import SwiftUI

struct SettingsView: View {
    var theme: StreetTheme
    var appearance: AppearancePreference
    var direction: DesignDirection
    var onAppearance: (AppearancePreference) -> Void
    var onDirection: (DesignDirection) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Rhythm.block) {
                Text("Settings")
                    .font(.system(.largeTitle, design: .serif))
                    .foregroundStyle(theme.ink)
                    .accessibilityAddTraits(.isHeader)
                appearanceBlock
                directionBlock
                Text("StreetPi is the same app for everyone in the house. Nothing here is tied to a person.")
                    .font(.footnote)
                    .foregroundStyle(theme.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
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

    private var directionBlock: some View {
        VStack(alignment: .leading, spacing: Rhythm.line) {
            Text("Direction")
                .font(.headline)
                .foregroundStyle(theme.ink)
            Text("Three ways the home screen can look. The facts stay the same.")
                .font(.subheadline)
                .foregroundStyle(theme.secondary)
                .fixedSize(horizontal: false, vertical: true)
            ForEach(DesignDirection.allCases) { choice in
                Button {
                    onDirection(choice)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(choice.title)
                            .font(.title3)
                            .foregroundStyle(theme.ink)
                        Text(choice.blurb)
                            .font(.subheadline)
                            .foregroundStyle(theme.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Rhythm.line)
                    .background(
                        choice == direction ? theme.surface : Color.clear,
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(choice == direction ? theme.accent : theme.hairline, lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(choice == direction ? .isSelected : [])
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
            .padding(.vertical, 10)
            .background(selected ? theme.ink : theme.surface, in: Capsule())
            .overlay {
                Capsule().stroke(theme.hairline, lineWidth: selected ? 0 : 1)
            }
            .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
