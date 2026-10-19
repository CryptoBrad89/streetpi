import Foundation

public struct DNSRoute: Sendable, Equatable {
    public var method: String
    public var path: String
    public var needsConfigAccess: Bool

    public init(method: String, path: String, needsConfigAccess: Bool) {
        self.method = method
        self.path = path
        self.needsConfigAccess = needsConfigAccess
    }
}

/// Pi-hole v6 paths a later client would call. No host, and nothing here opens a connection.
public enum DNSAPI {
    public static let routes: [DNSRoute] = [
        DNSRoute(method: "POST", path: "/api/auth", needsConfigAccess: false),
        DNSRoute(method: "GET", path: "/api/stats/summary", needsConfigAccess: false),
        DNSRoute(method: "GET", path: "/api/history", needsConfigAccess: false),
        DNSRoute(method: "GET", path: "/api/dns/blocking", needsConfigAccess: false),
        DNSRoute(method: "POST", path: "/api/dns/blocking", needsConfigAccess: false),
        DNSRoute(method: "GET", path: "/api/stats/top_domains", needsConfigAccess: false),
        DNSRoute(method: "GET", path: "/api/stats/top_clients", needsConfigAccess: false),
        DNSRoute(method: "GET", path: "/api/queries", needsConfigAccess: false),
        DNSRoute(method: "GET", path: "/api/clients", needsConfigAccess: false),
        DNSRoute(method: "POST", path: "/api/clients", needsConfigAccess: false),
        DNSRoute(method: "GET", path: "/api/groups", needsConfigAccess: false),
        DNSRoute(method: "POST", path: "/api/groups", needsConfigAccess: false),
        DNSRoute(method: "GET", path: "/api/domains/deny/exact", needsConfigAccess: false),
        DNSRoute(method: "POST", path: "/api/domains/deny/exact", needsConfigAccess: false),
        DNSRoute(method: "GET", path: "/api/lists", needsConfigAccess: false),
        DNSRoute(method: "POST", path: "/api/lists", needsConfigAccess: false),
        DNSRoute(method: "GET", path: "/api/config", needsConfigAccess: true),
        DNSRoute(method: "PATCH", path: "/api/config", needsConfigAccess: true),
        DNSRoute(method: "POST", path: "/api/action/gravity", needsConfigAccess: false),
        DNSRoute(method: "POST", path: "/api/action/restartdns", needsConfigAccess: false),
        DNSRoute(method: "POST", path: "/api/action/flush/logs", needsConfigAccess: false),
    ]
}
