//
//  ColorPickerView.swift
//  Vesta
//
//  Created on 2026-01-22.
//

import SwiftUI

struct ColorPickerView: View {
    // MARK: - Properties

    @Binding var selectedColor: String
    let columns = [GridItem(.adaptive(minimum: 50))]

    // MARK: - Body

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(TreatmentColors.allColors, id: \.hex) { colorOption in
                ColorCircle(
                    color: colorOption,
                    isSelected: selectedColor == colorOption.hex
                ) {
                    selectedColor = colorOption.hex
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Color Circle

struct ColorCircle: View {
    let color: TreatmentColorOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color(hex: color.hex))
                    .frame(width: 50, height: 50)

                if isSelected {
                    Circle()
                        .stroke(AppColors.primary, lineWidth: 3)
                        .frame(width: 56, height: 56)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    ColorPickerView(selectedColor: .constant("#FFA0B9"))
        .padding()
}
