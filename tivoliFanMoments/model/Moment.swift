struct Moment: Decodable, Identifiable {
    let id: Int
    let minute: Int
    let art: String
    var uploadCount: Int { 1 }

    enum CodingKeys: String, CodingKey {
        case id = "pk_moment"
        case minute
        case art
    }
}
