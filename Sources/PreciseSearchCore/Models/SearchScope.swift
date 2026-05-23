import Foundation

public enum SearchScope: String, CaseIterable, Identifiable, Sendable {
    case all
    case home
    case desktop
    case downloads
    case documents

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .all:
            "这台 Mac"
        case .home:
            "用户目录"
        case .desktop:
            "桌面"
        case .downloads:
            "下载"
        case .documents:
            "文稿"
        }
    }

    public var path: String? {
        switch self {
        case .all:
            nil
        case .home:
            FileManager.default.homeDirectoryForCurrentUser.path
        case .desktop:
            firstPath(for: .desktopDirectory)
        case .downloads:
            firstPath(for: .downloadsDirectory)
        case .documents:
            firstPath(for: .documentDirectory)
        }
    }

    private func firstPath(for directory: FileManager.SearchPathDirectory) -> String {
        FileManager.default.urls(for: directory, in: .userDomainMask).first?.path
            ?? FileManager.default.homeDirectoryForCurrentUser.path
    }
}
