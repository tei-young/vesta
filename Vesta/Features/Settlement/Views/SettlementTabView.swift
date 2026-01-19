//
//  SettlementTabView.swift
//  Vesta
//
//  Created on 2026-01-19.
//

import SwiftUI

struct SettlementTabView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("📊")
                    .font(.system(size: 60))

                Text("결산 탭")
                    .font(.title)
                    .foregroundColor(AppColors.textPrimary)

                Text("곧 구현될 예정입니다")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }
            .navigationTitle("결산")
        }
    }
}

#Preview {
    SettlementTabView()
}
