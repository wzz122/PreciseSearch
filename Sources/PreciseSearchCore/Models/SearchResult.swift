import Foundation

public struct SearchResult: Identifiable, Hashable, Sendable {
    public var id: String { path }

    public let path: String
    public let name: String
    public let folder: String
    public let kind: String
    public let isDirectory: Bool
    public let size: Int?
    public let modifiedAt: Date?

    public init(
        path: String,
        name: String,
        folder: String,
        kind: String,
        isDirectory: Bool,
        size: Int?,
        modifiedAt: Date?
    ) {
        self.path = path
        self.name = name
        self.folder = folder
        self.kind = kind
        self.isDirectory = isDirectory
        self.size = size
        self.modifiedAt = modifiedAt
    }
}
