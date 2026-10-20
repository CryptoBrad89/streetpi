import SwiftUI

/// A single frame of the splash film, aspect-filled the same way the player is.
struct SplashPoster: View {
    var image: UIImage

    var body: some View {
        GeometryReader { proxy in
            SplashPosterFrame(
                image: image,
                fit: SplashLayout.fit(viewSize: proxy.size, mediaSize: image.size),
                size: proxy.size
            )
        }
        .accessibilityHidden(true)
    }
}

private struct SplashPosterFrame: View {
    var image: UIImage
    var fit: SplashFit
    var size: CGSize

    var body: some View {
        if fit == .letterbox {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: size.width, height: size.height)
        } else {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: size.width, height: size.height)
                .clipped()
        }
    }
}
