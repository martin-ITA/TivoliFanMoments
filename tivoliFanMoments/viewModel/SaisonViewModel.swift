import Foundation

/// ViewModel, das die Saison-Daten via Supabase lädt und publiziert
final class SaisonViewModel: ObservableObject {
    @Published var saisons: [Saison] = []
    @Published var errorMessage: String? = nil

    private let db: DatabaseConnector

    init(dbConnector: DatabaseConnector = DatabaseConnector()) {
        self.db = dbConnector
        Task { await loadSaisons() }
        // sobald die VM initialisiert wird, starten wir den Ladevorgang
    }

    /// Lädt die Saisons asynchron und schreibt sie in `saisons`
    func loadSaisons() async {
        do {
            let fetched = try await db.fetchAllSaisons()
            // Supabase gibt leer zurück, falls keine Datensätze existieren,
            // dann ist fetched == []
            await MainActor.run {
                self.saisons = fetched
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Fehler beim Laden der Saisons: \(error.localizedDescription)"
            }
        }
    }
}
