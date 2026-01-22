//
//  MonthHeaderView.swift
//  Vesta
//
//  Created on 2026-01-22.
//

import SwiftUI

struct MonthHeaderView: View {
    // MARK: - Properties

    let monthString: String
    let monthlyRevenue: Int
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onToday: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            // 월 네비게이션
            HStack {
                Button(action: onPrevious) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(AppColors.primary)
                }

                Spacer()

                Text(monthString)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Button(action: onNext) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundColor(AppColors.primary)
                }
            }
            .padding(.horizontal)

            // 월 총 매출
            HStack {
                Text("이달의 매출")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)

                Spacer()

                Text(monthlyRevenue.formattedCurrency)
                    .font(.headline)
                    .foregroundColor(AppColors.primary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(AppColors.background)
            .cornerRadius(8)
            .padding(.horizontal)

            // 요일 헤더
            HStack(spacing: 0) {
                ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

#Preview {
    MonthHeaderView(
        monthString: "2026년 1월",
        monthlyRevenue: 1500000,
        onPrevious: {},
        onNext: {},
        onToday: {}
    )
}
