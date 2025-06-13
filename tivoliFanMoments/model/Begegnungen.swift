struct Mannschaft: Decodable, Identifiable, Hashable {
    let id: Int
    let name: String

    enum CodingKeys: String, CodingKey {
        case id = "pk_mannschaft"
        case name
    }
}

struct Begegnung: Decodable, Identifiable, Hashable {
    let id: Int
    let spieltag: Int
    let heimTore: Int?
    let gastTore: Int?
    let heim: Mannschaft
    let gast: Mannschaft
    let qr_code: String?

    enum CodingKeys: String, CodingKey {
        case id = "pk_begegnung"
        case spieltag
        case heimTore = "heim_tore"
        case gastTore = "gast_tore"
        case heim = "fk_mannschaft_heim"
        case gast = "fk_mannschaft_gast"
        case qr_code = "qr_code"
    }
}
