//
//  AdjustmentRow.swift
//  Vesta
//
//  Created on 2026-01-22.
//

import SwiftUI

struct AdjustmentRow: View {
    // MARK: - Properties

    let adjustment: DailyAdjustment
    let onDelete: () -> Void

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            // 아이콘
            ZStack {
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 40, height: 40)

                Image(systemName: iconName)
                    .foregroundColor(.white)
                    .font(.body)
            }

            // 조정 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(adjustment.amount < 0 ? "할인" : "추가 금액")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)

                if let reason = adjustment.reason, !reason.isEmpty {
                    Text(reason)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            Spacer()

            // 금액
            Text(adjustment.amount.formattedCurrency)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(adjustment.amount < 0 ? .red : .green)

            // 삭제 버튼
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.body)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical, 8)
    }

    // MARK: - Computed Properties

    private var iconName: String {
        adjustment.amount < 0 ? "minus" : "plus"
    }

    private var iconBackgroundColor: Color {
        adjustment.amount < 0 ? .red : .green
    }
}

// MARK: - Preview

#Preview {
    VStack {
        AdjustmentRow(
            adjustment: DailyAdjustment(
                date: Date(),
                amount: -5000,
                reason: "단골 할인",
                createdAt: Date()
            ),
            onDelete: {}
        )

        AdjustmentRow(
            adjustment: DailyAdjustment(
                date: Date(),
                amount: 10000,
                reason: "팁",
                createdAt: Date()
            ),
            onDelete: {}
        )
    }
    .padding()
}
