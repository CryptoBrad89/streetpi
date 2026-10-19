import Foundation

public enum AppPassword {
    /// Keychain account for the Pi-hole app password. The password itself is never stored here.
    public static let account = "pihole.app-password"
    /// SHA-256 pin for the Pi's certificate. Not a password.
    public static let certificatePin = "pihole.certificate-pin"
}

/// Wire shape for `POST /api/auth`. Description and mirrors never include the password.
public struct AuthRequest: Codable, Equatable, Sendable, CustomStringConvertible {
    public var password: String

    public init(password: String) {
        self.password = password
    }

    public var description: String {
        "AuthRequest(password: redacted)"
    }
}
