//
//  RegisterView.swift
//  tivoliFanMoments
//
//  Created by Kili on 26.05.25.
//

import SwiftUI

struct RegisterView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

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


                SecureField("", text: $confirmPassword)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.yellow)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.yellow, lineWidth: 1))
                    .placeholder(when: password.isEmpty) {
                        Text("Passwort bestätigen")
                            .foregroundColor(.yellow.opacity(0.7))
                            .padding(.leading, 8)
                    }


                Button(action: {
                    // Registrierung verarbeiten
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

#Preview {
    RegisterView()
}
