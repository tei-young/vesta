//
//  AuthService.swift
//  Vesta
//
//  Created on 2026-01-19.
//

import Foundation
import Combine
import FirebaseCore
import FirebaseAuth
import AuthenticationServices
import CryptoKit
import GoogleSignIn

@MainActor
class AuthService: ObservableObject {
    // MARK: - Published Properties

    @Published var currentUser: AppUser?
    @Published var isAuthenticated = false
    @Published var isLoading = true
    @Published var errorMessage: String?

    // MARK: - Private Properties

    private var authStateListener: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?

    // MARK: - Initialization

    init() {
        setupAuthStateListener()
    }

    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }

    // MARK: - Auth State Listener

    private func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }

            Task { @MainActor in
                self.isLoading = false

                if let user = user {
                    self.currentUser = AppUser(from: user)
                    self.isAuthenticated = true
                } else {
                    self.currentUser = nil
                    self.isAuthenticated = false
                }
            }
        }
    }

    // MARK: - Apple Sign In

    /// Apple Sign In을 위한 nonce 생성
    func generateNonce() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return nonce
    }

    /// Apple Sign In 처리
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        guard let nonce = currentNonce else {
            throw AuthError.invalidNonce
        }

        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            throw AuthError.invalidToken
        }

        let firebaseCredential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: tokenString,
            rawNonce: nonce
        )

        do {
            let result = try await Auth.auth().signIn(with: firebaseCredential)
            print("✅ Apple Sign In 성공: \(result.user.uid)")
        } catch {
            print("❌ Apple Sign In 실패: \(error.localizedDescription)")
            throw AuthError.signInFailed(error.localizedDescription)
        }
    }

    // MARK: - Google Sign In

    /// Google Sign In 처리
    func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.invalidToken
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw AuthError.signInFailed("Unable to get root view controller")
        }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let user = result.user

            guard let idToken = user.idToken?.tokenString else {
                throw AuthError.invalidToken
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            let authResult = try await Auth.auth().signIn(with: credential)
            print("✅ Google Sign In 성공: \(authResult.user.uid)")
        } catch {
            print("❌ Google Sign In 실패: \(error.localizedDescription)")
            throw AuthError.signInFailed(error.localizedDescription)
        }
    }

    // MARK: - Sign Out

    func signOut() throws {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            print("✅ 로그아웃 성공")
        } catch {
            print("❌ 로그아웃 실패: \(error.localizedDescription)")
            throw AuthError.signOutFailed(error.localizedDescription)
        }
    }

    // MARK: - Helper Methods

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case invalidNonce
    case invalidToken
    case signInFailed(String)
    case signOutFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidNonce:
            return "인증 처리 중 오류가 발생했습니다."
        case .invalidToken:
            return "유효하지 않은 인증 토큰입니다."
        case .signInFailed(let message):
            return "로그인 실패: \(message)"
        case .signOutFailed(let message):
            return "로그아웃 실패: \(message)"
        }
    }
}
