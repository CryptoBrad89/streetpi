import StreetPiCore

struct GalleryRoom: Identifiable {
    var id: String
    var title: String
    var detail: String
    var word: String
    var symbol: String
    var tone: PlainEnglishStatus.Tone
    var prominent: Bool
}
