//
//  AdjustmentEditSheet.swift
//  Vesta
//
//  Created on 2026-01-22.
//

import SwiftUI

struct AdjustmentEditSheet: View {
    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    let date: Date
    let onSave: (Int, String) -> Void

    @State private var amountText: String = ""
    @State private var reason: String = ""
    @State private var isDiscount: Bool = false
    @FocusState private var focusedField: Field?

    enum Field {
        case amount
        case reason
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            Form {
                Section {
                    // 조정 타입 선택
                    Picker("타입", selection: $isDiscount) {
                        Text("추가 금액").tag(false)
                        Text("할인").tag(true)
                    }
                    .pickerStyle(.segmented)

                    // 금액 입력
                    HStack {
                        Text("금액")
                            .foregroundColor(AppColors.textPrimary)

                        Spacer()

                        TextField("0", text: $amountText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .amount)

                        Text("원")
                            .foregroundColor(AppColors.textSecondary)
                    }

                    // 사유 입력 (선택)
                    TextField("사유 (선택)", text: $reason)
                        .focused($focusedField, equals: .reason)
                } header: {
                    Text("조정 정보")
                }

                Section {
                    // 미리보기
                    HStack {
                        Text("최종 금액")
                            .foregroundColor(AppColors.textPrimary)

                        Spacer()

                        Text(finalAmount.formattedCurrency)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(isDiscount ? .red : .green)
                    }
                }
            }
            .navigationTitle("금액 조정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        saveAdjustment()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                focusedField = .amount
            }
        }
    }

    // MARK: - Computed Properties

    private var finalAmount: Int {
        let amount = Int(amountText) ?? 0
        return isDiscount ? -amount : amount
    }

    private var isValid: Bool {
        guard let amount = Int(amountText), amount > 0 else {
            return false
        }
        return true
    }

    // MARK: - Methods

    private func saveAdjustment() {
        onSave(finalAmount, reason.trimmingCharacters(in: .whitespacesAndNewlines))
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    AdjustmentEditSheet(
        date: Date(),
        onSave: { amount, reason in
            print("Amount: \(amount), Reason: \(reason)")
        }
    )
}
