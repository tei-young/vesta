//
//  ExpenseSection.swift
//  Vesta
//
//  Created on 2026-01-25.
//

import SwiftUI

struct ExpenseSection: View {
    // MARK: - Properties

    let categories: [ExpenseCategory]
    let getExpenseAmount: (String) -> Int  // categoryId -> amount
    let totalExpense: Int
    let onAddCategory: () -> Void
    let onCopyFromPrevious: () -> Void
    let onEditCategory: (ExpenseCategory) -> Void
    let onDeleteCategory: (ExpenseCategory) -> Void
    let onEditExpense: (ExpenseCategory) -> Void

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 헤더: 지출 제목 + 카테고리 추가 버튼
            HStack {
                Text("지출")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Button(action: onAddCategory) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("카테고리")
                    }
                    .font(.subheadline)
                    .foregroundColor(AppColors.primary)
                }
            }

            // "이전 달 불러오기" 버튼
            Button(action: onCopyFromPrevious) {
                HStack {
                    Image(systemName: "arrow.down.circle")
                        .foregroundColor(AppColors.primary)

                    Text("이전 달 불러오기")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textPrimary)

                    Spacer()
                }
                .padding()
                .background(AppColors.background)
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())

            Divider()
                .background(AppColors.divider)

            // 카테고리별 지출 리스트
            if categories.isEmpty {
                // 빈 상태
                VStack(spacing: 8) {
                    Text("등록된 지출 카테고리가 없습니다")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)

                    Text("+ 버튼을 눌러 카테고리를 추가하세요")
                        .font(.caption)
                        .foregroundColor(AppColors.textTertiary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 16)
            } else {
                VStack(spacing: 12) {
                    ForEach(categories) { category in
                        ExpenseRow(
                            category: category,
                            amount: getExpenseAmount(category.id ?? ""),
                            onEdit: {
                                onEditExpense(category)
                            },
                            onEditCategory: {
                                onEditCategory(category)
                            },
                            onDelete: {
                                onDeleteCategory(category)
                            }
                        )
                    }
                }
            }

            Divider()
                .background(AppColors.divider)

            // 총 지출
            HStack {
                Text("총 지출")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)

                Spacer()

                Text(totalExpense.formattedCurrency)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
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
    ExpenseSection(
        categories: [
            ExpenseCategory(
                id: "1",
                name: "재료비",
                icon: "💇",
                order: 0,
                createdAt: Date(),
                updatedAt: Date()
            ),
            ExpenseCategory(
                id: "2",
                name: "임대료",
                icon: "🏠",
                order: 1,
                createdAt: Date(),
                updatedAt: Date()
            ),
            ExpenseCategory(
                id: "3",
                name: "인건비",
                icon: "👤",
                order: 2,
                createdAt: Date(),
                updatedAt: Date()
            )
        ],
        getExpenseAmount: { categoryId in
            if categoryId == "1" { return 500000 }
            if categoryId == "2" { return 1200000 }
            if categoryId == "3" { return 800000 }
            return 0
        },
        totalExpense: 2500000,
        onAddCategory: {},
        onCopyFromPrevious: {},
        onEditCategory: { _ in },
        onDeleteCategory: { _ in },
        onEditExpense: { _ in }
    )
    .padding()
}
