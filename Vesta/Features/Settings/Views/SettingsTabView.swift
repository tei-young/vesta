//
//  SettingsTabView.swift
//  Vesta
//
//  Created on 2026-01-19.
//

import SwiftUI

struct SettingsTabView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        NavigationView {
            VStack {
                Text("⚙️")
                    .font(.system(size: 60))

                Text("설정 탭")
                    .font(.title)
                    .foregroundColor(AppColors.textPrimary)

                Text("곧 구현될 예정입니다")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.bottom, AppConstants.Spacing.l)

                // 로그아웃 버튼 (테스트용)
                Button {
                    try? authService.signOut()
                } label: {
                    Text("로그아웃")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("설정")
        }
    }
}

#Preview {
    SettingsTabView()
        .environmentObject(AuthService())
}
