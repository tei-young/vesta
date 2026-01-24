//
//  DayCell.swift
//  Vesta
//
//  Created on 2026-01-22.
//

import SwiftUI

struct DayCell: View {
    // MARK: - Properties

    let date: Date?
    let isToday: Bool
    let isSelected: Bool
    let treatmentColors: [String]
    let onTap: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                if let date = date {
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.body)
                        .fontWeight(isToday ? .bold : .regular)
                        .foregroundColor(textColor)

                    // 시술 색상 도트 표시
                    if !treatmentColors.isEmpty {
                        HStack(spacing: 2) {
                            ForEach(treatmentColors, id: \.self) { colorHex in
                                Circle()
                                    .fill(Color(hex: colorHex))
                                    .frame(width: 4, height: 4)
                            }
                        }
                        .frame(height: 4)
                    } else {
                        Spacer()
                            .frame(height: 4)
                    }
                } else {
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(backgroundColor)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Computed Properties

    private var textColor: Color {
        if date == nil {
            return .clear
        } else if isSelected {
            return .white
        } else if isToday {
            return AppColors.primary
        } else {
            return AppColors.textPrimary
        }
    }

    private var backgroundColor: Color {
        if date == nil {
            return .clear
        } else if isSelected {
            return AppColors.primary
        } else if isToday {
            return AppColors.primaryLight.opacity(0.3)
        } else {
            return Color.clear
        }
    }
}

// MARK: - Preview

#Preview {
    HStack {
        DayCell(
            date: Date(),
            isToday: true,
            isSelected: false,
            treatmentColors: ["#FF6B6B", "#4ECDC4"],
            onTap: {}
        )

        DayCell(
            date: Date(),
            isToday: false,
            isSelected: true,
            treatmentColors: ["#95E1D3"],
            onTap: {}
        )

        DayCell(
            date: nil,
            isToday: false,
            isSelected: false,
            treatmentColors: [],
            onTap: {}
        )
    }
    .padding()
}
