import Foundation

extension DNSDesk {
    public func applying(_ action: HouseholdAction) -> DNSDesk {
        var copy = self
        copy.applyBlocking(action)
        copy.applyCatalog(action)
        return copy
    }

    private mutating func applyBlocking(_ action: HouseholdAction) {
        switch action {
        case .pauseAdBlocking(let length):
            blocking = DNSBlocking(enabled: false, pause: length)
        case .resumeAdBlocking:
            blocking = DNSBlocking(enabled: true)
        case .updateBlockLists:
            listsUpdatedAt = .streetFixtureNow
        case .setServiceBlocked(let name, let blocked):
            setService(name, blocked: blocked)
        default:
            break
        }
    }

    private mutating func applyCatalog(_ action: HouseholdAction) {
        switch action {
        case .addDomain(let name, let blocked):
            domains.append(NamedRow(id: name, name: name, detail: blocked ? "Blocked" : "Allowed"))
        case .addClient(let name):
            clients.append(NamedRow(id: name, name: name, detail: "Default"))
            knownClients = clients.count
        case .addGroup(let name):
            groups.append(NamedRow(id: name, name: name, detail: "No devices yet"))
        case .addBlockList(let name):
            lists.append(DNSListRow(id: name, name: name, host: "fixture.local", enabled: true))
            listCount = lists.count
        case .addLocalName(let name):
            guard configWritesAllowed else { return }
            localNames.append(NamedRow(id: name, name: name, detail: "Inside the house"))
        case .removeDNSEntry(let kind, let name):
            guard kind != .localName || configWritesAllowed else { return }
            remove(kind, named: name)
        default:
            break
        }
    }

    private mutating func remove(_ kind: DNSEntryKind, named name: String) {
        switch kind {
        case .client:
            clients.removeAll { $0.name == name }
            knownClients = clients.count
        case .group:
            groups.removeAll { $0.name == name }
        case .domain:
            domains.removeAll { $0.name == name }
        case .blockList:
            lists.removeAll { $0.name == name }
            listCount = lists.count
        case .localName:
            localNames.removeAll { $0.name == name }
        }
    }

    private mutating func setService(_ name: String, blocked: Bool) {
        guard let index = services.firstIndex(where: { $0.name == name }) else { return }
        services[index].blocked = blocked
    }
}
