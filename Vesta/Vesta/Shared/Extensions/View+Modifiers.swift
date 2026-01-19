//
//  View+Modifiers.swift
//  Vesta
//
//  Created on 2026-01-19.
//

import SwiftUI

extension View {
    // MARK: - Card Style

    /// 카드 스타일 적용
    func cardStyle(padding: CGFloat = AppConstants.Spacing.m) -> some View {
        self
            .padding(padding)
            .background(AppColors.card)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - Primary Button Style

    /// 메인 버튼 스타일 적용
    func primaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppColors.primary)
            .cornerRadius(12)
    }

    /// 보조 버튼 스타일 적용
    func secondaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(AppColors.textPrimary)
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppColors.accent)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.divider, lineWidth: 1)
            )
    }

    // MARK: - Conditional Modifier

    /// 조건부로 modifier 적용
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    // MARK: - Keyboard Dismiss

    /// 키보드 숨기기
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    /// 탭하면 키보드 숨기기
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            hideKeyboard()
        }
    }
}

// MARK: - Custom ViewModifier

struct RoundedBackgroundModifier: ViewModifier {
    var color: Color
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .padding()
            .background(color)
            .cornerRadius(cornerRadius)
    }
}

extension View {
    func roundedBackground(_ color: Color = AppColors.accent, cornerRadius: CGFloat = 12) -> some View {
        modifier(RoundedBackgroundModifier(color: color, cornerRadius: cornerRadius))
    }
}
