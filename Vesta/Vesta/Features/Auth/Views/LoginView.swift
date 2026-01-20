//
//  LoginView.swift
//  Vesta
//
//  Created on 2026-01-19.
//

import SwiftUI
import AuthenticationServices
import CryptoKit

struct LoginView: View {
    // MARK: - Properties

    @EnvironmentObject var authService: AuthService
    @State private var isLoading = false
    @State private var errorMessage: String?

    // MARK: - Body

    var body: some View {
        ZStack {
            // 배경색
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: AppConstants.Spacing.xl) {
                Spacer()

                // 로고 & 타이틀
                VStack(spacing: AppConstants.Spacing.m) {
                    Text("💅")
                        .font(.system(size: 80))

                    Text("Vesta")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(AppColors.primary)

                    Text("뷰티샵 매출 관리 앱")
                        .font(.title3)
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                // 로그인 버튼들
                VStack(spacing: AppConstants.Spacing.m) {
                    // Google Sign In 버튼
                    Button(action: {
                        handleGoogleSignIn()
                    }) {
                        HStack {
                            Image(systemName: "g.circle.fill")
                                .font(.title2)
                            Text("Google로 계속하기")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .background(Color(red: 0.26, green: 0.52, blue: 0.96))
                        .cornerRadius(12)
                    }

                    // Apple Sign In 버튼
                    SignInWithAppleButton(
                        .signIn,
                        onRequest: { request in
                            let nonce = authService.generateNonce()
                            request.requestedScopes = [.email, .fullName]
                            request.nonce = sha256(nonce)
                        },
                        onCompletion: { result in
                            handleSignInWithApple(result: result)
                        }
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .cornerRadius(12)

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, AppConstants.Spacing.l)

                Spacer()
                    .frame(height: 100)
            }
            .padding()

            // 로딩 오버레이
            if isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            }
        }
    }

    // MARK: - Methods

    private func handleGoogleSignIn() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await authService.signInWithGoogle()
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }

    private func handleSignInWithApple(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                errorMessage = "인증 정보를 가져올 수 없습니다."
                return
            }

            isLoading = true
            errorMessage = nil

            Task {
                do {
                    try await authService.signInWithApple(credential: credential)
                    isLoading = false
                } catch {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }

        case .failure(let error):
            let authError = error as NSError
            // 사용자가 취소한 경우는 에러 메시지 표시 안함
            if authError.code != ASAuthorizationError.canceled.rawValue {
                errorMessage = "로그인 실패: \(error.localizedDescription)"
            }
        }
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

// MARK: - Preview

#Preview {
    LoginView()
        .environmentObject(AuthService())
}
