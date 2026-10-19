import Foundation

/// How long to wait before asking the house again.
/// A quiet Pi is checked every half minute. Each miss waits longer, up to five minutes.
public enum RefreshPace {
    public static let settledSeconds = 30
    public static let ceilingSeconds = 300

    public static func waitSeconds(afterFailures failures: Int) -> Int {
        guard failures > 0 else { return settledSeconds }
        let steps = min(failures, 4)
        let doubled = settledSeconds << steps
        return min(doubled, ceilingSeconds)
    }
}

public struct HousePollTick: Sendable, Equatable {
    public var snapshot: HouseholdSnapshot?
    public var unreachable: Bool
    public var waitSeconds: Int

    public init(snapshot: HouseholdSnapshot?, unreachable: Bool, waitSeconds: Int) {
        self.snapshot = snapshot
        self.unreachable = unreachable
        self.waitSeconds = waitSeconds
    }
}

/// One refresh at a time, off the main actor. The load closure is the only I/O.
/// This type never opens a socket itself.
public actor HousePoller {
    private let load: @Sendable () async throws -> HouseholdSnapshot
    private var failures = 0

    public init(load: @escaping @Sendable () async throws -> HouseholdSnapshot) {
        self.load = load
    }

    public func tick() async -> HousePollTick {
        do {
            let snapshot = try await load()
            failures = 0
            return HousePollTick(
                snapshot: snapshot,
                unreachable: false,
                waitSeconds: RefreshPace.waitSeconds(afterFailures: 0)
            )
        } catch {
            failures += 1
            return HousePollTick(
                snapshot: nil,
                unreachable: true,
                waitSeconds: RefreshPace.waitSeconds(afterFailures: failures)
            )
        }
    }
}
