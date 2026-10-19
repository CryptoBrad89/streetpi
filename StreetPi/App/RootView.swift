import SwiftUI
import StreetPiCore

struct RootView: View {
    var now: Date
    @State private var screen = HouseScreen.ready(.healthyFixture)
    @State private var section = AppSection.home
    @State private var showIntro = true
    @State private var desk = DNSDesk.houseFixture
    @State private var dnsPage: DNSPage?
    @State private var pending: HouseholdAction?
    @State private var passwordSaved = false
    @State private var showPassword = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.secretStore) private var secretStore
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
                onSection: { next in
                    section = next
                    if next != .group(.adBlockerAndDNS) {
                        dnsPage = nil
                    }
                },
                onAppearance: { appearanceRaw = $0.rawValue },
                desk: desk,
                dnsPage: dnsPage,
                pendingAction: pending,
                passwordSaved: passwordSaved,
                onDNSPage: { dnsPage = $0 },
                onPending: { pending = $0 },
                onConfirm: { action in
                    Task { await confirm(action) }
                },
                onSavePassword: { showPassword = true }
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
        .sheet(isPresented: $showPassword) {
            SavePasswordSheet(
                theme: .house(colorScheme),
                onSave: savePassword,
                onCancel: { showPassword = false }
            )
        }
        .task {
            let clock = now
            let loader = HouseholdStatusLoader.healthyFixture { clock }
            if let loaded = try? await loader.load() {
                screen = .ready(loaded)
            }
            let stored = try? secretStore.load(for: AppPassword.account)
            passwordSaved = stored != nil
        }
    }

    private func savePassword(_ raw: String) {
        guard !raw.isEmpty else { return }
        try? secretStore.save(Data(raw.utf8), for: AppPassword.account)
        passwordSaved = true
        showPassword = false
    }

    private func confirm(_ action: HouseholdAction) async {
        let policy = ActionPolicy.confirmation(for: action)
        if policy.requiresFaceID {
            let reason = policy.explanation ?? "Confirm this change."
            let allowed = await FaceIDGate.allow(reason: reason)
            guard allowed else { return }
        }
        desk = desk.applying(action)
        pending = nil
    }
}
