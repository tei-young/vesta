//
//  CategoryEditSheet.swift
//  Vesta
//
//  Created on 2026-01-25.
//

import SwiftUI

struct CategoryEditSheet: View {
    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss

    let editingCategory: ExpenseCategory?
    let onSave: (String, String) async -> Void  // (name, icon) -> Void

    @State private var name: String = ""
    @State private var icon: String = ""

    private var isEditing: Bool {
        editingCategory != nil
    }

    private var title: String {
        isEditing ? "카테고리 수정" : "카테고리 추가"
    }

    private var isValid: Bool {
        !name.isEmpty && !icon.isEmpty
    }

    // MARK: - Initialization

    init(editingCategory: ExpenseCategory?, onSave: @escaping (String, String) async -> Void) {
        self.editingCategory = editingCategory
        self.onSave = onSave

        if let category = editingCategory {
            _name = State(initialValue: category.name)
            _icon = State(initialValue: category.icon)
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            Form {
                // 카테고리명 입력
                Section("카테고리명") {
                    TextField("예: 재료비", text: $name)
                }

                // 아이콘 선택
                Section("아이콘") {
                    EmojiTextField(text: $icon, placeholder: "💇")
                }

                // 미리보기
                if !name.isEmpty && !icon.isEmpty {
                    Section("미리보기") {
                        HStack(spacing: 12) {
                            Text(icon)
                                .font(.title2)
                                .frame(width: 40, height: 40)

                            Text(name)
                                .font(.subheadline)
                                .foregroundColor(AppColors.textPrimary)

                            Spacer()
                        }
                    }
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
                    Button("저장") {
                        Task {
                            await onSave(name, icon)
                            dismiss()
                        }
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CategoryEditSheet(
        editingCategory: nil,
        onSave: { name, icon in
            print("카테고리 저장: \(name), \(icon)")
        }
    )
}
