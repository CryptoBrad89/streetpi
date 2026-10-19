import Foundation

extension DNSDesk {
    public func applying(_ action: HouseholdAction) -> DNSDesk {
        var copy = self
        switch action {
        case .pauseAdBlocking(let length):
            copy.blocking = DNSBlocking(enabled: false, pause: length)
        case .resumeAdBlocking:
            copy.blocking = DNSBlocking(enabled: true)
        case .blockDomain(let name):
            copy.upsert(name, detail: "Blocked")
        case .allowDomain(let name):
            copy.upsert(name, detail: "Allowed")
        case .refresh, .signOutOfAdBlocker:
            break
        }
        return copy
    }

    private mutating func upsert(_ name: String, detail: String) {
        if let index = domains.firstIndex(where: { $0.name == name }) {
            domains[index].detail = detail
        } else {
            domains.append(NamedRow(id: name, name: name, detail: detail))
        }
    }
}
