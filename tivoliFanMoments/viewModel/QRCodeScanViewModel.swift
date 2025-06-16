import Foundation
import SwiftUI

class QRScanViewModel: ObservableObject {
    @Published var foundGame: Begegnung? = nil
    @Published var showUpload = false
    @Published var errorMessage: String? = nil
    
    func handleScannedCode(_ code: String) {
        Task {
            do {
                if let game = try await DatabaseConnector().findGameByQRCode(code) {
                    DispatchQueue.main.async {
                        self.foundGame = game
                        self.showUpload = true
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Kein Spiel mit diesem QR-Code gefunden."
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Fehler beim Abrufen des Spiels: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func lookup(_ code: String, completion: @escaping (Begegnung?) -> Void) {
        Task {
            print("🔎 Looking up code: \(code)")
            do {
                if let game = try await DatabaseConnector().findGameByQRCode(code) {
                    try await DatabaseConnector().recordVisit(begegnungId: game.id)
                    DispatchQueue.main.async {
                        self.errorMessage = nil
                        print("✅ Game found for code \(code)")
                        completion(game)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Kein Spiel mit diesem QR-Code gefunden."
                        print("❌ No game for code \(code)")
                        completion(nil)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Fehler: \(error.localizedDescription)"
                    print("❌ Lookup failed for code \(code): \(error)")
                    completion(nil)
                }
            }
        }
    }

}
