import AppKit
import Combine
import Foundation
import PreciseSearchCore

@MainActor
final class SearchStore: ObservableObject {
    @Published var query = ""
    @Published var mode: SearchMode = .exact
    @Published var scope: SearchScope = .all
    @Published var ignoreExtension = true
    @Published var includeHidden = false
    @Published private(set) var results: [SearchResult] = []
    @Published private(set) var isSearching = false
    @Published private(set) var statusText = "等待搜索"
    @Published var selectedResultID: SearchResult.ID?

    private var searchTask: Task<Void, Never>?

    var selectedResult: SearchResult? {
        guard let selectedResultID else {
            return nil
        }

        return results.first { $0.id == selectedResultID }
    }

    func scheduleSearch() {
        searchTask?.cancel()

        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            clearResults()
            return
        }

        searchTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(250))
            guard !Task.isCancelled else {
                return
            }
            await self?.runSearch()
        }
    }

    func searchImmediately() {
        searchTask?.cancel()

        searchTask = Task { [weak self] in
            await self?.runSearch()
        }
    }

    func openSelected() {
        guard let selectedResult else {
            return
        }

        open(selectedResult)
    }

    func revealSelected() {
        guard let selectedResult else {
            return
        }

        reveal(selectedResult)
    }

    func copySelectedPath() {
        guard let selectedResult else {
            return
        }

        copyPath(selectedResult)
    }

    func open(_ result: SearchResult) {
        NSWorkspace.shared.open(URL(fileURLWithPath: result.path))
    }

    func reveal(_ result: SearchResult) {
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: result.path)])
    }

    func copyPath(_ result: SearchResult) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(result.path, forType: .string)
        statusText = "已复制路径"
    }

    private func clearResults() {
        results = []
        selectedResultID = nil
        isSearching = false
        statusText = "等待搜索"
    }

    private func runSearch() async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            clearResults()
            return
        }

        let request = SearchRequest(
            query: trimmedQuery,
            mode: mode,
            scope: scope,
            ignoreExtension: ignoreExtension,
            includeHidden: includeHidden,
            maxResults: 300
        )

        isSearching = true
        statusText = "搜索中"

        do {
            let foundResults = try await SearchService.search(request)
            guard !Task.isCancelled else {
                return
            }

            results = foundResults
            selectedResultID = foundResults.first?.id
            statusText = foundResults.isEmpty ? "没有结果" : "\(foundResults.count) 个结果"
        } catch {
            guard !Task.isCancelled else {
                return
            }

            results = []
            selectedResultID = nil
            statusText = error.localizedDescription
        }

        isSearching = false
    }
}
