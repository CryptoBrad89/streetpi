import SwiftUI
import StreetPiCore

struct ActionConfirm: View {
    var action: HouseholdAction
    var theme: StreetTheme
    var onCancel: () -> Void
    var onConfirm: () -> Void

    private var confirmation: Confirmation {
        ActionPolicy.confirmation(for: action)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: Rhythm.block) {
                    Text("Before this changes")
                        .font(.system(.title2, design: .rounded))
                        .foregroundStyle(theme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                    Text(confirmation.explanation ?? "")
                        .font(.body)
                        .foregroundStyle(theme.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    VStack(spacing: Rhythm.line) {
                        confirmButton
                        Button("Cancel", action: onCancel)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(theme.ink)
                            .frame(maxWidth: .infinity)
                            .padding(Rhythm.line)
                    }
                }
                .padding(Rhythm.block)
                .frame(maxWidth: 480)
                .background(theme.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(theme.hairline, lineWidth: 1)
                }
                .padding(Rhythm.page)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .accessibilityAddTraits(.isModal)
        .accessibilityElement(children: .contain)
    }

    private var confirmButton: some View {
        let title = confirmation.requiresFaceID ? "Confirm with Face ID" : "Confirm"
        return Button(action: onConfirm) {
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .padding(Rhythm.line)
        }
        .buttonStyle(.plain)
        .foregroundStyle(theme.background)
        .background(theme.accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityLabel(title)
    }
}

struct SavePasswordSheet: View {
    var theme: StreetTheme
    var onSave: (String) -> Void
    var onCancel: () -> Void

    @State private var entry = ""

    var body: some View {
        VStack(alignment: .leading, spacing: Rhythm.block) {
            Text("App password")
                .font(.system(.title2, design: .rounded))
                .foregroundStyle(theme.ink)
                .accessibilityAddTraits(.isHeader)
            Text("It stays on this phone. StreetPi does not show it again.")
                .font(.body)
                .foregroundStyle(theme.secondary)
                .fixedSize(horizontal: false, vertical: true)
            SecureField("Password", text: $entry)
                .textContentType(.password)
                .font(.body)
                .foregroundStyle(theme.ink)
            Button("Save on this phone") {
                let password = entry
                entry = ""
                onSave(password)
            }
            .font(.headline)
            .foregroundStyle(theme.accent)
            .disabled(entry.isEmpty)
            Button("Cancel", action: onCancel)
                .font(.body)
                .foregroundStyle(theme.secondary)
        }
        .padding(Rhythm.page)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(theme.background)
    }
}
