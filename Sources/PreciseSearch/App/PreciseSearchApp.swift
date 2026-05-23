import AppKit
import SwiftUI

@main
struct PreciseSearchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup("精准搜索", id: "main") {
            ContentView()
                .frame(minWidth: 760, minHeight: 500)
        }
        .defaultSize(width: 920, height: 620)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }

        MenuBarExtra("精准搜索", systemImage: "magnifyingglass.circle") {
            QuickMenuView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}
