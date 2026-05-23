import PreciseSearchCore
import SwiftUI

struct ResultsListView: View {
    @ObservedObject var store: SearchStore

    var body: some View {
        List(selection: $store.selectedResultID) {
            ForEach(store.results) { result in
                ResultRowView(result: result)
                    .tag(result.id)
                    .contentShape(Rectangle())
                    .onTapGesture(count: 2) {
                        store.open(result)
                    }
                    .contextMenu {
                        Button {
                            store.open(result)
                        } label: {
                            Label("打开", systemImage: "arrow.up.right.square")
                        }

                        Button {
                            store.reveal(result)
                        } label: {
                            Label("在 Finder 显示", systemImage: "finder")
                        }

                        Button {
                            store.copyPath(result)
                        } label: {
                            Label("复制路径", systemImage: "doc.on.doc")
                        }
                    }
            }
        }
        .listStyle(.inset)
    }
}
