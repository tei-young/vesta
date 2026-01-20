//
//  VestaApp.swift
//  Vesta
//
//  Created on 2026-01-19.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct VestaApp: App {
    // MARK: - Properties

    @StateObject private var authService = AuthService()

    // MARK: - Initialization

    init() {
        // Firebase 초기화
        FirebaseApp.configure()
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
