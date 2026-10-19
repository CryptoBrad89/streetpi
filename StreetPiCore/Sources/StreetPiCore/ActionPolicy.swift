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
    case pauseAdBlocking(PauseLength)
    case resumeAdBlocking
    case addDomain(named: String, blocked: Bool)
    case addClient(named: String)
    case addGroup(named: String)
    case addBlockList(named: String)
    case addLocalName(named: String)
    case removeDNSEntry(DNSEntryKind, named: String)
    case setServiceBlocked(named: String, blocked: Bool)
    case updateBlockLists
    case restartDNS
    case flushQueryLog
    case stopMachineService(named: String)
    case startMachineService(named: String)
    case stopContainer(named: String)
    case startContainer(named: String)
    case saveFile(named: String)
    case runBackup
    case installUpdates
    case setPin(named: String, on: Bool)
    case addCron(named: String)
    case removeCron(named: String)
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
        case .reboot, .shutDown, .deleteFiles, .killProcess, .restartDNS, .flushQueryLog,
             .removeDNSEntry, .removeCron:
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
        case .restartDNS:
            return "DNS will restart. Devices may briefly fail to look up names."
        case .flushQueryLog:
            return "The saved lookup history will be erased. This cannot be undone."
        case .removeDNSEntry(_, let name):
            return "\(name) will be removed for the whole house. This cannot be undone."
        case .removeCron(let name):
            return "\(name) will be removed from the schedule. This cannot be undone."
        default:
            return "This change is hard to undo."
        }
    }

    private static func plainCopy(_ action: HouseholdAction) -> String {
        switch action {
        case .stopService(let name):
            return "\(name) will stop until someone starts it again. The rest of the house stays up."
        case .changeDNSSettings:
            return "This changes how the house looks up names. Devices may briefly lose the network."
        case .pauseAdBlocking(let length):
            return pauseCopy(length)
        case .resumeAdBlocking:
            return "Ad blocking will turn back on for the whole house."
        case .setServiceBlocked(let name, true):
            return "\(name) will be blocked for the whole house."
        case .setServiceBlocked(let name, false):
            return "\(name) will be allowed again for the whole house."
        case .updateBlockLists:
            return "The Pi will download the latest block lists. Lookups may be slow for a minute."
        case .addDomain, .addClient, .addGroup, .addBlockList, .addLocalName:
            return addCopy(action)
        case .stopMachineService, .startMachineService, .stopContainer, .startContainer,
             .saveFile, .runBackup, .installUpdates, .setPin, .addCron:
            return machineCopy(action)
        default:
            return "This will change the house."
        }
    }

    private static func machineCopy(_ action: HouseholdAction) -> String {
        switch action {
        case .stopMachineService(let name):
            return "\(name) will stop until someone starts it again."
        case .startMachineService(let name):
            return "\(name) will start."
        case .stopContainer(let name):
            return "\(name) will stop. The rest of the house stays up."
        case .startContainer(let name):
            return "\(name) will start."
        case .saveFile(let name):
            return "\(name) will be replaced with what is on the screen."
        case .runBackup:
            return "The weekly copy will run now. The Pi may be busy for a while."
        case .installUpdates:
            return "The Pi will install the waiting updates. It may need a restart afterwards."
        case .setPin(let name, let on):
            return on ? "\(name) will turn on." : "\(name) will turn off."
        case .addCron(let name):
            return "\(name) will be added to the schedule."
        default:
            return "This will change the Pi."
        }
    }

    private static func addCopy(_ action: HouseholdAction) -> String {
        switch action {
        case .addDomain(let name, let blocked):
            return blocked
                ? "\(name) will be blocked for the whole house."
                : "\(name) will be allowed for the whole house."
        case .addClient(let name):
            return "\(name) will be added as a device the house knows."
        case .addGroup(let name):
            return "\(name) will be added as a group of devices that share a rule."
        case .addBlockList(let name):
            return "\(name) will be added. The house will not download it until the lists are updated."
        case .addLocalName(let name):
            return "\(name) will be saved as a name that stays inside the house."
        default:
            return "This will be added for the whole house."
        }
    }

    private static func pauseCopy(_ length: PauseLength) -> String {
        switch length {
        case .untilTurnedBackOn:
            "Ad blocking will pause for the whole house. Ads will load until it is turned back on."
        default:
            "Ad blocking will pause for the whole house for \(length.title). Ads will load until it comes back on."
        }
    }
}
