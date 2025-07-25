import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false

    @State private var errorMessage: String? = nil
    @State private var showError: Bool = false

    @State private var connectorVM = DatabaseConnectorViewModel()

    var body: some View {
        NavigationStack {
            if isLoggedIn {
                MainView()
            } else {
                ZStack {
                    Color.black.ignoresSafeArea()

                    VStack(spacing: 20) {
                        Image("Aachen_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .padding(.bottom, 10)

                        Text("Login")
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

                        SecureField("Passwort", text: $password, prompt: Text("Passwort").foregroundColor(.yellow))
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
                            connectorVM.signIn(email: email, password: password)
                        }) {
                            Text("Einloggen")
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.yellow)
                                .cornerRadius(10)
                        }
                        
                        Text("Noch kein Konto?")
                            .foregroundColor(.yellow)
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        NavigationLink(destination: RegisterView()) {
                            Text("Registrieren")
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.yellow)
                                .cornerRadius(10)
                        }
                        .padding(.top, 0)
                    }
                    .padding(.horizontal, 30)
                    .onChange(of: connectorVM.isAuthenticated) {
                        if connectorVM.isAuthenticated {
                            isLoggedIn = true
                        } else {
                            showError = true
                            errorMessage = "Login fehlgeschlagen"
                        }
                    }
                }
            }
        }
    }
}
