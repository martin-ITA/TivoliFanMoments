import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var session: SessionManager
    @State private var oldPassword: String = ""
    @State private var newPassword: String = ""
    @State private var matchesCount: Int = 0
    @State private var uploadCount: Int = 0
    @State private var info: String? = nil

    private let db = DatabaseConnector()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let user = session.currentUser {
                    Text("Benutzername: \(user.displayname)")
                        .foregroundColor(.yellow)
                    Text("E-Mail: \(user.email)")
                        .foregroundColor(.yellow)
                }

                Divider().background(Color.yellow)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Statistiken")
                        .font(.headline)
                        .foregroundColor(.yellow)
                    Text("Du hast \(matchesCount) Spiel/e besucht.")
                        .foregroundColor(.yellow)
                    Text("Du hast \(uploadCount) Medien hochgeladen.")
                        .foregroundColor(.yellow)
                }

                Divider().background(Color.yellow)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Passwort ändern")
                        .font(.headline)
                        .foregroundColor(.yellow)
                    SecureField("Altes Passwort", text: $oldPassword, prompt: Text("Altes Passwort").foregroundColor(.yellow))
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.yellow)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.yellow))
                    SecureField("Neues Passwort", text: $newPassword, prompt: Text("Neues Passwort").foregroundColor(.yellow))
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.yellow)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.yellow))
                    if let info { Text(info).foregroundColor(.red) }
                    Button("Speichern") {
                        Task {
                            do {
                                try await db.changePassword(old: oldPassword, new: newPassword)
                                info = "Passwort geändert"
                            } catch {
                                info = "Änderung fehlgeschlagen"
                            }
                        }
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow)
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            Task {
                if let user = session.currentUser {
                    matchesCount = (try? await db.countVisitedMatches(userId: user.id)) ?? 0
                    uploadCount = (try? await db.countUploads(userId: user.id)) ?? 0
                }
            }
        }
    }
}
