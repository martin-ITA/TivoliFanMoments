import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false

    var body: some View {
        if isLoggedIn {
            // ➡️ Wenn eingeloggt, MainView anzeigen
            MainView()
        } else {
            // ➡️ Login-Ansicht
            ZStack {
                Color.black
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Image("Aachen-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .padding(.bottom, 10)

                    Text("Login")
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

                    SecureField("", text: $password)
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

                    Button(action: {
                        // ➡️ Hier später deine Login-Logik
                        // Jetzt nur „eingeloggt“ umschalten:
                        isLoggedIn = true
                    }) {
                        Text("Einloggen")
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
}
