import Foundation

public struct SearchRequest: Equatable, Sendable {
    public var query: String
    public var mode: SearchMode
    public var scope: SearchScope
    public var ignoreExtension: Bool
    public var includeHidden: Bool
    public var maxResults: Int

    public init(
        query: String,
        mode: SearchMode,
        scope: SearchScope,
        ignoreExtension: Bool,
        includeHidden: Bool,
        maxResults: Int = 300
    ) {
        self.query = query
        self.mode = mode
        self.scope = scope
        self.ignoreExtension = ignoreExtension
        self.includeHidden = includeHidden
        self.maxResults = maxResults
    }

    public var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
