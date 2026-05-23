import SwiftUI

struct StatusBarView: View {
    @ObservedObject var store: SearchStore

    var body: some View {
        HStack(spacing: 10) {
            if store.isSearching {
                ProgressView()
                    .controlSize(.small)
            }

            Text(store.statusText)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer()

            Button {
                store.openSelected()
            } label: {
                Label("打开", systemImage: "arrow.up.right.square")
            }
            .disabled(store.selectedResult == nil)
            .help("打开")

            Button {
                store.revealSelected()
            } label: {
                Label("Finder", systemImage: "finder")
            }
            .disabled(store.selectedResult == nil)
            .help("在 Finder 显示")

            Button {
                store.copySelectedPath()
            } label: {
                Label("路径", systemImage: "doc.on.doc")
            }
            .disabled(store.selectedResult == nil)
            .help("复制路径")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
    }
}
