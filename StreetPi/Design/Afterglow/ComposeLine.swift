import SwiftUI

struct ComposeLine: View {
    var text: String
    var index: Int
    var revealed: Bool
    var blurs: Bool
    var animates: Bool

    @Environment(\.afterglowPalette) private var palette

    var body: some View {
        line
            .opacity(blurs || revealed ? 1 : 0)
            .modifier(ComposeBlur(enabled: blurs, progress: revealed ? 1 : 0))
            .animation(animates ? lineAnimation : nil, value: revealed)
    }

    private var line: some View {
        Text(text)
            .font(AfterglowType.body)
            .foregroundStyle(palette.secondary)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var lineAnimation: Animation {
        AfterglowMotion.spring.delay(Double(index) * AfterglowMotion.composeStep)
    }
}
