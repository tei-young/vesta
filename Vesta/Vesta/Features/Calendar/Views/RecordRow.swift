//
//  RecordRow.swift
//  Vesta
//
//  Created on 2026-01-22.
//

import SwiftUI

struct RecordRow: View {
    // MARK: - Properties

    let record: DailyRecord
    let treatment: Treatment?
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onDelete: () -> Void

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            // 색상 + 아이콘
            if let treatment = treatment {
                ZStack {
                    Circle()
                        .fill(Color(hex: treatment.color))
                        .frame(width: 40, height: 40)

                    if let icon = treatment.icon, !icon.isEmpty {
                        Text(icon)
                            .font(.title3)
                    }
                }
            }

            // 시술 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(treatment?.name ?? "알 수 없음")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)

                Text(record.totalAmount.formattedCurrency)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            // 수량 조절
            HStack(spacing: 8) {
                Button(action: onDecrement) {
                    Image(systemName: "minus.circle")
                        .foregroundColor(AppColors.textSecondary)
                        .font(.title3)
                }
                .buttonStyle(BorderlessButtonStyle())

                Text("\(record.count)")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(minWidth: 20)

                Button(action: onIncrement) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(AppColors.primary)
                        .font(.title3)
                }
                .buttonStyle(BorderlessButtonStyle())
            }

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
}

// MARK: - Preview

#Preview {
    RecordRow(
        record: DailyRecord(
            date: Date(),
            treatmentId: "1",
            count: 3,
            totalAmount: 150000,
            createdAt: Date()
        ),
        treatment: Treatment(
            name: "젤네일",
            price: 50000,
            icon: "💅",
            color: "#FFA0B9",
            order: 0,
            createdAt: Date(),
            updatedAt: Date()
        ),
        onIncrement: {},
        onDecrement: {},
        onDelete: {}
    )
    .padding()
}
