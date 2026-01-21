//
//  EmojiTextField.swift
//  Vesta
//
//  Created on 2026-01-22.
//

import SwiftUI

struct EmojiTextField: View {
    // MARK: - Properties

    @Binding var text: String
    let placeholder: String

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            TextField(placeholder, text: $text)
                .font(.system(size: 40))
                .multilineTextAlignment(.center)
                .frame(width: 80, height: 80)
                .background(AppColors.background)
                .cornerRadius(12)
                .onChange(of: text) { oldValue, newValue in
                    // 이모지 2글자 제한
                    if newValue.count > 2 {
                        text = String(newValue.prefix(2))
                    }
                }

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

// MARK: - Preview

#Preview {
    EmojiTextField(text: .constant("💅"), placeholder: "💅")
        .padding()
}
