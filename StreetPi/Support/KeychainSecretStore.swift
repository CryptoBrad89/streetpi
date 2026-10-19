import Foundation
import Security
import StreetPiCore
import SwiftUI

struct KeychainSecretStore: SecretStoring, Sendable {
    private let service = "com.streetfam.streetpi.secrets"

    func save(_ secret: Data, for account: String) throws {
        let query = baseQuery(account: account)
        SecItemDelete(query as CFDictionary)
        var insert = query
        insert[kSecValueData as String] = secret
        insert[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        let status = SecItemAdd(insert as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw SecretStoreError.failed
        }
    }

    func load(for account: String) throws -> Data? {
        var query = baseQuery(account: account)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess else {
            throw SecretStoreError.failed
        }
        return item as? Data
    }

    func delete(for account: String) throws {
        let status = SecItemDelete(baseQuery(account: account) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecretStoreError.failed
        }
    }

    private func baseQuery(account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }
}

private struct SecretStoreKey: EnvironmentKey {
    static let defaultValue: any SecretStoring = KeychainSecretStore()
}

extension EnvironmentValues {
    var secretStore: any SecretStoring {
        get { self[SecretStoreKey.self] }
        set { self[SecretStoreKey.self] = newValue }
    }
}
