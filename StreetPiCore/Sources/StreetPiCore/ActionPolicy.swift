import Foundation

/// What the house is about to do. The confirmation protects the action, whoever is holding the phone.
public enum HouseholdAction: Sendable, Equatable {
    case refresh
    case reboot
    case shutDown
    case stopService(named: String)
    case deleteFiles(count: Int)
    case changeDNSSettings
    case killProcess(named: String)
    case pauseAdBlocking
    case resumeAdBlocking
}

public enum Confirmation: Sendable, Equatable {
    case notRequired
    case explain(String)
    case explainAndUseFaceID(String)

    public var explanation: String? {
        switch self {
        case .notRequired:
            nil
        case .explain(let text), .explainAndUseFaceID(let text):
            text
        }
    }

    public var requiresFaceID: Bool {
        if case .explainAndUseFaceID = self {
            return true
        }
        return false
    }
}

public enum ActionPolicy {
    public static func confirmation(for action: HouseholdAction) -> Confirmation {
        switch action {
        case .refresh:
            return .notRequired
        case .reboot:
            return .explainAndUseFaceID(
                "The Pi will restart. Ad blocking and the other house services will drop out for a few minutes."
            )
        case .shutDown:
            return .explainAndUseFaceID(
                "The Pi will turn off and stay off until someone switches the power back on."
            )
        case .stopService(let name):
            return .explain(
                "\(name) will stop until someone starts it again. The rest of the house stays up."
            )
        case .deleteFiles(let count):
            let noun = count == 1 ? "1 item" : "\(max(count, 0)) items"
            return .explainAndUseFaceID(
                "This will permanently delete \(noun) from the Pi. They cannot be undone."
            )
        case .changeDNSSettings:
            return .explain(
                "This changes how the house looks up names. Devices may briefly lose the network."
            )
        case .killProcess(let name):
            return .explainAndUseFaceID(
                "\(name) will be forced to quit. Anything it was doing stops immediately."
            )
        case .pauseAdBlocking:
            return .explain(
                "Ad blocking will pause for the whole house. Ads will load until it is turned back on."
            )
        case .resumeAdBlocking:
            return .explain("Ad blocking will turn back on for the whole house.")
        }
    }
}
