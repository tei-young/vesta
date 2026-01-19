//
//  ContentView.swift
//  Vesta
//
//  Created on 2026-01-19.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties

    @EnvironmentObject var authService: AuthService

    // MARK: - Body

    var body: some View {
        Group {
            if authService.isLoading {
                // 로딩 화면
                LoadingView()
            } else if authService.isAuthenticated, let user = authService.currentUser {
                // 로그인 완료 -> 메인 앱
                MainTabView()
                    .environmentObject(authService)
            } else {
                // 미로그인 -> 로그인 화면
                LoginView()
                    .environmentObject(authService)
            }
        }
    }
}

// MARK: - Loading View

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)

                Text("Vesta")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primary)
            }
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    var body: some View {
        TabView {
            // Tab 1: 캘린더
            CalendarTabView()
                .tabItem {
                    Label("캘린더", systemImage: "calendar")
                }

            // Tab 2: 결산
            SettlementTabView()
                .tabItem {
                    Label("결산", systemImage: "chart.bar.fill")
                }

            // Tab 3: 설정
            SettingsTabView()
                .tabItem {
                    Label("설정", systemImage: "gearshape.fill")
                }
        }
        .tint(AppColors.primary)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(AuthService())
}
