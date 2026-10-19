import Foundation

public struct PlainEnglishStatus: Sendable, Equatable {
    public enum Tone: String, Sendable, Equatable, Codable {
        case calm
        case attention
        case problem
    }

    public var headline: String
    public var detail: String?
    public var tone: Tone
    public var linkLine: String

    public init(headline: String, detail: String?, tone: Tone, linkLine: String) {
        self.headline = headline
        self.detail = detail
        self.tone = tone
        self.linkLine = linkLine
    }
}

public enum StatusNarrator {
    public static func narrate(_ snapshot: HouseholdSnapshot, now: Date) -> PlainEnglishStatus {
        let notes = findings(in: snapshot).sorted { $0.rank < $1.rank }
        let headline: String
        var tone: PlainEnglishStatus.Tone
        if let primary = notes.first {
            headline = primary.headline
            tone = primary.tone
        } else {
            headline = "Everything's good."
            tone = .calm
        }

        var parts: [String] = []
        if let away = awaySentence(snapshot, now: now) {
            parts.append(away)
        }
        if let primary = notes.first, let extra = primary.note {
            parts.append(extra)
        }
        for note in notes.dropFirst() {
            parts.append(note.note ?? note.headline)
        }

        let stale = CacheFreshness.isStale(snapshot, now: now)
        if stale {
            let age = AgePhrase.english(from: snapshot.referenceDate, to: now)
            let line = "This reading is from \(age) and may be out of date."
            if case .away = snapshot.link, !parts.isEmpty {
                parts[0] = "You're away from home. \(line)"
            } else {
                parts.append(line)
            }
            if tone == .calm {
                tone = .attention
            }
        }

        return PlainEnglishStatus(
            headline: headline,
            detail: parts.isEmpty ? nil : parts.joined(separator: " "),
            tone: tone,
            linkLine: linkLine(snapshot, now: now)
        )
    }

    private static func downHeadline(_ service: ServiceHealth) -> String {
        if service.kind == .dnsFilter {
            return "The ad blocker is down."
        }
        return "\(service.name) is down."
    }

    private struct Finding {
        var rank: Int
        var tone: PlainEnglishStatus.Tone
        var headline: String
        var note: String?
    }

    private static func findings(in snapshot: HouseholdSnapshot) -> [Finding] {
        var notes: [Finding] = []
        let down = snapshot.services.filter { $0.state == .notResponding }
        let degraded = snapshot.services.filter { $0.state == .degraded }

        if down.count == 1, let only = down.first {
            notes.append(
                Finding(rank: 0, tone: .problem, headline: downHeadline(only), note: nil)
            )
        } else if down.count > 1 {
            notes.append(
                Finding(
                    rank: 0,
                    tone: .problem,
                    headline: "A few things at home need a look.",
                    note: "\(englishList(down.map(\.name))) are down."
                )
            )
        }

        if let temperature = snapshot.machine?.temperatureCelsius, temperature >= MachineLimits.hotCelsius {
            notes.append(Finding(rank: 1, tone: .problem, headline: "The Pi is too hot.", note: nil))
        }

        if degraded.count == 1, let only = degraded.first {
            notes.append(
                Finding(rank: 2, tone: .attention, headline: "\(only.name) is having trouble.", note: nil)
            )
        } else if degraded.count > 1 {
            notes.append(
                Finding(
                    rank: 2,
                    tone: .attention,
                    headline: "A few things at home need a look.",
                    note: "\(englishList(degraded.map(\.name))) are having trouble."
                )
            )
        }

        if let temperature = snapshot.machine?.temperatureCelsius,
           temperature >= MachineLimits.warmCelsius,
           temperature < MachineLimits.hotCelsius {
            notes.append(
                Finding(rank: 3, tone: .attention, headline: "The Pi is warmer than usual.", note: nil)
            )
        }

        if let disk = snapshot.machine?.diskUsedFraction, disk >= MachineLimits.diskAttention {
            notes.append(
                Finding(rank: 4, tone: .attention, headline: "The Pi's disk is almost full.", note: nil)
            )
        }

        if let memory = snapshot.machine?.memoryUsedFraction, memory >= MachineLimits.memoryAttention {
            notes.append(
                Finding(rank: 5, tone: .attention, headline: "The Pi is low on memory.", note: nil)
            )
        }

        if snapshot.dns?.blockingEnabled == false {
            notes.append(Finding(rank: 6, tone: .attention, headline: "Ad blocking is paused.", note: nil))
        }

        return notes
    }

    private static func awaySentence(_ snapshot: HouseholdSnapshot, now: Date) -> String? {
        guard case .away(let cachedAt) = snapshot.link else {
            return nil
        }
        let age = AgePhrase.english(from: cachedAt, to: now)
        return "You're away from home. This reading is from \(age)."
    }

    private static func linkLine(_ snapshot: HouseholdSnapshot, now: Date) -> String {
        switch snapshot.link {
        case .homeNetwork:
            return "On the home network"
        case .away(let cachedAt):
            return "Away · \(AgePhrase.english(from: cachedAt, to: now))"
        }
    }

    private static func englishList(_ names: [String]) -> String {
        switch names.count {
        case 0:
            return ""
        case 1:
            return names[0]
        case 2:
            return "\(names[0]) and \(names[1])"
        default:
            let head = names.dropLast().joined(separator: ", ")
            let last = names[names.count - 1]
            return "\(head), and \(last)"
        }
    }
}
