//
//  ProfitCard.swift
//  Vesta
//
//  Created on 2026-01-25.
//

import SwiftUI

struct ProfitCard: View {
    // MARK: - Properties

    let totalRevenue: Int
    let totalExpense: Int
    let netProfit: Int

    // MARK: - Computed Properties

    var isProfit: Bool {
        netProfit >= 0
    }

    var profitColor: Color {
        if netProfit > 0 {
            return Color(hex: "#4ECDC4")  // 청록색 (흑자)
        } else if netProfit < 0 {
            return Color(hex: "#FF6B6B")  // 빨간색 (적자)
        } else {
            return AppColors.textSecondary  // 회색 (손익 0)
        }
    }

    var profitIcon: String {
        if netProfit > 0 {
            return "arrow.up.circle.fill"
        } else if netProfit < 0 {
            return "arrow.down.circle.fill"
        } else {
            return "minus.circle.fill"
        }
    }

    var profitLabel: String {
        if netProfit > 0 {
            return "흑자"
        } else if netProfit < 0 {
            return "적자"
        } else {
            return "손익 0"
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 헤더: 순이익 제목
            Text("순이익")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)

            // 매출 - 지출 = 순이익 구조
            VStack(spacing: 12) {
                // 매출
                HStack {
                    Text("매출")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)

                    Spacer()

                    Text(totalRevenue.formattedCurrency)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textPrimary)
                }

                // 지출
                HStack {
                    Text("지출")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)

                    Spacer()

                    Text("- \(totalExpense.formattedCurrency)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textPrimary)
                }

                Divider()
                    .background(AppColors.divider)

                // 순이익 (강조)
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: profitIcon)
                            .foregroundColor(profitColor)
                            .font(.title3)

                        Text(profitLabel)
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)
                    }

                    Spacer()

                    Text(abs(netProfit).formattedCurrency)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(profitColor)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(AppColors.card)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        // 흑자 케이스
        ProfitCard(
            totalRevenue: 5000000,
            totalExpense: 3000000,
            netProfit: 2000000
        )

        // 적자 케이스
        ProfitCard(
            totalRevenue: 2000000,
            totalExpense: 3500000,
            netProfit: -1500000
        )

        // 손익 0 케이스
        ProfitCard(
            totalRevenue: 2500000,
            totalExpense: 2500000,
            netProfit: 0
        )
    }
    .padding()
}
