import SwiftUI

struct SettingsView: View {
    var theme: StreetTheme
    var appearance: AppearancePreference
    var onAppearance: (AppearancePreference) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Rhythm.block) {
                Text("Settings")
                    .font(.system(.largeTitle, design: .rounded))
                    .foregroundStyle(theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                appearanceBlock
                Text("StreetPi is the same app for everyone in the house. Nothing here is tied to a person.")
                    .font(.body)
                    .foregroundStyle(theme.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(versionLine)
                    .font(.subheadline)
                    .foregroundStyle(theme.secondary)
                    .accessibilityLabel(versionLine)
            }
            .padding(.horizontal, Rhythm.page)
            .padding(.bottom, Rhythm.page)
            .frame(maxWidth: 680, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
    }

    private var appearanceBlock: some View {
        VStack(alignment: .leading, spacing: Rhythm.line) {
            Text("Appearance")
                .font(.headline)
                .foregroundStyle(theme.ink)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: Rhythm.tight) {
                    appearanceButtons
                }
                VStack(alignment: .leading, spacing: Rhythm.tight) {
                    appearanceButtons
                }
            }
        }
    }

    private var versionLine: String {
        let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
        guard !short.isEmpty, !build.isEmpty else { return "StreetPi" }
        return "Version \(short) (\(build))"
    }

    private var appearanceButtons: some View {
        ForEach(AppearancePreference.allCases) { choice in
            ChoiceButton(
                title: choice.title,
                selected: choice == appearance,
                theme: theme
            ) {
                onAppearance(choice)
            }
        }
    }
}

private struct ChoiceButton: View {
    var title: String
    var selected: Bool
    var theme: StreetTheme
    var action: () -> Void

    var body: some View {
        Button(title, action: action)
            .font(.body.weight(.medium))
            .foregroundStyle(selected ? theme.background : theme.ink)
            .padding(.horizontal, 16)
            .frame(minHeight: 44)
            .background(selected ? theme.ink : theme.surface, in: Capsule())
            .overlay {
                Capsule().stroke(theme.hairline, lineWidth: selected ? 0 : 1)
            }
            .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
