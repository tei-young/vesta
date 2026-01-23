//
//  CalendarTabView.swift
//  Vesta
//
//  Created on 2026-01-19.
//

import SwiftUI

struct CalendarTabView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        CalendarTabContent(authService: authService)
    }
}

private struct CalendarTabContent: View {
    // MARK: - Properties

    @StateObject private var viewModel: CalendarViewModel
    @State private var showingDayDetail = false

    // MARK: - Initialization

    init(authService: AuthService) {
        _viewModel = StateObject(wrappedValue: CalendarViewModel(authService: authService))
    }

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
            .task {
                await viewModel.fetchInitialData()
            }
            .onChange(of: viewModel.shouldShowDayDetail) { _, _ in
                // 날짜 선택 시 항상 트리거됨 (같은 날짜도 포함)
                showingDayDetail = true
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
