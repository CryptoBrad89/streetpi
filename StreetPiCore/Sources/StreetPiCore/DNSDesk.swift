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
    /// True only when the Pi allows the app password to change config. StreetPi does not turn this on.
    public var configWritesAllowed: Bool
    public var queries: [NamedRow]
    public var topClients: [NamedRow]
    public var topDomains: [NamedRow]
    public var topBlocked: [NamedRow]

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
        services: [DNSServiceChoice],
        configWritesAllowed: Bool = false,
        queries: [NamedRow] = [],
        topClients: [NamedRow] = [],
        topDomains: [NamedRow] = [],
        topBlocked: [NamedRow] = []
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
        self.configWritesAllowed = configWritesAllowed
        self.queries = queries
        self.topClients = topClients
        self.topDomains = topDomains
        self.topBlocked = topBlocked
    }
}

extension DNSDesk {
    public static let houseFixture = DNSDesk(
            queryLoggingEnabled: false,
            blocking: DNSBlocking(enabled: true),
            chartIsSample: false,
            day: [],
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

    /// The house after query logging is on and local names can be saved. The Pi is not changed here.
    public static let loggingOnFixture: DNSDesk = {
        var desk = houseFixture
        desk.queryLoggingEnabled = true
        desk.configWritesAllowed = true
        desk.chartIsSample = false
        desk.day = (0..<24).map { hour in
            DayChartSample(hour: hour, allowed: 40 + (hour * 7) % 30, blocked: 8 + (hour * 3) % 12)
        }
        desk.queries = [
            NamedRow(id: "q1", name: "ads.example.test", detail: "Blocked"),
            NamedRow(id: "q2", name: "printer.fixture.local", detail: "Allowed"),
        ]
        desk.topClients = [NamedRow(id: "living-room", name: "Living room", detail: "12")]
        desk.topDomains = [NamedRow(id: "ads", name: "ads.example.test", detail: "9")]
        desk.topBlocked = [NamedRow(id: "ads-blocked", name: "ads.example.test", detail: "9")]
        return desk
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
