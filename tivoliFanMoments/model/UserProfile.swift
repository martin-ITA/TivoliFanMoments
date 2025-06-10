import Foundation

struct UserProfile: Codable, Hashable {
    let id: Int            // ← same type the DB stores
    let email: String
    var displayname: String

    enum CodingKeys: String, CodingKey {
        case id          = "pk_nutzer"
        case email
        case displayname = "nutzername"
    }
}
