import Foundation

public struct MachineDesk: Sendable, Equatable, Codable {
    public var modelName: String
    public var host: String
    public var cpu: [MetricPoint]
    public var activity: [ActivityRow]
    public var services: [NamedRow]
    public var containers: [NamedRow]
    public var processes: [NamedRow]
    public var files: [HouseFile]
    public var schedule: [NamedRow]
    public var pins: [PinRow]
    public var backupSentence: String
    public var updates: [NamedRow]
    public var alerts: [HouseAlert]
    public var terminalTranscript: String
    public var hostPin: String

    public init(
        modelName: String,
        host: String,
        cpu: [MetricPoint],
        activity: [ActivityRow],
        services: [NamedRow],
        containers: [NamedRow],
        processes: [NamedRow],
        files: [HouseFile],
        schedule: [NamedRow],
        pins: [PinRow],
        backupSentence: String,
        updates: [NamedRow],
        alerts: [HouseAlert],
        terminalTranscript: String,
        hostPin: String
    ) {
        self.modelName = modelName
        self.host = host
        self.cpu = cpu
        self.activity = activity
        self.services = services
        self.containers = containers
        self.processes = processes
        self.files = files
        self.schedule = schedule
        self.pins = pins
        self.backupSentence = backupSentence
        self.updates = updates
        self.alerts = alerts
        self.terminalTranscript = terminalTranscript
        self.hostPin = hostPin
    }
}

extension MachineDesk {
    public static let houseFixture = MachineDesk(
        modelName: "Pi 5",
        host: "fixture.local",
        cpu: (0..<24).map { MetricPoint(hour: $0, value: 0.12 + Double($0 % 5) * 0.04) },
        activity: [
            ActivityRow(
                id: "copy",
                when: Date.streetFixtureNow.addingTimeInterval(-2 * 86_400),
                sentence: "The weekly copy succeeded."
            ),
            ActivityRow(
                id: "boot",
                when: Date.streetFixtureNow.addingTimeInterval(-12 * 86_400),
                sentence: "The Pi started."
            ),
        ],
        services: [
            NamedRow(id: "filter", name: "Ad blocker", detail: "Running"),
            NamedRow(id: "names", name: "Name lookup", detail: "Running"),
        ],
        containers: [
            NamedRow(id: "media", name: "Media helper", detail: "Running"),
            NamedRow(id: "status", name: "Status page", detail: "Running"),
        ],
        processes: [
            NamedRow(id: "filter-proc", name: "House filter", detail: "Quiet"),
            NamedRow(id: "names-proc", name: "Name lookup", detail: "Quiet"),
        ],
        files: [
            HouseFile(id: "notes", name: "notes.txt", text: "The weekly copy is on Sunday.\n"),
            HouseFile(id: "readme", name: "readme.txt", text: "This folder is a sample.\n"),
        ],
        schedule: [
            NamedRow(id: "weekly", name: "Weekly copy", detail: "Sunday at 3 in the morning"),
        ],
        pins: [
            PinRow(id: "17", name: "Pin 17", on: false),
            PinRow(id: "18", name: "Pin 18", on: true),
        ],
        backupSentence: "The weekly copy succeeded 2 days ago.",
        updates: [
            NamedRow(id: "sample", name: "sample-tool", detail: "An update is waiting"),
        ],
        alerts: [
            HouseAlert(id: "copy", sentence: "The weekly copy succeeded.", tone: .calm),
            HouseAlert(id: "logging", sentence: "Query logging is off.", tone: .attention),
        ],
        terminalTranscript: "streetpi@fixture.local:~ $\nThe Pi is up.\n",
        hostPin: "SHA256:fixture-not-a-real-host-pin"
    )

    public var openFile: HouseFile? { files.first }
}

public enum ActivityExport {
    public static func csv(_ rows: [ActivityRow]) -> String {
        let lines = rows.map { row in
            let stamp = ISO8601DateFormatter().string(from: row.when)
            return "\(stamp),\(row.sentence.replacingOccurrences(of: ",", with: " "))"
        }
        return (["when,what"] + lines).joined(separator: "\n")
    }
}

public enum HostPin {
    public static let account = "ssh.host-pin"

    public static func accepts(presented: String, pinned: String) -> Bool {
        !pinned.isEmpty && presented == pinned
    }
}

public enum DeviceSecret {
    public static let privateKeyAccount = "ssh.private-key"
}

public struct NetdataRoute: Sendable, Equatable {
    public var method: String
    public var path: String

    public init(method: String, path: String) {
        self.method = method
        self.path = path
    }
}

public enum NetdataAPI {
    public static let routes: [NetdataRoute] = [
        NetdataRoute(method: "GET", path: "/api/v1/info"),
        NetdataRoute(method: "GET", path: "/api/v3/data"),
        NetdataRoute(method: "GET", path: "/api/v1/alarms"),
    ]
}
