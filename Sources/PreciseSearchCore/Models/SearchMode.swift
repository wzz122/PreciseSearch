import Foundation

public enum SearchMode: String, CaseIterable, Identifiable, Sendable {
    case exact
    case fuzzy

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .exact:
            "精准"
        case .fuzzy:
            "模糊"
        }
    }
}
