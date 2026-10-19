import SwiftUI

/// The splash slot. This build shows a still. A later video splash replaces `SplashStill` only.
struct SplashStill: View {
    var theme: StreetTheme

    var body: some View {
        VStack(alignment: .leading, spacing: Rhythm.line) {
            Image(systemName: "house.fill")
                .font(.largeTitle)
                .foregroundStyle(theme.accent)
                .accessibilityHidden(true)
            Text("StreetPi")
                .font(.system(.largeTitle, design: .serif))
                .foregroundStyle(theme.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            Text("The house, in plain English.")
                .font(.title3)
                .foregroundStyle(theme.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Rhythm.block)
        .frame(maxWidth: 420, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(theme.surface)
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(theme.hairline, lineWidth: 1)
                }
        }
        .accessibilityElement(children: .contain)
    }
}

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
            SplashStill(theme: theme)
                .padding(Rhythm.page)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(visible ? 1 : 0)
                .accessibilitySortPriority(0)
            VStack {
                HStack {
                    Spacer()
                    SkipControl(title: "Skip", action: onFinished)
                        .accessibilitySortPriority(1)
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
            withAnimation(.easeOut(duration: 0.35)) {
                visible = true
            }
        }
        .task {
            let hold: Duration = reduceMotion ? .milliseconds(200) : .milliseconds(800)
            try? await Task.sleep(for: hold)
            guard !Task.isCancelled else { return }
            onFinished()
        }
    }
}
