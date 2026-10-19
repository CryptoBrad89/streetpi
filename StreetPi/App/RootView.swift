import SwiftUI
import StreetPiCore

struct RootView: View {
    var now: Date
    @State private var screen = HouseScreen.ready(.healthyFixture)
    @State private var section = AppSection.home
    @State private var showIntro = true
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(PreferenceKey.appearance) private var appearanceRaw = AppearancePreference.system.rawValue

    private var appearance: AppearancePreference {
        AppearancePreference(rawValue: appearanceRaw) ?? .system
    }

    var body: some View {
        ZStack {
            AppShell(
                section: section,
                appearance: appearance,
                screen: screen,
                now: now,
                onSection: { section = $0 },
                onAppearance: { appearanceRaw = $0.rawValue }
            )
            if showIntro {
                IntroView(theme: .house(colorScheme), animatesIn: true) {
                    showIntro = false
                }
                .transition(.opacity)
            }
        }
        .preferredColorScheme(appearance.colorScheme)
        .environment(\.secretStore, KeychainSecretStore())
        .task {
            let clock = now
            let loader = HouseholdStatusLoader.healthyFixture { clock }
            if let loaded = try? await loader.load() {
                screen = .ready(loaded)
            }
        }
    }
}
