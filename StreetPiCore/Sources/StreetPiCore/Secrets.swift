import Foundation

public protocol SecretStoring: Sendable {
    func save(_ secret: Data, for account: String) throws
    func load(for account: String) throws -> Data?
    func delete(for account: String) throws
}

public enum SecretStoreError: Error, Equatable {
    case failed
}

/// Test double. Its description never includes secret bytes or account names.
public final class MemorySecretStore: SecretStoring, @unchecked Sendable, CustomStringConvertible {
    private let lock = NSLock()
    private var values: [String: Data] = [:]

    public init() {}

    public func save(_ secret: Data, for account: String) throws {
        lock.lock()
        values[account] = secret
        lock.unlock()
    }

    public func load(for account: String) throws -> Data? {
        lock.lock()
        let value = values[account]
        lock.unlock()
        return value
    }

    public func delete(for account: String) throws {
        lock.lock()
        values[account] = nil
        lock.unlock()
    }

    public var description: String {
        lock.lock()
        let count = values.count
        lock.unlock()
        return "MemorySecretStore(accounts: \(count))"
    }
}
