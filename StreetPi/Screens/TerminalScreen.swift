import SwiftUI
import StreetPiCore
import SwiftTerm
import UIKit

struct TerminalScreen: View {
    var transcript: String
    var keySaved: Bool
    var theme: StreetTheme
    var wide: Bool

    var body: some View {
        DeskScroll(wide: wide) {
            Text("Terminal")
                .font(.system(.largeTitle, design: .rounded))
                .foregroundStyle(theme.ink)
                .accessibilityAddTraits(.isHeader)
            Text(keySaved ? "Key saved on this phone." : "No key on this phone yet.")
                .font(.subheadline)
                .foregroundStyle(theme.secondary)
            Text("Pinned to the sample Pi. Nothing is connected.")
                .font(.subheadline)
                .foregroundStyle(theme.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Text(transcript)
                .font(.body.monospaced())
                .foregroundStyle(theme.ink)
                .fixedSize(horizontal: false, vertical: true)
            TermHost(transcript: transcript)
                .frame(minHeight: 180)
                .accessibilityIdentifier(SSHLibraryAnchor.name)
        }
    }
}

struct TermHost: UIViewRepresentable {
    var transcript: String

    func makeUIView(context: Context) -> TerminalView {
        let view = TerminalView(frame: .zero, font: nil)
        view.feed(text: transcript)
        return view
    }

    func updateUIView(_ uiView: TerminalView, context: Context) {}
}
