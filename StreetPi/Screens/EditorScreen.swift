import Runestone
import SwiftUI
import StreetPiCore
import UIKit

struct EditorScreen: View {
    var file: HouseFile?
    var theme: StreetTheme
    var wide: Bool
    var onAction: (HouseholdAction) -> Void

    var body: some View {
        DeskScroll(wide: wide) {
            Text(file?.name ?? "Editor")
                .font(.system(.largeTitle, design: .rounded))
                .foregroundStyle(theme.ink)
                .accessibilityAddTraits(.isHeader)
            Text(file?.text ?? "")
                .font(.body)
                .foregroundStyle(theme.ink)
                .fixedSize(horizontal: false, vertical: true)
            EditorHost(text: file?.text ?? "")
                .frame(minHeight: 160)
            if let file {
                Button("Save \(file.name)") { onAction(.saveFile(named: file.name)) }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(theme.accent)
            }
        }
    }
}

struct EditorHost: UIViewRepresentable {
    var text: String

    func makeUIView(context: Context) -> TextView {
        let view = TextView(frame: .zero)
        view.setState(TextViewState(text: text))
        return view
    }

    func updateUIView(_ uiView: TextView, context: Context) {}
}
