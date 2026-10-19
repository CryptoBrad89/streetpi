import SwiftUI
import StreetPiCore

struct RootView: View {
    var now: Date
    @State private var snapshot = HouseholdSnapshot.healthyFixture
    @State private var section = AppSection.home
    @State private var showIntro = true
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(PreferenceKey.appearance) private var appearanceRaw = AppearancePreference.system.rawValue
    @AppStorage(PreferenceKey.direction) private var directionRaw = DesignDirection.lampblack.rawValue

    private var appearance: AppearancePreference {
        AppearancePreference(rawValue: appearanceRaw) ?? .system
    }

    private var direction: DesignDirection {
        DesignDirection(rawValue: directionRaw) ?? .lampblack
    }

    var body: some View {
        ZStack {
            AppShell(
                section: section,
                direction: direction,
                appearance: appearance,
                snapshot: snapshot,
                now: now,
                onSection: { section = $0 },
                onAppearance: { appearanceRaw = $0.rawValue },
                onDirection: { directionRaw = $0.rawValue }
            )
            if showIntro {
                IntroView(theme: direction.theme(colorScheme), animatesIn: true) {
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
                snapshot = loaded
            }
        }
    }
}
