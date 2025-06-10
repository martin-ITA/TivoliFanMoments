import Foundation
import Combine
import Supabase
import SwiftUI

@MainActor
class BegegnungViewModel: ObservableObject {
    @Published var begegnungen: [Begegnung] = []
    @Published var errorMessage: String?

    private let db: DatabaseConnector

    init(dbConnector: DatabaseConnector = DatabaseConnector()) {
        self.db = dbConnector
        // Ladevorgang sofort beim Erstellen starten (z.B. mit Saison ID 1)
        Task {
            await load(saisonId: 1)
        }
    }

    func load(saisonId: Int) async {
        do {
            let fetched = try await db.fetchAllGames(saisonId: saisonId)
            self.begegnungen = fetched
        } catch {
            self.errorMessage = "Fehler beim Laden der Begegnungen: \(error.localizedDescription)"
        }
    }
}
