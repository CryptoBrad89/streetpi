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
    @State private var showsSetup = false
    @State private var dnsSession = DNSSessionHold()
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase
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
                showsSetup: showsSetup,
                sessionActive: dnsSession.client != nil,
                onDNSPage: { dnsPage = $0 },
                onPending: { pending = $0 },
                onConfirm: { action in
                    Task { await confirm(action) }
                },
                onSavePassword: { showsSetup = true },
                onSetupSave: saveSetup,
                onSetupCancel: { showsSetup = false }
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
        .onChange(of: scenePhase) { _, phase in
            guard phase == .background else { return }
            let client = dnsSession.client
            Task {
                await client?.appDidEnterBackground()
            }
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

    private func saveSetup(_ raw: String) {
        guard !raw.isEmpty else { return }
        do {
            try secretStore.save(Data(raw.utf8), for: AppPassword.account)
            let pin = Data(PiholeCertificate.houseFixture.sha256Fingerprint.utf8)
            try secretStore.save(pin, for: AppPassword.certificatePin)
            passwordSaved = true
            showsSetup = false
        } catch {
            showsSetup = true
        }
    }

    private func confirm(_ action: HouseholdAction) async {
        let policy = ActionPolicy.confirmation(for: action)
        if policy.requiresFaceID {
            let reason = policy.explanation ?? "Confirm this change."
            let allowed = await FaceIDGate.allow(reason: reason)
            guard allowed else { return }
        }
        if case .signOutOfAdBlocker = action {
            await dnsSession.client?.signOut()
        } else {
            desk = desk.applying(action)
        }
        pending = nil
    }
}
