import Foundation

struct Saison: Identifiable, Decodable, Equatable {
    let id: Int                 // entspricht tbl_saison.pk_saison
    let bezeichnung: String     // entspricht tbl_saison.bezeichnung

    // CodingKeys weisen dem JSON-Key "pk_saison" unser Property "id" zu
    enum CodingKeys: String, CodingKey {
        case id             = "pk_saison"
        case bezeichnung
    }
    
    static func == (lhs: Saison, rhs: Saison) -> Bool {
        lhs.id == rhs.id
    }
}
