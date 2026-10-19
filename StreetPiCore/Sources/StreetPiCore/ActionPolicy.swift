import Foundation

/// What the house is about to do. The confirmation protects the action, whoever is holding the phone.
public enum HouseholdAction: Sendable, Equatable {
    case refresh
    case reboot
    case shutDown
    case stopService(named: String)
    case deleteFiles(count: Int)
    case killProcess(named: String)
    case pauseAdBlocking(PauseLength)
    case resumeAdBlocking
    case blockDomain(named: String)
    case allowDomain(named: String)
    case signOutOfAdBlocker
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
        if action == .refresh {
            return .notRequired
        }
        if isDestructive(action) {
            return .explainAndUseFaceID(destructiveCopy(action))
        }
        return .explain(plainCopy(action))
    }

    private static func isDestructive(_ action: HouseholdAction) -> Bool {
        switch action {
        case .reboot, .shutDown, .deleteFiles, .killProcess:
            true
        default:
            false
        }
    }

    private static func destructiveCopy(_ action: HouseholdAction) -> String {
        switch action {
        case .reboot:
            return "The Pi will restart. Ad blocking and the other house services will drop out for a few minutes."
        case .shutDown:
            return "The Pi will turn off and stay off until someone switches the power back on."
        case .deleteFiles(let count):
            let noun = count == 1 ? "1 item" : "\(max(count, 0)) items"
            return "This will permanently delete \(noun) from the Pi. They cannot be undone."
        case .killProcess(let name):
            return "\(name) will be forced to quit. Anything it was doing stops immediately."
        default:
            return "This change is hard to undo."
        }
    }

    private static func plainCopy(_ action: HouseholdAction) -> String {
        switch action {
        case .stopService(let name):
            return "\(name) will stop until someone starts it again. The rest of the house stays up."
        case .pauseAdBlocking(let length):
            return pauseCopy(length)
        case .resumeAdBlocking:
            return "Ad blocking will turn back on for the whole house now."
        case .blockDomain(let name):
            return "\(name) will be blocked for the whole house."
        case .allowDomain(let name):
            return "\(name) will be allowed for the whole house."
        case .signOutOfAdBlocker:
            return "This phone will sign out. The password stays on this phone, and ad blocking stays as it is."
        default:
            return "This will change the house."
        }
    }

    private static func pauseCopy(_ length: PauseLength) -> String {
        """
        Ad blocking will pause for the whole house for \(length.title). \
        It turns itself back on. Ads will load until then.
        """
    }
}
