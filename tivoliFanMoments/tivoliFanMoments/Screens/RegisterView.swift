import SwiftUI

struct RegisterView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var username: String = ""
    
    @Environment(\ .dismiss) private var dismiss
    
    @State private var errorMessage: String? = nil
    @State private var showError: Bool = false
    
    private var client = ServiceLocator.shared.databaseConnector.current
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image("Aachen_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.bottom, 10)
                
                VStack(spacing: 20) {
                    Text("Registrieren")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                    
                    TextField("E-Mail", text: $email, prompt: Text("E-Mail").foregroundColor(.yellow))
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.yellow)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.yellow, lineWidth: 1)
                        )
                    
                    TextField("Benutzername", text: $username, prompt: Text("Benutzername").foregroundColor(.yellow))
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.yellow)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.yellow, lineWidth: 1)
                        )
                    
                    SecureField("Passwort", text: $password, prompt: Text("Passwort").foregroundColor(.yellow))
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.yellow)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.yellow, lineWidth: 1)
                        )
                    
                    SecureField("Passwort bestätigen", text: $confirmPassword, prompt: Text("Passwort bestätigen").foregroundColor(.yellow))
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.yellow)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.yellow, lineWidth: 1)
                        )
                    
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
                .tint(.yellow)
            }
        }
    }
}
