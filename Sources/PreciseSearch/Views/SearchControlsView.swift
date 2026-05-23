import PreciseSearchCore
import SwiftUI

struct SearchControlsView: View {
    @ObservedObject var store: SearchStore

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("文件名", text: $store.query)
                    .textFieldStyle(.plain)
                    .font(.system(size: 20, weight: .medium))

                if !store.query.isEmpty {
                    Button {
                        store.query = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .help("清空")
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(.quaternary.opacity(0.45), in: RoundedRectangle(cornerRadius: 8))

            HStack(spacing: 12) {
                Picker("模式", selection: $store.mode) {
                    ForEach(SearchMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 132)

                Picker("范围", selection: $store.scope) {
                    ForEach(SearchScope.allCases) { scope in
                        Text(scope.title).tag(scope)
                    }
                }
                .frame(width: 148)

                Toggle("忽略扩展名", isOn: $store.ignoreExtension)
                    .disabled(store.mode != .exact)

                Toggle("隐藏文件", isOn: $store.includeHidden)

                Spacer()

                Button {
                    store.searchImmediately()
                } label: {
                    Label("搜索", systemImage: "magnifyingglass")
                }
                .keyboardShortcut(.return, modifiers: [.command])
                .disabled(store.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .controlSize(.regular)
        }
        .padding(16)
        .background(.regularMaterial)
    }
}
