import Foundation

public struct MetricPoint: Sendable, Equatable, Identifiable, Codable {
    public var hour: Int
    public var value: Double

    public var id: Int { hour }

    public init(hour: Int, value: Double) {
        self.hour = hour
        self.value = value
    }
}

public struct ActivityRow: Sendable, Equatable, Identifiable, Codable {
    public var id: String
    public var when: Date
    public var sentence: String

    public init(id: String, when: Date, sentence: String) {
        self.id = id
        self.when = when
        self.sentence = sentence
    }
}

public struct HouseFile: Sendable, Equatable, Identifiable, Codable {
    public var id: String
    public var name: String
    public var text: String

    public init(id: String, name: String, text: String) {
        self.id = id
        self.name = name
        self.text = text
    }
}

public struct PinRow: Sendable, Equatable, Identifiable, Codable {
    public var id: String
    public var name: String
    public var on: Bool

    public init(id: String, name: String, on: Bool) {
        self.id = id
        self.name = name
        self.on = on
    }
}

public struct HouseAlert: Sendable, Equatable, Identifiable, Codable {
    public var id: String
    public var sentence: String
    public var tone: PlainEnglishStatus.Tone

    public init(id: String, sentence: String, tone: PlainEnglishStatus.Tone) {
        self.id = id
        self.sentence = sentence
        self.tone = tone
    }
}

public enum MachinePage: String, CaseIterable, Sendable, Equatable, Identifiable {
    case dashboard
    case chart
    case activity
    case services
    case containers
    case processes
    case terminal
    case files
    case editor
    case schedule
    case pins
    case backups
    case updates
    case power

    public var id: String { rawValue }

    public var title: String { MachinePageCopy.title[self] ?? rawValue }

    public var blurb: String { MachinePageCopy.blurb[self] ?? "" }

    public var symbolName: String { MachinePageCopy.symbol[self] ?? "circle" }
}

private enum MachinePageCopy {
    static let title: [MachinePage: String] = [
        .dashboard: "The Pi",
        .chart: "Charts",
        .activity: "Activity",
        .services: "Services",
        .containers: "Containers",
        .processes: "Processes",
        .terminal: "Terminal",
        .files: "Files",
        .editor: "Editor",
        .schedule: "Schedule",
        .pins: "Pins",
        .backups: "Copies",
        .updates: "Updates",
        .power: "Power",
    ]

    static let blurb: [MachinePage: String] = [
        .dashboard: "How the Pi is doing right now.",
        .chart: "One measurement over the last day.",
        .activity: "What the Pi has been doing.",
        .services: "The jobs that stay running.",
        .containers: "The boxed jobs.",
        .processes: "What is using the Pi right now.",
        .terminal: "A sample session. Nothing is connected.",
        .files: "Files in the house account.",
        .editor: "Read and replace a file.",
        .schedule: "Jobs that run on their own.",
        .pins: "The Pi's little switches.",
        .backups: "The weekly copy.",
        .updates: "Software waiting to install.",
        .power: "Restart or turn the Pi off.",
    ]

    static let symbol: [MachinePage: String] = [
        .dashboard: "cpu",
        .chart: "chart.xyaxis.line",
        .activity: "clock",
        .services: "gearshape",
        .containers: "shippingbox",
        .processes: "list.bullet",
        .terminal: "terminal",
        .files: "folder",
        .editor: "doc.text",
        .schedule: "calendar",
        .pins: "circle.grid.3x3",
        .backups: "externaldrive",
        .updates: "arrow.down.circle",
        .power: "power",
    ]
}
