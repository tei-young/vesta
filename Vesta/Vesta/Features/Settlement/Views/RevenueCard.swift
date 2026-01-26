//
//  RevenueCard.swift
//  Vesta
//
//  Created on 2026-01-25.
//

import SwiftUI

struct RevenueCard: View {
    // MARK: - Properties

    let totalRevenue: Int
    let revenueByTreatment: [(treatmentId: String, name: String, color: String, amount: Int)]

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 헤더: 매출 제목
            Text("매출")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)

            // 총 매출
            HStack {
                Text("총 매출")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)

                Spacer()

                Text(totalRevenue.formattedCurrency)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primary)
            }

            Divider()
                .background(AppColors.divider)

            // TODO: 시술별 매출 리스트 (다음 단계에서 구현)
        }
        .padding()
        .background(AppColors.card)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    RevenueCard(
        totalRevenue: 2500000,
        revenueByTreatment: [
            ("1", "펌", "#FF6B6B", 1200000),
            ("2", "염색", "#4ECDC4", 800000),
            ("3", "커트", "#95E1D3", 500000)
        ]
    )
    .padding()
}
