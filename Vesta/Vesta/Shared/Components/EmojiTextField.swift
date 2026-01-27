//
//  EmojiTextField.swift
//  Vesta
//
//  Created on 2026-01-22.
//  Updated on 2026-01-27.
//

import SwiftUI
import UIKit

struct EmojiTextField: View {
    // MARK: - Properties

    @Binding var text: String
    let placeholder: String

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            EmojiTextFieldRepresentable(text: $text, placeholder: placeholder)
                .frame(width: 80, height: 80)
                .background(AppColors.background)
                .cornerRadius(12)

            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.textSecondary)
                        .font(.title2)
                }
            }
        }
    }
}

// MARK: - UIViewRepresentable

struct EmojiTextFieldRepresentable: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.placeholder = placeholder
        textField.font = UIFont.systemFont(ofSize: 40)
        textField.textAlignment = .center
        textField.borderStyle = .none
        textField.backgroundColor = .clear

        // 자동으로 이모지 키보드를 선호하도록 설정
        textField.textContentType = .none

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: EmojiTextFieldRepresentable

        init(_ parent: EmojiTextFieldRepresentable) {
            self.parent = parent
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

            // 최대 10글자 제한 (이모지나 텍스트 모두 허용)
            if updatedText.count <= 10 {
                parent.text = updatedText
                return true
            }

            return false
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        EmojiTextField(text: .constant("💅"), placeholder: "아이콘")
        EmojiTextField(text: .constant("월세"), placeholder: "아이콘")
        EmojiTextField(text: .constant(""), placeholder: "아이콘")
    }
    .padding()
}
