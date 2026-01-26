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

            // 시술별 매출 리스트
            if revenueByTreatment.isEmpty {
                // 빈 상태
                Text("시술 기록이 없습니다")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 12) {
                    ForEach(revenueByTreatment, id: \.treatmentId) { item in
                        TreatmentRevenueRow(
                            name: item.name,
                            color: item.color,
                            amount: item.amount
                        )
                    }
                }
            }
        }
        .padding()
        .background(AppColors.card)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Treatment Revenue Row

private struct TreatmentRevenueRow: View {
    let name: String
    let color: String
    let amount: Int

    var body: some View {
        HStack(spacing: 12) {
            // 시술 색상 원형
            Circle()
                .fill(Color(hex: color))
                .frame(width: 12, height: 12)

            // 시술명
            Text(name)
                .font(.subheadline)
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            // 금액
            Text(amount.formattedCurrency)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppColors.textSecondary)
        }
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
