import Foundation

public enum StreetJSON {
    public static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    public static func encoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }
}

public enum FixtureError: Error, Equatable {
    case missing(String)
}

public enum FixtureBook {
    public static func snapshot(named name: String) throws -> HouseholdSnapshot {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
            throw FixtureError.missing(name)
        }
        let data = try Data(contentsOf: url)
        return try StreetJSON.decoder().decode(HouseholdSnapshot.self, from: data)
    }
}

extension HouseholdSnapshot {
    public static let healthyFixture = HouseholdSnapshot(
        capturedAt: .streetFixtureNow,
        link: .homeNetwork,
        services: [
            ServiceHealth(id: "pi-hole", name: "Pi-hole", kind: .dnsFilter, state: .responding),
            ServiceHealth(id: "unbound", name: "Unbound", kind: .resolver, state: .responding),
            ServiceHealth(id: "home-assistant", name: "Home Assistant", kind: .homeAutomation, state: .responding),
            ServiceHealth(id: "media", name: "Media", kind: .media, state: .responding),
        ],
        machine: MachineReading(
            cpuUsedFraction: 0.18,
            temperatureCelsius: 47.2,
            memoryUsedFraction: 0.41,
            diskUsedFraction: 0.22,
            uptimeSeconds: 1_036_800
        ),
        dns: DNSSummary(blockingEnabled: true)
    )

    public static let awayTroubleFixture = HouseholdSnapshot(
        capturedAt: Date(timeIntervalSince1970: 1_792_421_280),
        link: .away(cachedAt: Date(timeIntervalSince1970: 1_792_421_280)),
        services: [
            ServiceHealth(id: "pi-hole", name: "Pi-hole", kind: .dnsFilter, state: .notResponding),
            ServiceHealth(id: "unbound", name: "Unbound", kind: .resolver, state: .responding),
            ServiceHealth(id: "home-assistant", name: "Home Assistant", kind: .homeAutomation, state: .responding),
            ServiceHealth(id: "media", name: "Media", kind: .media, state: .responding),
        ],
        machine: MachineReading(
            cpuUsedFraction: 0.18,
            temperatureCelsius: 47.2,
            memoryUsedFraction: 0.41,
            diskUsedFraction: 0.22,
            uptimeSeconds: 1_036_800
        ),
        dns: DNSSummary(blockingEnabled: true)
    )
}
