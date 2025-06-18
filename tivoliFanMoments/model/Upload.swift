enum UploadKind { case image, video }

struct Upload: Identifiable, Decodable {
    let id: Int                // pk_upload       →   “2”
    let momentId: Int          // fk_moment
    let ext: String            // typ             →   “png”, “jpg”, “mp4” …
    let description: String?   // beschreibung    (optional)
    let userId: Int            // fk_nutzer

    enum CodingKeys: String, CodingKey {
        case id          = "pk_upload"
        case momentId    = "fk_moment"
        case ext         = "typ"
        case description = "beschreibung"
        case userId      = "fk_nutzer"
    }

    /// Quick helper to decide which UI we show
    var kind: UploadKind {
        switch ext.lowercased() {
        case "mp4", "mov", "m4v": return .video
        default                : return .image
        }
    }
}
