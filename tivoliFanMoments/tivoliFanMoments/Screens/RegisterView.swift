import SwiftUI

struct RegisterView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var username: String = ""

    @Environment(\.dismiss) private var dismiss

    @State private var errorMessage: String? = nil
    @State private var showError: Bool = false

    private var client = ServiceLocator.shared.databaseConnector.current

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Registrieren")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)

                TextField("", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.yellow)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.yellow, lineWidth: 1))
                    .placeholder(when: email.isEmpty) {
                        Text("E-Mail")
                            .foregroundColor(.yellow.opacity(0.7))
                            .padding(.leading, 8)
                    }

                TextField("", text: $username)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.yellow)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.yellow, lineWidth: 1))
                    .placeholder(when: username.isEmpty) {
                        Text("Benutzername")
                            .foregroundColor(.yellow.opacity(0.7))
                            .padding(.leading, 8)
                    }

                SecureField("", text: $password)
                    .textContentType(.newPassword)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.yellow)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.yellow, lineWidth: 1))
                    .placeholder(when: password.isEmpty) {
                        Text("Passwort")
                            .foregroundColor(.yellow.opacity(0.7))
                            .padding(.leading, 8)
                    }

                SecureField("", text: $confirmPassword)
                    .textContentType(.newPassword)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.yellow)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.yellow, lineWidth: 1))
                    .placeholder(when: confirmPassword.isEmpty) {
                        Text("Passwort bestätigen")
                            .foregroundColor(.yellow.opacity(0.7))
                            .padding(.leading, 8)
                    }

                if showError, let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                Button(action: {
                    print("▶️ Register button tapped")
                    Task {
                        guard password == confirmPassword else {
                            print("❌ Passwords don't match")
                            errorMessage = "Passwörter stimmen nicht überein."
                            showError = true
                            return
                        }

                        let newUser = [
                            "nutzername": username,
                            "email": email,
                            "passwort": password
                        ]

                        do {
                            print("📤 Inserting into tbl_nutzer: \(newUser)")
                            let result = try await client
                                .from("tbl_nutzer")
                                .insert([newUser])
                                .execute()
                            print("✅ Inserted: \(result)")

                            dismiss()
                        } catch {
                            print("❌ Failed to register user: \(error)")
                            errorMessage = "Registrierung fehlgeschlagen: \(error.localizedDescription)"
                            showError = true
                        }
                    }
                }) {
                    Text("Registrieren")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .cornerRadius(10)
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 30)
        }
    }
}
