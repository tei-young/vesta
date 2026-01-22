//
//  DayDetailSheet.swift
//  Vesta
//
//  Created on 2026-01-22.
//

import SwiftUI

struct DayDetailSheet: View {
    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CalendarViewModel

    @State private var showingTreatmentPicker = false
    @State private var showingAdjustmentEdit = false

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 날짜 표시
                    dateHeader

                    // 시술 기록 섹션
                    recordsSection

                    // 조정 금액 섹션
                    adjustmentsSection

                    // 합계 섹션
                    totalSection
                }
                .padding()
            }
            .navigationTitle("일별 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingTreatmentPicker) {
                TreatmentPickerSheet(
                    treatments: viewModel.treatments,
                    onSelect: { treatmentId in
                        Task {
                            await viewModel.addRecord(treatmentId: treatmentId)
                        }
                        showingTreatmentPicker = false
                    }
                )
            }
            .sheet(isPresented: $showingAdjustmentEdit) {
                AdjustmentEditSheet(
                    date: viewModel.selectedDate,
                    onSave: { amount, reason in
                        Task {
                            await viewModel.saveAdjustment(amount: amount, reason: reason)
                        }
                        showingAdjustmentEdit = false
                    }
                )
            }
        }
    }

    // MARK: - Subviews

    private var dateHeader: some View {
        VStack(spacing: 4) {
            Text(viewModel.selectedDate.formatted(.dateTime.year().month().day()))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)

            Text(viewModel.selectedDate.formatted(.dateTime.weekday(.wide)))
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppColors.card)
        .cornerRadius(12)
    }

    private var recordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 섹션 헤더
            HStack {
                Text("시술 기록")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Button(action: {
                    showingTreatmentPicker = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("시술 추가")
                    }
                    .font(.subheadline)
                    .foregroundColor(AppColors.primary)
                }
            }

            // 시술 기록 리스트
            if viewModel.records.isEmpty {
                Text("등록된 시술이 없습니다")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.records) { record in
                        RecordRow(
                            record: record,
                            treatment: viewModel.getTreatment(byId: record.treatmentId),
                            onIncrement: {
                                Task {
                                    await viewModel.updateRecordCount(record: record, increment: true)
                                }
                            },
                            onDecrement: {
                                Task {
                                    await viewModel.updateRecordCount(record: record, increment: false)
                                }
                            },
                            onDelete: {
                                Task {
                                    await viewModel.deleteRecord(record: record)
                                }
                            }
                        )
                        .padding(.horizontal, 8)

                        if record.id != viewModel.records.last?.id {
                            Divider()
                        }
                    }
                }
                .padding(.vertical, 8)
                .background(AppColors.card)
                .cornerRadius(12)
            }
        }
    }

    private var adjustmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 섹션 헤더
            HStack {
                Text("금액 조정")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Button(action: {
                    showingAdjustmentEdit = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("조정 추가")
                    }
                    .font(.subheadline)
                    .foregroundColor(AppColors.primary)
                }
            }

            // 조정 금액 리스트
            if viewModel.adjustments.isEmpty {
                Text("금액 조정 내역이 없습니다")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.adjustments) { adjustment in
                        AdjustmentRow(
                            adjustment: adjustment,
                            onDelete: {
                                Task {
                                    await viewModel.deleteAdjustment(adjustment: adjustment)
                                }
                            }
                        )
                        .padding(.horizontal, 8)

                        if adjustment.id != viewModel.adjustments.last?.id {
                            Divider()
                        }
                    }
                }
                .padding(.vertical, 8)
                .background(AppColors.card)
                .cornerRadius(12)
            }
        }
    }

    private var totalSection: some View {
        VStack(spacing: 12) {
            Divider()

            // 시술 합계
            HStack {
                Text("시술 합계")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)

                Spacer()

                Text(viewModel.totalRecordAmount.formattedCurrency)
                    .font(.body)
                    .foregroundColor(AppColors.textPrimary)
            }

            // 조정 합계
            if !viewModel.adjustments.isEmpty {
                HStack {
                    Text("조정 합계")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)

                    Spacer()

                    Text(viewModel.totalAdjustmentAmount.formattedCurrency)
                        .font(.body)
                        .foregroundColor(viewModel.totalAdjustmentAmount < 0 ? .red : .green)
                }
            }

            Divider()

            // 일일 합계
            HStack {
                Text("일일 합계")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text(viewModel.dailyTotal.formattedCurrency)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primary)
            }
        }
        .padding()
        .background(AppColors.card)
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    DayDetailSheet(
        viewModel: CalendarViewModel(authService: AuthService())
    )
}
