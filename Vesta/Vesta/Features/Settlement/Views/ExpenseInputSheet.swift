//
//  ExpenseInputSheet.swift
//  Vesta
//
//  Created on 2026-01-25.
//

import SwiftUI

struct ExpenseInputSheet: View {
    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss

    let category: ExpenseCategory
    let currentAmount: Int
    let onSave: (Int) async -> Void

    @State private var amountText: String = ""

    private var isValid: Bool {
        !amountText.isEmpty && Int(amountText) != nil
    }

    private var inputAmount: Int {
        Int(amountText) ?? 0
    }

    // MARK: - Initialization

    init(category: ExpenseCategory, currentAmount: Int, onSave: @escaping (Int) async -> Void) {
        self.category = category
        self.currentAmount = currentAmount
        self.onSave = onSave

        if currentAmount > 0 {
            _amountText = State(initialValue: String(currentAmount))
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // 카테고리 정보
                VStack(spacing: 12) {
                    Text(category.icon ?? "📋")
                        .font(.system(size: 60))

                    Text(category.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)

                    Text("지출 금액 입력")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, 32)

                // 금액 입력
                VStack(spacing: 8) {
                    TextField("0", text: $amountText)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(AppColors.primary)
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .onChange(of: amountText) { oldValue, newValue in
                            // 숫자만 입력 가능
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered != newValue {
                                amountText = filtered
                            }
                        }

                    // 천 단위 구분자로 표시
                    if let amount = Int(amountText), amount > 0 {
                        Text(amount.formattedCurrency)
                            .font(.title3)
                            .foregroundColor(AppColors.textSecondary)
                    } else {
                        Text("금액을 입력하세요")
                            .font(.title3)
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
                .padding(.horizontal)

                Spacer()

                // 빠른 입력 버튼
                VStack(spacing: 12) {
                    Text("빠른 입력")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)

                    HStack(spacing: 12) {
                        QuickAmountButton(amount: 100000, currentText: $amountText)
                        QuickAmountButton(amount: 500000, currentText: $amountText)
                        QuickAmountButton(amount: 1000000, currentText: $amountText)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .navigationTitle("지출 입력")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        Task {
                            await onSave(inputAmount)
                            dismiss()
                        }
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}

// MARK: - Quick Amount Button

private struct QuickAmountButton: View {
    let amount: Int
    @Binding var currentText: String

    var body: some View {
        Button(action: {
            currentText = String(amount)
        }) {
            Text(amount.formattedCurrency)
                .font(.subheadline)
                .foregroundColor(AppColors.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppColors.background)
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    ExpenseInputSheet(
        category: ExpenseCategory(
            name: "재료비",
            icon: "💇",
            order: 0
        ),
        currentAmount: 500000,
        onSave: { amount in
            print("저장: \(amount)")
        }
    )
}
