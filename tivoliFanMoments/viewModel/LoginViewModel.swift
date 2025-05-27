//
//  LoginViewModel.swift
//  tivoliFanMoments
//
//  Created by Kili on 26.05.25.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var showRegisterView: Bool = false

    func navigateToRegister() {
        showRegisterView = true
    }
}
