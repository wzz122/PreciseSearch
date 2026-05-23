import Foundation

enum FileSystemSearch {
    static func search(_ request: SearchRequest, excluding excludedPaths: Set<String>) -> [SearchResult] {
        search(request, roots: defaultRoots(for: request.scope), excluding: excludedPaths)
    }

    static func search(_ request: SearchRequest, roots: [URL], excluding excludedPaths: Set<String>) -> [SearchResult] {
        guard !request.trimmedQuery.isEmpty else {
            return []
        }

        let resourceKeys: Set<URLResourceKey> = [
            .isDirectoryKey,
            .fileSizeKey,
            .contentModificationDateKey,
            .localizedTypeDescriptionKey,
            .isHiddenKey
        ]
        var options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants]
        if !request.includeHidden {
            options.insert(.skipsHiddenFiles)
        }

        var results: [SearchResult] = []
        var seen = excludedPaths
        let fileManager = FileManager.default

        for root in roots where fileManager.fileExists(atPath: root.path) {
            guard let enumerator = fileManager.enumerator(
                at: root,
                includingPropertiesForKeys: Array(resourceKeys),
                options: options
            ) else {
                continue
            }

            for case let url as URL in enumerator {
                let path = url.path
                guard seen.insert(path).inserted else {
                    continue
                }

                guard matches(filename: url.lastPathComponent, request: request) else {
                    continue
                }

                guard request.includeHidden || !isHidden(url: url) else {
                    continue
                }

                guard let result = makeResult(url: url) else {
                    continue
                }

                results.append(result)

                if results.count >= request.maxResults {
                    return results
                }
            }
        }

        return results
    }

    static func matches(filename: String, request: SearchRequest) -> Bool {
        let query = normalized(request.trimmedQuery)
        guard !query.isEmpty else {
            return false
        }

        let target = normalized(comparableName(for: filename, ignoreExtension: request.ignoreExtension))

        switch request.mode {
        case .exact:
            return target.contains(query)
        case .fuzzy:
            return containsCharactersInOrder(query, in: target)
        }
    }

    private static func defaultRoots(for scope: SearchScope) -> [URL] {
        if let path = scope.path {
            return [URL(fileURLWithPath: path, isDirectory: true)]
        }

        let directories: [FileManager.SearchPathDirectory] = [
            .downloadsDirectory,
            .desktopDirectory,
            .documentDirectory,
            .picturesDirectory,
            .moviesDirectory,
            .musicDirectory
        ]

        var seen = Set<String>()
        return directories.compactMap { directory in
            FileManager.default.urls(for: directory, in: .userDomainMask).first
        }
        .filter { seen.insert($0.path).inserted }
    }

    private static func comparableName(for filename: String, ignoreExtension: Bool) -> String {
        if ignoreExtension {
            return (filename as NSString).deletingPathExtension
        }

        return filename
    }

    private static func normalized(_ value: String) -> String {
        value.folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: .current)
    }

    private static func containsCharactersInOrder(_ query: String, in target: String) -> Bool {
        var cursor = target.startIndex

        for character in query {
            guard let match = target[cursor...].firstIndex(of: character) else {
                return false
            }
            cursor = target.index(after: match)
        }

        return true
    }

    private static func makeResult(url: URL) -> SearchResult? {
        guard FileManager.default.fileExists(atPath: url.path) else {
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
            path: url.path,
            name: url.lastPathComponent,
            folder: url.deletingLastPathComponent().path,
            kind: kind,
            isDirectory: isDirectory,
            size: isDirectory ? nil : values?.fileSize,
            modifiedAt: values?.contentModificationDate
        )
    }

    private static func isHidden(url: URL) -> Bool {
        if url.lastPathComponent.hasPrefix(".") {
            return true
        }

        let values = try? url.resourceValues(forKeys: [.isHiddenKey])
        return values?.isHidden ?? false
    }
}
