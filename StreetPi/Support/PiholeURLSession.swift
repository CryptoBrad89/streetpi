import CryptoKit
import Foundation
import Security
import StreetPiCore

/// Live transport for the house Pi. Sockets stay off, so `send` never dials.
struct PiholeURLSessionTransport: PiholeTransport {
    var pinnedFingerprint: String?

    func send(_ request: PiholeRequest) async throws -> PiholeResponse {
        guard PiholeLiveLink.socketsEnabled else {
            throw PiholeProblem.offline
        }
        guard let url = PiholeEndpoint.house.url(pathAndQuery: request.path) else {
            throw PiholeProblem.notUnderstood
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method
        urlRequest.httpBody = request.body
        for (field, value) in request.headers {
            urlRequest.setValue(value, forHTTPHeaderField: field)
        }
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        let delegate = PiholeTrustDelegate(pinnedFingerprint: pinnedFingerprint)
        let session = URLSession(configuration: .ephemeral, delegate: delegate, delegateQueue: nil)
        defer { session.finishTasksAndInvalidate() }
        do {
            let (data, response) = try await session.data(for: urlRequest)
            let status = (response as? HTTPURLResponse)?.statusCode ?? 0
            return PiholeResponse(status: status, body: data)
        } catch let problem as PiholeProblem {
            throw problem
        } catch {
            throw PiholeProblem.offline
        }
    }
}

final class DNSSessionHold {
    var client: PiholeClient?
}

private final class PiholeTrustDelegate: NSObject, URLSessionDelegate, @unchecked Sendable {
    var pinnedFingerprint: String?

    init(pinnedFingerprint: String?) {
        self.pinnedFingerprint = pinnedFingerprint
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        let space = challenge.protectionSpace
        guard space.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              space.host == PiholeEndpoint.house.host,
              let trust = space.serverTrust,
              let presented = Self.certificate(from: trust)
        else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        switch PiholeTrust.decide(
            presented: presented,
            pinnedFingerprint: pinnedFingerprint,
            forHost: PiholeEndpoint.house.host
        ) {
        case .trusted:
            completionHandler(.useCredential, URLCredential(trust: trust))
        case .needsConsent, .rejected:
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

    private static func certificate(from trust: SecTrust) -> PiholeCertificate? {
        guard let chain = SecTrustCopyCertificateChain(trust) as? [SecCertificate],
              let leaf = chain.first
        else { return nil }
        let data = SecCertificateCopyData(leaf) as Data
        let digest = SHA256.hash(data: data)
        let hex = digest.map { String(format: "%02x", $0) }.joined()
        let summary = (SecCertificateCopySubjectSummary(leaf) as String?) ?? ""
        let name = summary == PiholeTrust.commonName ? summary : ""
        return PiholeCertificate(
            host: PiholeEndpoint.house.host,
            commonName: name,
            notAfter: CertificateValidity.notAfter(der: data) ?? Date(timeIntervalSince1970: 0),
            sha256Fingerprint: "SHA256:\(hex)"
        )
    }
}
