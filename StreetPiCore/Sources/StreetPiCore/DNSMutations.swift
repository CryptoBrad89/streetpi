import Foundation

extension DNSDesk {
    public func applying(_ action: HouseholdAction) -> DNSDesk {
        var copy = self
        switch action {
        case .pauseAdBlocking(let length):
            copy.blocking = DNSBlocking(enabled: false, pause: length)
        case .resumeAdBlocking:
            copy.blocking = DNSBlocking(enabled: true)
        case .addDomain(let name, let blocked):
            copy.domains.append(NamedRow(id: name, name: name, detail: blocked ? "Blocked" : "Allowed"))
        case .addClient(let name):
            copy.clients.append(NamedRow(id: name, name: name, detail: "Default"))
            copy.knownClients = copy.clients.count
        case .addGroup(let name):
            copy.groups.append(NamedRow(id: name, name: name, detail: "No devices yet"))
        case .addBlockList(let name):
            copy.lists.append(DNSListRow(id: name, name: name, host: "fixture.local", enabled: true))
            copy.listCount = copy.lists.count
        case .addLocalName(let name):
            copy.localNames.append(NamedRow(id: name, name: name, detail: "Inside the house"))
        case .removeDNSEntry(let kind, let name):
            copy.remove(kind, named: name)
        case .setServiceBlocked(let name, let blocked):
            copy.setService(name, blocked: blocked)
        case .updateBlockLists:
            copy.listsUpdatedAt = .streetFixtureNow
        case .restartDNS, .flushQueryLog, .refresh, .reboot, .shutDown, .stopService,
             .deleteFiles, .changeDNSSettings, .killProcess:
            break
        }
        return copy
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
