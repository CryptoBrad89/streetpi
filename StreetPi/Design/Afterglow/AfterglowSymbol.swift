import StreetPiCore

enum AfterglowSymbol {
    static func status(_ tone: PlainEnglishStatus.Tone) -> String {
        switch tone {
        case .calm:
            "checkmark.circle.fill"
        case .attention:
            "exclamationmark.circle.fill"
        case .problem:
            "xmark.circle.fill"
        }
    }
}
