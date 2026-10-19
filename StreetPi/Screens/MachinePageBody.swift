import SwiftUI
import StreetPiCore

struct MachinePageBody: View {
    var page: MachinePage
    var desk: MachineDesk
    var machine: MachineReading?
    var theme: StreetTheme
    var wide: Bool
    var now: Date
    var keySaved: Bool
    var onAction: (HouseholdAction) -> Void

    var body: some View {
        switch page {
        case .dashboard, .chart, .activity, .terminal, .editor, .power:
            reading
        case .services, .containers, .processes, .files, .schedule, .updates:
            lists
        case .pins:
            PinScreen(pins: desk.pins, theme: theme, wide: wide, onAction: onAction)
        case .backups:
            BackupScreen(sentence: desk.backupSentence, theme: theme, wide: wide, onAction: onAction)
        }
    }

    @ViewBuilder
    private var reading: some View {
        switch page {
        case .dashboard:
            MachineHome(desk: desk, machine: machine, theme: theme, wide: wide, onPage: { _ in })
        case .chart:
            MetricChartScreen(points: desk.cpu, theme: theme, wide: wide)
        case .activity:
            ActivityScreen(rows: desk.activity, theme: theme, wide: wide, now: now)
        case .terminal:
            TerminalScreen(transcript: desk.terminalTranscript, keySaved: keySaved, theme: theme, wide: wide)
        case .editor:
            EditorScreen(file: desk.openFile, theme: theme, wide: wide, onAction: onAction)
        case .power:
            PowerScreen(theme: theme, wide: wide, onAction: onAction)
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private var lists: some View {
        switch page {
        case .services:
            namedList(desk.services, action: "Stop") { onAction(.stopMachineService(named: $0)) }
        case .containers:
            namedList(desk.containers, action: "Stop") { onAction(.stopContainer(named: $0)) }
        case .processes:
            namedList(desk.processes, action: "Stop it") { onAction(.killProcess(named: $0)) }
        case .files:
            namedList(
                desk.files.map { NamedRow(id: $0.id, name: $0.name, detail: "In the house account") },
                action: "Remove"
            ) { _ in onAction(.deleteFiles(count: 1)) }
        case .schedule:
            namedList(desk.schedule, action: "Remove") { onAction(.removeCron(named: $0)) }
        case .updates:
            namedList(desk.updates, action: "Install") { _ in onAction(.installUpdates) }
        default:
            EmptyView()
        }
    }

    private func namedList(
        _ rows: [NamedRow],
        action: String,
        onRow: @escaping (String) -> Void
    ) -> some View {
        MachineListScreen(
            title: page.title,
            intro: page.blurb,
            rows: rows,
            actionTitle: action,
            theme: theme,
            wide: wide,
            onRow: onRow
        )
    }
}

private struct PinScreen: View {
    var pins: [PinRow]
    var theme: StreetTheme
    var wide: Bool
    var onAction: (HouseholdAction) -> Void

    var body: some View {
        DeskScroll(wide: wide) {
            Text("Pins")
                .font(.system(.largeTitle, design: .rounded))
                .foregroundStyle(theme.ink)
                .accessibilityAddTraits(.isHeader)
            ForEach(pins) { pin in
                Button(pin.on ? "Turn \(pin.name) off" : "Turn \(pin.name) on") {
                    onAction(.setPin(named: pin.name, on: !pin.on))
                }
                .font(.body.weight(.semibold))
                .foregroundStyle(theme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Rhythm.line)
                .background(theme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }
}

private struct BackupScreen: View {
    var sentence: String
    var theme: StreetTheme
    var wide: Bool
    var onAction: (HouseholdAction) -> Void

    var body: some View {
        DeskScroll(wide: wide) {
            Text("Copies")
                .font(.system(.largeTitle, design: .rounded))
                .foregroundStyle(theme.ink)
                .accessibilityAddTraits(.isHeader)
            Text(sentence).font(.body).foregroundStyle(theme.secondary)
            Button("Run the weekly copy") { onAction(.runBackup) }
                .font(.body.weight(.semibold))
                .foregroundStyle(theme.accent)
        }
    }
}
