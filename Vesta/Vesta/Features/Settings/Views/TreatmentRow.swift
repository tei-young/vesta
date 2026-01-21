//
//  TreatmentRow.swift
//  Vesta
//
//  Created on 2026-01-22.
//

import SwiftUI

struct TreatmentRow: View {
    // MARK: - Properties

    let treatment: Treatment
    let onEdit: () -> Void
    let onDelete: () -> Void

    // MARK: - Body

    var body: some View {
        HStack(spacing: 16) {
            // 색상 + 아이콘
            ZStack {
                Circle()
                    .fill(Color(hex: treatment.color))
                    .frame(width: 50, height: 50)

                if let icon = treatment.icon, !icon.isEmpty {
                    Text(icon)
                        .font(.title2)
                }
            }

            // 시술 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(treatment.name)
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)

                Text(treatment.price.formattedCurrency)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            // 수정/삭제 버튼
            HStack(spacing: 12) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(AppColors.primary)
                        .font(.title3)
                }

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.title3)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

#Preview {
    TreatmentRow(
        treatment: Treatment(
            name: "젤네일",
            price: 50000,
            icon: "💅",
            color: "#FFA0B9",
            order: 0,
            createdAt: Date(),
            updatedAt: Date()
        ),
        onEdit: {},
        onDelete: {}
    )
    .padding()
}
