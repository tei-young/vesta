//
//  TreatmentEditSheet.swift
//  Vesta
//
//  Created on 2026-01-22.
//

import SwiftUI

struct TreatmentEditSheet: View {
    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SettingsViewModel

    let editingTreatment: Treatment?

    @State private var name: String = ""
    @State private var priceText: String = ""
    @State private var icon: String = ""
    @State private var selectedColor: String = "#FFA0B9"

    private var isEditing: Bool {
        editingTreatment != nil
    }

    private var title: String {
        isEditing ? "시술 수정" : "시술 추가"
    }

    private var isValid: Bool {
        !name.isEmpty && !priceText.isEmpty && Int(priceText) != nil
    }

    // MARK: - Initialization

    init(viewModel: SettingsViewModel, editingTreatment: Treatment?) {
        self.viewModel = viewModel
        self.editingTreatment = editingTreatment

        if let treatment = editingTreatment {
            _name = State(initialValue: treatment.name)
            _priceText = State(initialValue: String(treatment.price))
            _icon = State(initialValue: treatment.icon ?? "")
            _selectedColor = State(initialValue: treatment.color)
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            Form {
                // 시술명 입력
                Section("시술명") {
                    TextField("예: 젤네일", text: $name)
                }

                // 가격 입력
                Section("가격") {
                    TextField("가격 입력", text: $priceText)
                        .keyboardType(.numberPad)
                        .onChange(of: priceText) { oldValue, newValue in
                            // 숫자만 입력 가능
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered != newValue {
                                priceText = filtered
                            }
                        }

                    if let price = Int(priceText) {
                        Text(price.formattedCurrency)
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                // 아이콘 선택
                Section {
                    EmojiTextField(text: $icon, placeholder: "아이콘")
                } header: {
                    Text("아이콘 (선택)")
                } footer: {
                    Text("이모지나 짧은 텍스트를 입력하세요")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                // 색상 선택
                Section("색상") {
                    ColorPickerView(selectedColor: $selectedColor)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "수정" : "추가") {
                        saveAction()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    // MARK: - Actions

    private func saveAction() {
        guard let price = Int(priceText) else { return }

        Task {
            if let treatment = editingTreatment, let _ = treatment.id {
                // 수정
                var updatedTreatment = treatment
                updatedTreatment.name = name
                updatedTreatment.price = price
                updatedTreatment.icon = icon.isEmpty ? nil : icon
                updatedTreatment.color = selectedColor

                await viewModel.updateTreatment(updatedTreatment)
            } else {
                // 추가
                await viewModel.addTreatment(
                    name: name,
                    price: price,
                    icon: icon.isEmpty ? nil : icon,
                    color: selectedColor
                )
            }

            dismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    TreatmentEditSheet(
        viewModel: SettingsViewModel(authService: AuthService()),
        editingTreatment: nil
    )
}
