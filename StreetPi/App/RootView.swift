import CryptoKit
import SwiftUI
import StreetPiCore

struct RootView: View {
    var now: Date
    @State private var screen = HouseScreen.ready(.healthyFixture)
    @State private var section = AppSection.home
    @State private var showIntro = true
    @State private var desk = DNSDesk.houseFixture
    @State private var dnsPage: DNSPage?
    @State private var machine = MachineDesk.houseFixture
    @State private var machinePage: MachinePage?
    @State private var pending: HouseholdAction?
    @State private var passwordSaved = false
    @State private var keySaved = false
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
                    if next != .group(.piHealth) {
                        machinePage = nil
                    }
                },
                onAppearance: { appearanceRaw = $0.rawValue },
                desk: desk,
                dnsPage: dnsPage,
                machine: machine,
                machinePage: machinePage,
                pendingAction: pending,
                passwordSaved: passwordSaved,
                keySaved: keySaved,
                onDNSPage: { dnsPage = $0 },
                onMachinePage: { machinePage = $0 },
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
            ensureDeviceSecrets()
        }
    }

    private func ensureDeviceSecrets() {
        let account = DeviceSecret.privateKeyAccount
        if (try? secretStore.load(for: account)) == nil {
            let raw = Curve25519.Signing.PrivateKey().rawRepresentation
            try? secretStore.save(raw, for: account)
        }
        keySaved = (try? secretStore.load(for: account)) != nil
        if (try? secretStore.load(for: HostPin.account)) == nil {
            try? secretStore.save(Data(machine.hostPin.utf8), for: HostPin.account)
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
        machine = machine.applying(action)
        pending = nil
    }
}
