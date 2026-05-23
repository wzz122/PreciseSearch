import AppKit
import PreciseSearchCore
import SwiftUI

struct ResultRowView: View {
    let result: SearchResult

    var body: some View {
        HStack(spacing: 12) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: result.path))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 3) {
                Text(result.name)
                    .font(.body)
                    .lineLimit(1)

                Text(result.folder)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer(minLength: 16)

            VStack(alignment: .trailing, spacing: 3) {
                Text(result.kind)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    if let modifiedAt = result.modifiedAt {
                        Text(DisplayFormatters.modifiedDate.string(from: modifiedAt))
                    }

                    if let size = result.size {
                        Text(DisplayFormatters.fileSize.string(fromByteCount: Int64(size)))
                    }
                }
                .font(.caption)
                .foregroundStyle(.tertiary)
                .lineLimit(1)
            }
        }
        .padding(.vertical, 6)
    }
}
