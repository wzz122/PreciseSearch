import AppKit
import SwiftUI

struct QuickMenuView: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button {
            openWindow(id: "main")
            NSApp.activate(ignoringOtherApps: true)
        } label: {
            Label("打开精准搜索", systemImage: "magnifyingglass")
        }

        Divider()

        Text("默认精准搜索")
            .font(.caption)
            .foregroundStyle(.secondary)

        Button("退出") {
            NSApp.terminate(nil)
        }
    }
}
