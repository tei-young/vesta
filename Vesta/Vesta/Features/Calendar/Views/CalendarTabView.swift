//
//  CalendarTabView.swift
//  Vesta
//
//  Created on 2026-01-19.
//

import SwiftUI

struct CalendarTabView: View {
    // MARK: - Properties

    @StateObject private var viewModel = CalendarViewModel()
    @State private var showingDayDetail = false

    private let weekdaySymbols = ["일", "월", "화", "수", "목", "금", "토"]

    // MARK: - Body

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // 월 헤더 (네비게이션 + 월 매출)
                MonthHeaderView(viewModel: viewModel)
                    .padding(.horizontal)

                // 요일 헤더
                weekdayHeader

                // 캘린더 그리드
                CalendarGridView(
                    viewModel: viewModel,
                    days: viewModel.getDaysInMonth()
                )

                Spacer()
            }
            .navigationTitle("캘린더")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingDayDetail) {
                DayDetailSheet(viewModel: viewModel)
            }
            .task {
                await viewModel.loadTreatments()
                await viewModel.loadMonthlyData()
            }
            .onChange(of: viewModel.selectedDate) { _, newDate in
                // 날짜가 선택되면 해당 날짜의 데이터를 로드하고 시트 표시
                Task {
                    await viewModel.loadDailyData(for: newDate)
                    showingDayDetail = true
                }
            }
            .onChange(of: viewModel.currentDate) { _, _ in
                // 월이 변경되면 월별 데이터 다시 로드
                Task {
                    await viewModel.loadMonthlyData()
                }
            }
        }
    }

    // MARK: - Subviews

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(
                        symbol == "일" ? .red :
                        symbol == "토" ? .blue :
                        AppColors.textSecondary
                    )
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    CalendarTabView()
}
