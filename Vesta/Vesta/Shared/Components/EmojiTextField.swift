//
//  EmojiTextField.swift
//  Vesta
//
//  Created on 2026-01-22.
//  Updated on 2026-01-27.
//

import SwiftUI

struct EmojiTextField: View {
    // MARK: - Properties

    @Binding var text: String
    let placeholder: String
    @FocusState private var isFocused: Bool

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            TextField(placeholder, text: $text)
                .font(.system(size: 40))
                .multilineTextAlignment(.center)
                .frame(width: 80, height: 80)
                .background(AppColors.background)
                .cornerRadius(12)
                .focused($isFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onChange(of: text) { oldValue, newValue in
                    // 최대 10글자 제한
                    if newValue.count > 10 {
                        text = String(newValue.prefix(10))
                    }
                }
                .onTapGesture {
                    isFocused = true
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
    VStack(spacing: 20) {
        EmojiTextField(text: .constant("💅"), placeholder: "아이콘")
        EmojiTextField(text: .constant("월세"), placeholder: "아이콘")
        EmojiTextField(text: .constant(""), placeholder: "아이콘")
    }
    .padding()
}
