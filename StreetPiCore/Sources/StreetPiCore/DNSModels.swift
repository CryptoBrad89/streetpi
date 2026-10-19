import Foundation

public struct DayChartSample: Sendable, Equatable, Identifiable, Codable {
    public var hour: Int
    public var allowed: Int
    public var blocked: Int

    public var id: Int { hour }

    public init(hour: Int, allowed: Int, blocked: Int) {
        self.hour = hour
        self.allowed = allowed
        self.blocked = blocked
    }
}

public struct DNSBlocking: Sendable, Equatable, Codable {
    public var enabled: Bool
    public var pause: PauseLength?

    public init(enabled: Bool, pause: PauseLength? = nil) {
        self.enabled = enabled
        self.pause = pause
    }
}

public struct NamedRow: Sendable, Equatable, Identifiable, Codable {
    public var id: String
    public var name: String
    public var detail: String

    public init(id: String, name: String, detail: String) {
        self.id = id
        self.name = name
        self.detail = detail
    }
}

public struct DNSListRow: Sendable, Equatable, Identifiable, Codable {
    public var id: String
    public var name: String
    public var host: String
    public var enabled: Bool

    public init(id: String, name: String, host: String, enabled: Bool) {
        self.id = id
        self.name = name
        self.host = host
        self.enabled = enabled
    }
}

public struct DNSServiceChoice: Sendable, Equatable, Identifiable, Codable {
    public var id: String
    public var name: String
    public var detail: String
    public var blocked: Bool

    public init(id: String, name: String, detail: String, blocked: Bool) {
        self.id = id
        self.name = name
        self.detail = detail
        self.blocked = blocked
    }
}

public enum DNSEntryKind: String, Sendable, Equatable, Codable {
    case client
    case group
    case domain
    case blockList
    case localName
}

public enum DNSCopy {
    public static let queryLogTitle = "Nothing to show."
    public static let queryLogDetail = """
    Query logging is off, so the Pi is not keeping a list of lookups. Ads are still being blocked.
    """
    public static let liveLogTitle = "Nothing is streaming."
    public static let liveLogDetail = """
    A live list needs query logging, and that is off. Ads are still being blocked.
    """
    public static let topListsTitle = "No top lists yet."
    public static let topListsDetail = """
    Those lists come from the query log, and logging is off. Ads are still being blocked.
    """
    public static let chartCaption = """
    Query logging is off, so a live chart would be empty. This sample shows the shape of the last day.
    """
    public static let localNameNotice = """
    Saving a local name on the Pi needs a setting StreetPi will not change. You can still read the names here.
    """
}
