import Foundation

public struct PiholeCertificate: Sendable, Equatable {
    public var host: String
    public var commonName: String
    public var notAfter: Date
    public var sha256Fingerprint: String

    public init(host: String, commonName: String, notAfter: Date, sha256Fingerprint: String) {
        self.host = host
        self.commonName = commonName
        self.notAfter = notAfter
        self.sha256Fingerprint = sha256Fingerprint
    }
}

public enum PiholeTrustDecision: Sendable, Equatable {
    case trusted
    case needsConsent(String)
    case rejected(String)
}

public enum PiholeTrust {
    public static let commonName = "pi.hole"

    public static func decide(
        presented: PiholeCertificate,
        pinnedFingerprint: String?,
        forHost host: String
    ) -> PiholeTrustDecision {
        guard presented.host == host else {
            return .rejected("This certificate is for a different machine.")
        }
        guard presented.commonName == commonName else {
            return .rejected("This certificate is not the one named pi.hole.")
        }
        guard year(of: presented.notAfter) == 2_055 else {
            return .rejected("This certificate is not the one that lasts until 2055.")
        }
        if let pinnedFingerprint {
            guard pinnedFingerprint == presented.sha256Fingerprint else {
                return .rejected("This is not the Pi this phone already trusts.")
            }
            return .trusted
        }
        return .needsConsent(explanation(for: presented))
    }

    public static func explanation(for certificate: PiholeCertificate) -> String {
        """
        This Pi uses its own certificate, named pi.hole, good until 2055. \
        Trust it on this phone only. \(certificate.sha256Fingerprint)
        """
    }

    private static func year(of date: Date) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        if let zone = TimeZone(secondsFromGMT: 0) {
            calendar.timeZone = zone
        }
        return calendar.component(.year, from: date)
    }
}

extension PiholeCertificate {
    public static let houseFixture: PiholeCertificate = {
        var calendar = Calendar(identifier: .gregorian)
        if let zone = TimeZone(secondsFromGMT: 0) {
            calendar.timeZone = zone
        }
        let parts = DateComponents(year: 2_055, month: 12, day: 31)
        let date = calendar.date(from: parts) ?? Date(timeIntervalSince1970: 2_713_824_000)
        return PiholeCertificate(
            host: PiholeEndpoint.house.host,
            commonName: PiholeTrust.commonName,
            notAfter: date,
            sha256Fingerprint: "SHA256:fixture-not-a-real-cert"
        )
    }()
}
