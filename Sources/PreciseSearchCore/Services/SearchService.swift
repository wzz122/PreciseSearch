import Foundation

public enum SearchService {
    public static func search(_ request: SearchRequest) async throws -> [SearchResult] {
        try await Task.detached(priority: .userInitiated) {
            try searchSynchronously(request)
        }.value
    }

    private static func searchSynchronously(_ request: SearchRequest) throws -> [SearchResult] {
        guard !request.trimmedQuery.isEmpty else {
            return []
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/mdfind")

        var arguments = ["-0"]
        if let scopePath = request.scope.path {
            arguments.append(contentsOf: ["-onlyin", scopePath])
        }
        arguments.append(MetadataQueryBuilder.predicate(for: request))
        process.arguments = arguments

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        try process.run()
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            let message = String(data: errorData, encoding: .utf8) ?? "mdfind failed"
            throw SearchServiceError.commandFailed(process.terminationStatus, message)
        }

        let paths = outputData.split(separator: 0).compactMap {
            String(data: Data($0), encoding: .utf8)
        }

        var seen = Set<String>()
        var results: [SearchResult] = []
        results.reserveCapacity(min(paths.count, request.maxResults))

        for path in paths {
            guard seen.insert(path).inserted else {
                continue
            }
            guard request.includeHidden || !isHidden(path: path) else {
                continue
            }
            guard let result = makeResult(path: path) else {
                continue
            }

            results.append(result)

            if results.count >= request.maxResults {
                break
            }
        }

        return results
    }

    private static func makeResult(path: String) -> SearchResult? {
        let url = URL(fileURLWithPath: path)
        guard FileManager.default.fileExists(atPath: path) else {
            return nil
        }

        let keys: Set<URLResourceKey> = [
            .isDirectoryKey,
            .fileSizeKey,
            .contentModificationDateKey,
            .localizedTypeDescriptionKey
        ]
        let values = try? url.resourceValues(forKeys: keys)
        let isDirectory = values?.isDirectory ?? false
        let kind = values?.localizedTypeDescription ?? (isDirectory ? "文件夹" : "文件")

        return SearchResult(
            path: path,
            name: url.lastPathComponent,
            folder: url.deletingLastPathComponent().path,
            kind: kind,
            isDirectory: isDirectory,
            size: isDirectory ? nil : values?.fileSize,
            modifiedAt: values?.contentModificationDate
        )
    }

    private static func isHidden(path: String) -> Bool {
        let url = URL(fileURLWithPath: path)
        if url.lastPathComponent.hasPrefix(".") {
            return true
        }

        let values = try? url.resourceValues(forKeys: [.isHiddenKey])
        return values?.isHidden ?? false
    }
}

public enum SearchServiceError: LocalizedError, Equatable {
    case commandFailed(Int32, String)

    public var errorDescription: String? {
        switch self {
        case let .commandFailed(status, message):
            "mdfind 退出码 \(status)：\(message.trimmingCharacters(in: .whitespacesAndNewlines))"
        }
    }
}
