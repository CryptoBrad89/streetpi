import SwiftUI

struct ComposeText: View {
    var lines: [String]

    @Environment(\.afterglowGate) private var gate
    @State private var revealed = false

    var body: some View {
        VStack(alignment: .leading, spacing: AfterglowShape.tight) {
            ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                ComposeLine(
                    text: line,
                    index: index,
                    revealed: gate.still ? true : revealed,
                    blurs: gate.holdsMotion,
                    animates: !gate.still
                )
            }
        }
        .onAppear(perform: reveal)
    }

    private func reveal() {
        guard !gate.still else { return }
        withAnimation(AfterglowMotion.spring) {
            revealed = true
        }
    }
}
