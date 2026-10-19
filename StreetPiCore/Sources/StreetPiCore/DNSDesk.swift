import Foundation

public struct DNSDesk: Sendable, Equatable, Codable {
    public var queryLoggingEnabled: Bool
    public var blocking: DNSBlocking
    public var chartIsSample: Bool
    public var day: [DayChartSample]
    public var knownClients: Int
    public var listCount: Int
    public var listsUpdatedAt: Date
    public var clients: [NamedRow]
    public var groups: [NamedRow]
    public var domains: [NamedRow]
    public var lists: [DNSListRow]
    public var localNames: [NamedRow]
    public var services: [DNSServiceChoice]

    public init(
        queryLoggingEnabled: Bool,
        blocking: DNSBlocking,
        chartIsSample: Bool,
        day: [DayChartSample],
        knownClients: Int,
        listCount: Int,
        listsUpdatedAt: Date,
        clients: [NamedRow],
        groups: [NamedRow],
        domains: [NamedRow],
        lists: [DNSListRow],
        localNames: [NamedRow],
        services: [DNSServiceChoice]
    ) {
        self.queryLoggingEnabled = queryLoggingEnabled
        self.blocking = blocking
        self.chartIsSample = chartIsSample
        self.day = day
        self.knownClients = knownClients
        self.listCount = listCount
        self.listsUpdatedAt = listsUpdatedAt
        self.clients = clients
        self.groups = groups
        self.domains = domains
        self.lists = lists
        self.localNames = localNames
        self.services = services
    }
}

extension DNSDesk {
    public static let houseFixture: DNSDesk = {
        let samples = (0..<24).map { hour in
            DayChartSample(hour: hour, allowed: 40 + (hour * 7) % 30, blocked: 8 + (hour * 3) % 12)
        }
        return DNSDesk(
            queryLoggingEnabled: false,
            blocking: DNSBlocking(enabled: true),
            chartIsSample: true,
            day: samples,
            knownClients: 4,
            listCount: 2,
            listsUpdatedAt: Date.streetFixtureNow.addingTimeInterval(-2 * 86_400),
            clients: [
                NamedRow(id: "living-room", name: "Living room", detail: "Default"),
                NamedRow(id: "kitchen", name: "Kitchen display", detail: "Default"),
                NamedRow(id: "office", name: "Office laptop", detail: "Default"),
                NamedRow(id: "upstairs", name: "Upstairs speaker", detail: "Default"),
            ],
            groups: [
                NamedRow(id: "default", name: "Default", detail: "4 devices"),
                NamedRow(id: "guests", name: "Guests", detail: "No devices yet"),
            ],
            domains: [
                NamedRow(id: "ads", name: "ads.example.test", detail: "Blocked"),
                NamedRow(id: "news", name: "news.example.test", detail: "Allowed"),
            ],
            lists: [
                DNSListRow(id: "block", name: "House block list", host: "fixture.local", enabled: true),
                DNSListRow(id: "allow", name: "House allow list", host: "fixture.local", enabled: true),
            ],
            localNames: [
                NamedRow(id: "printer", name: "printer.fixture.local", detail: "Living room"),
            ],
            services: [
                DNSServiceChoice(
                    id: "video-ads",
                    name: "Video ads",
                    detail: "Clips that play before a show",
                    blocked: true
                ),
                DNSServiceChoice(
                    id: "trackers",
                    name: "Trackers",
                    detail: "Sites that follow a device around",
                    blocked: true
                ),
                DNSServiceChoice(
                    id: "shopping-ads",
                    name: "Shopping ads",
                    detail: "Offers from shops",
                    blocked: false
                ),
            ]
        )
    }()

    public var blockingLine: String {
        if blocking.enabled {
            return "Ads are being blocked."
        }
        if let pause = blocking.pause, pause != .untilTurnedBackOn {
            return "Ad blocking is paused for \(pause.title)."
        }
        return "Ad blocking is paused."
    }
}
