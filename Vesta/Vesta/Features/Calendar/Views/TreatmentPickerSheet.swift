//
//  TreatmentPickerSheet.swift
//  Vesta
//
//  Created on 2026-01-22.
//

import SwiftUI

struct TreatmentPickerSheet: View {
    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    let treatments: [Treatment]
    let onSelect: (String) -> Void

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView {
                if treatments.isEmpty {
                    VStack(spacing: 16) {
                        Text("등록된 시술이 없습니다")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)

                        Text("설정 탭에서 시술을 먼저 등록해주세요")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.top, 40)
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(treatments) { treatment in
                            TreatmentButton(treatment: treatment) {
                                if let id = treatment.id {
                                    onSelect(id)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("시술 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Treatment Button

struct TreatmentButton: View {
    let treatment: Treatment
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color(hex: treatment.color))
                        .frame(width: 60, height: 60)

                    if let icon = treatment.icon, !icon.isEmpty {
                        Text(icon)
                            .font(.largeTitle)
                    }
                }

                Text(treatment.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)

                Text(treatment.price.formattedCurrency)
                    .font(.caption2)
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(AppColors.background)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    TreatmentPickerSheet(
        treatments: [
            Treatment(
                name: "젤네일",
                price: 50000,
                icon: "💅",
                color: "#FFA0B9",
                order: 0,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Treatment(
                name: "네일아트",
                price: 30000,
                icon: "🎨",
                color: "#FF6B9D",
                order: 1,
                createdAt: Date(),
                updatedAt: Date()
            )
        ],
        onSelect: { _ in }
    )
}
