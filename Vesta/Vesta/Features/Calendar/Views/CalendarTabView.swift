//
//  CalendarTabView.swift
//  Vesta
//
//  Created on 2026-01-19.
//

import SwiftUI

struct CalendarTabView: View {
    // MARK: - Properties

    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = CalendarViewModel()
    @State private var showingDayDetail = false

    // MARK: - Body

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // 월 헤더 (네비게이션 + 월 매출)
                MonthHeaderView(
                    monthString: viewModel.monthDisplayString,
                    monthlyRevenue: viewModel.monthlyRevenue,
                    onPrevious: { viewModel.previousMonth() },
                    onNext: { viewModel.nextMonth() },
                    onToday: { viewModel.goToToday() }
                )

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
            .onAppear {
                viewModel.setAuthService(authService)
            }
            .task {
                await viewModel.fetchInitialData()
            }
            .onChange(of: viewModel.selectedDate) { _, newDate in
                // 날짜가 선택되면 해당 날짜의 데이터를 로드하고 시트 표시
                Task {
                    await viewModel.fetchDayData(for: newDate)
                    showingDayDetail = true
                }
            }
            .onChange(of: viewModel.currentDate) { _, _ in
                // 월이 변경되면 월별 데이터 다시 로드
                Task {
                    await viewModel.fetchMonthlyData()
                }
            }
        }
    }
}

#Preview {
    CalendarTabView()
}
