import PreciseSearchCore
import SwiftUI

struct ContentView: View {
    @StateObject private var store = SearchStore()

    var body: some View {
        VStack(spacing: 0) {
            SearchControlsView(store: store)

            Divider()

            ResultsContentView(store: store)

            Divider()

            StatusBarView(store: store)
        }
        .onChange(of: store.query) { _, _ in store.scheduleSearch() }
        .onChange(of: store.mode) { _, _ in store.scheduleSearch() }
        .onChange(of: store.scope) { _, _ in store.scheduleSearch() }
        .onChange(of: store.ignoreExtension) { _, _ in store.scheduleSearch() }
        .onChange(of: store.includeHidden) { _, _ in store.scheduleSearch() }
    }
}
