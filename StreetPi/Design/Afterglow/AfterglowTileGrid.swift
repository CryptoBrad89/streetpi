import SwiftUI

/// Equal columns that drop to one column when the minimum width no longer fits.
struct AfterglowTileGrid: Layout {
    var spacing: CGFloat
    var minimumColumnWidth: CGFloat
    var maximumColumns: Int

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let measured = proposal.width ?? widestChild(subviews)
        let width = measured.isFinite && measured > 0 ? measured : 320
        let columns = columnCount(for: width, count: subviews.count)
        let columnWidth = columnWidth(for: width, columns: columns)
        let heights = rowHeights(
            subviews: subviews,
            columns: columns,
            proposal: ProposedViewSize(width: columnWidth, height: nil)
        )
        let gaps = spacing * CGFloat(max(0, heights.count - 1))
        return CGSize(width: width, height: heights.reduce(0, +) + gaps)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let columns = columnCount(for: bounds.width, count: subviews.count)
        let columnWidth = columnWidth(for: bounds.width, columns: columns)
        let childProposal = ProposedViewSize(width: columnWidth, height: nil)
        let heights = rowHeights(subviews: subviews, columns: columns, proposal: childProposal)
        var originY = bounds.minY
        for row in heights.indices {
            var originX = bounds.minX
            let start = row * columns
            let end = min(start + columns, subviews.count)
            for index in start..<end {
                let point = CGPoint(x: originX, y: originY)
                subviews[index].place(at: point, anchor: .topLeading, proposal: childProposal)
                originX += columnWidth + spacing
            }
            originY += heights[row] + spacing
        }
    }

    private func widestChild(_ subviews: Subviews) -> CGFloat {
        let widths = subviews.map { $0.sizeThatFits(.unspecified).width }.filter(\.isFinite)
        return widths.max() ?? 320
    }

    private func columnCount(for width: CGFloat, count: Int) -> Int {
        guard count > 0 else { return 1 }
        let denominator = minimumColumnWidth + spacing
        guard denominator > 0, width.isFinite else { return 1 }
        let ratio = (width + spacing) / denominator
        guard ratio.isFinite else { return 1 }
        let fitted = Int(min(ratio, Double(max(count, maximumColumns))))
        return min(maximumColumns, max(1, min(count, fitted)))
    }

    private func columnWidth(for width: CGFloat, columns: Int) -> CGFloat {
        let gaps = spacing * CGFloat(max(0, columns - 1))
        return max(0, (width - gaps) / CGFloat(columns))
    }

    private func rowHeights(subviews: Subviews, columns: Int, proposal: ProposedViewSize) -> [CGFloat] {
        guard columns > 0, !subviews.isEmpty else { return [] }
        var heights: [CGFloat] = []
        var index = 0
        while index < subviews.count {
            var rowHeight: CGFloat = 0
            for offset in 0..<columns where index + offset < subviews.count {
                rowHeight = max(rowHeight, subviews[index + offset].sizeThatFits(proposal).height)
            }
            heights.append(rowHeight)
            index += columns
        }
        return heights
    }
}
