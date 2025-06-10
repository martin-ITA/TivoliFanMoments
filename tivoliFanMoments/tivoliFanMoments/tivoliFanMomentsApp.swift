//
//  tivoliFanMomentsApp.swift
//  tivoliFanMoments
//
//  Created by Bofur on 25.04.25.
//

import SwiftUI

@main
struct tivoliFanMomentsApp: App {
    @StateObject private var session = SessionManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environmentObject(session)
    }
}
