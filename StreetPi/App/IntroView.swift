import SwiftUI

/// Cold-launch film. Tap anywhere to skip. Reduce Motion holds the final frame, then Home.
struct IntroView: View {
    var poster: UIImage?
    var onFinished: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.streetPiStill) private var still
    @State private var model: SplashPlayerModel?
    @State private var closingImage: UIImage?
    @State private var didFinish = false

    var body: some View {
        ZStack {
            SplashLayout.backdrop
            if let image = shownImage {
                SplashPoster(image: image)
            } else if playsFilm, let model {
                SplashPlayerHost(model: model)
            }
            Button(action: finish) {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("StreetPi")
            .accessibilityHint("Skips the introduction")
        }
        .ignoresSafeArea()
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .task { await run() }
        .onDisappear(perform: halt)
    }

    private var playsFilm: Bool {
        poster == nil && !reduceMotion && !still
    }

    private var shownImage: UIImage? {
        if let poster { return poster }
        return playsFilm ? nil : closingImage
    }

    private func run() async {
        if poster != nil { return }
        if reduceMotion || still {
            await holdStill()
            return
        }
        await playFilm()
    }

    private func holdStill() async {
        closingImage = UIImage(named: SplashLayout.endImageName, in: .main, compatibleWith: nil)
        guard reduceMotion, !still else { return }
        do {
            try await Task.sleep(for: SplashLayout.stillHold)
        } catch {
            return
        }
        finish()
    }

    private func playFilm() async {
        guard let url = Bundle.main.url(forResource: SplashLayout.resourceName, withExtension: "mp4") else {
            finish()
            return
        }
        SplashAudio.startAmbient()
        let playback = SplashPlayerModel()
        model = playback
        await Task.yield()
        await playback.play(url: url)
        guard !Task.isCancelled, !didFinish else { return }
        finish()
    }

    private func finish() {
        guard !didFinish else { return }
        didFinish = true
        halt()
        onFinished()
    }

    private func halt() {
        model?.player.pause()
        SplashAudio.stop()
    }
}

#Preview("Splash") {
    IntroView {}
        .environment(\.streetPiStill, true)
        .environment(\.colorScheme, .dark)
}
