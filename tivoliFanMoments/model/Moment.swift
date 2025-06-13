struct Moment: Decodable, Identifiable {
    let id: Int
    let minute: Int
    let art: String
    var uploadCount: Int = 0

    enum CodingKeys: String, CodingKey {
        case id = "pk_moment"
        case minute
        case art
    }
}

@MainActor
func loadUploadCount(for moment: Moment) async -> Int {
    do {
        let dbc = DatabaseConnector()
        let count = try await dbc.countUploadsPerMoment(momentId: moment.id)
        return count
    } catch {
        print("Error fetching upload count: \(error)")
        return 0
    }
}
