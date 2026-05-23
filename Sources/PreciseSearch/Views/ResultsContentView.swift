import PreciseSearchCore
import SwiftUI

struct ResultsContentView: View {
    @ObservedObject var store: SearchStore

    var body: some View {
        ZStack {
            if store.results.isEmpty {
                ContentUnavailableView(
                    store.isSearching ? "搜索中" : store.statusText,
                    systemImage: store.isSearching ? "magnifyingglass" : "doc.text.magnifyingglass"
                )
            } else {
                ResultsListView(store: store)
            }
        }
    }
}
