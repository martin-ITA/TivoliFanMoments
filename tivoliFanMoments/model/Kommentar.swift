struct Kommentar: Identifiable, Decodable {
    let id: Int
    let userId: Int
    let uploadId: Int
    let inhalt: String
    var username: String? = nil

    enum CodingKeys: String, CodingKey {
        case id = "pk_kommentar"
        case userId = "fk_nutzer"
        case uploadId = "fk_upload"
        case inhalt
    }
}
