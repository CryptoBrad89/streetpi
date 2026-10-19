import Foundation

/// Short spoken lines for the household design direction. Facts only, no invented counts.
public enum HouseholdVoice {
    public static func porchLines(_ snapshot: HouseholdSnapshot) -> [String] {
        var lines: [String] = []
        let down = snapshot.services.filter { $0.state == .notResponding }

        if let first = down.first {
            lines.append("\(first.name) is not responding.")
        } else if let dns = snapshot.dns {
            lines.append(dns.blockingEnabled ? "Ads are being blocked." : "Ad blocking is paused.")
        }

        if let temperature = snapshot.machine?.temperatureCelsius {
            if temperature >= MachineLimits.hotCelsius {
                lines.append("The Pi is too hot.")
            } else if temperature >= MachineLimits.warmCelsius {
                lines.append("The Pi is warmer than usual.")
            } else {
                lines.append("The Pi is cool and quiet.")
            }
        }

        if let home = snapshot.services.first(where: { $0.kind == .homeAutomation }) {
            switch home.state {
            case .responding:
                lines.append("\(home.name) is up.")
            case .notResponding:
                break
            case .degraded:
                lines.append("\(home.name) is having trouble.")
            case .maintenance:
                lines.append("\(home.name) is paused for maintenance.")
            case .unknown:
                break
            }
        }

        if lines.isEmpty {
            lines.append("Nothing new to report.")
        }
        return Array(lines.prefix(3))
    }
}
