//
//  ExpenseRow.swift
//  Vesta
//
//  Created on 2026-01-25.
//

import SwiftUI

struct ExpenseRow: View {
    // MARK: - Properties

    let category: ExpenseCategory
    let amount: Int
    let onEdit: () -> Void           // 금액 입력
    let onEditCategory: () -> Void   // 카테고리 수정
    let onDelete: () -> Void         // 카테고리 삭제

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            // 이모지 아이콘
            Text(category.icon ?? "📋")
                .font(.title2)
                .frame(width: 40, height: 40)

            // 카테고리명
            Text(category.name)
                .font(.subheadline)
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            // 금액 (탭하여 수정)
            Button(action: onEdit) {
                HStack(spacing: 4) {
                    if amount > 0 {
                        Text(amount.formattedCurrency)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.textPrimary)
                    } else {
                        Text("입력")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textTertiary)
                    }

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColors.textTertiary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppColors.background)
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())

            // 수정/삭제 버튼
            Menu {
                Button(action: onEditCategory) {
                    Label("카테고리 수정", systemImage: "pencil")
                }

                Button(role: .destructive, action: onDelete) {
                    Label("카테고리 삭제", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 32, height: 32)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        ExpenseRow(
            category: ExpenseCategory(
                name: "재료비",
                icon: "💇",
                order: 0
            ),
            amount: 500000,
            onEdit: {},
            onEditCategory: {},
            onDelete: {}
        )

        ExpenseRow(
            category: ExpenseCategory(
                name: "임대료",
                icon: "🏠",
                order: 1
            ),
            amount: 0,
            onEdit: {},
            onEditCategory: {},
            onDelete: {}
        )
    }
    .padding()
}
