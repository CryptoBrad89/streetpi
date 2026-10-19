import Foundation

public enum PauseLength: String, CaseIterable, Sendable, Equatable, Identifiable, Codable {
    case thirtySeconds
    case fiveMinutes
    case thirtyMinutes
    case oneHour
    case untilTurnedBackOn

    public var id: String { rawValue }

    /// Nil means the pause stays until someone turns blocking back on.
    public var seconds: Int? {
        switch self {
        case .thirtySeconds: 30
        case .fiveMinutes: 300
        case .thirtyMinutes: 1_800
        case .oneHour: 3_600
        case .untilTurnedBackOn: nil
        }
    }

    public var title: String {
        switch self {
        case .thirtySeconds: "30 seconds"
        case .fiveMinutes: "5 minutes"
        case .thirtyMinutes: "30 minutes"
        case .oneHour: "1 hour"
        case .untilTurnedBackOn: "Until it's turned back on"
        }
    }
}
