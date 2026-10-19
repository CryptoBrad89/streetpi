import SwiftUI

struct IntroView: View {
    var theme: StreetTheme
    var animatesIn: Bool
    var onFinished: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var visible: Bool

    init(theme: StreetTheme, animatesIn: Bool = false, onFinished: @escaping () -> Void) {
        self.theme = theme
        self.animatesIn = animatesIn
        self.onFinished = onFinished
        _visible = State(initialValue: !animatesIn)
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: Rhythm.line) {
                Text("StreetPi")
                    .font(.system(.largeTitle, design: .serif))
                    .foregroundStyle(theme.ink)
                    .accessibilityAddTraits(.isHeader)
                Text("The house, in plain English.")
                    .font(.title3)
                    .foregroundStyle(theme.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(Rhythm.page)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .opacity(visible ? 1 : 0)
            VStack {
                HStack {
                    Spacer()
                    SkipControl(title: "Skip", action: onFinished)
                }
                Spacer()
            }
            .padding(Rhythm.page)
        }
        .onAppear {
            guard animatesIn, !reduceMotion else {
                visible = true
                return
            }
            withAnimation(.easeOut(duration: 0.45)) {
                visible = true
            }
        }
        .task {
            let hold: Duration = reduceMotion ? .milliseconds(400) : .milliseconds(1_350)
            try? await Task.sleep(for: hold)
            guard !Task.isCancelled else { return }
            onFinished()
        }
    }
}
