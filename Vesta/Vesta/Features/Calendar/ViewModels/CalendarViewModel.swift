//
//  CalendarViewModel.swift
//  Vesta
//
//  Created on 2026-01-22.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class CalendarViewModel: ObservableObject {
    // MARK: - Properties

    @Published var currentDate: Date = Date()
    @Published var selectedDate: Date = Date()
    @Published var records: [DailyRecord] = []
    @Published var adjustments: [DailyAdjustment] = []
    @Published var treatments: [Treatment] = []
    @Published var monthlyRecords: [DailyRecord] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingDayDetail = false
    @Published var showingTreatmentPicker = false
    @Published var showingAdjustmentEdit = false

    private var _authService: AuthService?
    var authService: AuthService {
        _authService ?? AuthService()
    }
    private let recordService = RecordService.shared
    private let adjustmentService = AdjustmentService.shared
    private let treatmentService = TreatmentService.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties

    var currentYear: Int {
        Calendar.current.component(.year, from: currentDate)
    }

    var currentMonth: Int {
        Calendar.current.component(.month, from: currentDate)
    }

    var monthDisplayString: String {
        currentDate.toMonthDisplayString()
    }

    var monthlyRevenue: Int {
        monthlyRecords.reduce(0) { $0 + $1.totalAmount }
    }

    var totalRecordAmount: Int {
        records.reduce(0) { $0 + $1.totalAmount }
    }

    var totalAdjustmentAmount: Int {
        adjustments.reduce(0) { $0 + $1.amount }
    }

    var dailyTotal: Int {
        totalRecordAmount + totalAdjustmentAmount
    }

    // MARK: - Initialization

    init(authService: AuthService? = nil) {
        self._authService = authService
        setupBindings()
    }

    func setAuthService(_ service: AuthService) {
        self._authService = service
    }

    // MARK: - Setup

    private func setupBindings() {
        treatmentService.$treatments
            .assign(to: &$treatments)

        recordService.$records
            .assign(to: &$records)

        adjustmentService.$adjustments
            .assign(to: &$adjustments)
    }

    // MARK: - Month Navigation

    func previousMonth() {
        guard let newDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) else { return }
        currentDate = newDate
        Task {
            await fetchMonthlyData()
        }
    }

    func nextMonth() {
        guard let newDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) else { return }
        currentDate = newDate
        Task {
            await fetchMonthlyData()
        }
    }

    func goToToday() {
        currentDate = Date()
        selectedDate = Date()
        Task {
            await fetchMonthlyData()
            await fetchDayData(for: selectedDate)
        }
    }

    // MARK: - Data Fetching

    func fetchInitialData() async {
        guard let userId = authService.currentUser?.id else { return }

        await treatmentService.fetchTreatments(userId: userId)
        await fetchMonthlyData()
        await fetchDayData(for: selectedDate)
    }

    func fetchMonthlyData() async {
        guard let userId = authService.currentUser?.id else { return }

        monthlyRecords = await recordService.fetchMonthlyRecords(
            userId: userId,
            year: currentYear,
            month: currentMonth
        )
    }

    func fetchDayData(for date: Date) async {
        guard let userId = authService.currentUser?.id else { return }

        await recordService.fetchRecords(userId: userId, date: date)
        await adjustmentService.fetchAdjustments(userId: userId, date: date)
    }

    // MARK: - Day Selection

    func selectDate(_ date: Date) {
        selectedDate = date
        Task {
            await fetchDayData(for: date)
            showingDayDetail = true
        }
    }

    // MARK: - Add Record

    func addRecord(treatmentId: String) async {
        guard let userId = authService.currentUser?.id,
              let treatment = treatments.first(where: { $0.id == treatmentId }) else {
            return
        }

        do {
            _ = try await recordService.addOrUpdateRecord(
                userId: userId,
                date: selectedDate,
                treatmentId: treatmentId,
                price: treatment.price
            )
            await fetchDayData(for: selectedDate)
            await fetchMonthlyData()
            showingTreatmentPicker = false
        } catch {
            errorMessage = "기록 추가 실패: \(error.localizedDescription)"
        }
    }

    // MARK: - Update Record Count

    func updateRecordCount(record: DailyRecord, increment: Bool) async {
        guard let userId = authService.currentUser?.id,
              let recordId = record.id else {
            return
        }

        let newCount = increment ? record.count + 1 : max(0, record.count - 1)
        let unitPrice = record.totalAmount / record.count
        let newTotalAmount = unitPrice * newCount

        do {
            try await recordService.updateRecordCount(
                id: recordId,
                count: newCount,
                totalAmount: newTotalAmount,
                userId: userId
            )
            await fetchDayData(for: selectedDate)
            await fetchMonthlyData()
        } catch {
            errorMessage = "수량 변경 실패: \(error.localizedDescription)"
        }
    }

    // MARK: - Delete Record

    func deleteRecord(record: DailyRecord) async {
        guard let userId = authService.currentUser?.id,
              let recordId = record.id else {
            return
        }

        do {
            try await recordService.deleteRecord(id: recordId, userId: userId)
            await fetchDayData(for: selectedDate)
            await fetchMonthlyData()
        } catch {
            errorMessage = "기록 삭제 실패: \(error.localizedDescription)"
        }
    }

    // MARK: - Add/Update Adjustment

    func saveAdjustment(amount: Int, reason: String?) async {
        guard let userId = authService.currentUser?.id else {
            return
        }

        do {
            _ = try await adjustmentService.addAdjustment(
                userId: userId,
                date: selectedDate,
                amount: amount,
                reason: reason
            )
            await fetchDayData(for: selectedDate)
            await fetchMonthlyData()
            showingAdjustmentEdit = false
        } catch {
            errorMessage = "조정 추가 실패: \(error.localizedDescription)"
        }
    }

    // MARK: - Delete Adjustment

    func deleteAdjustment(adjustment: DailyAdjustment) async {
        guard let userId = authService.currentUser?.id,
              let adjustmentId = adjustment.id else {
            return
        }

        do {
            try await adjustmentService.deleteAdjustment(id: adjustmentId, userId: userId)
            await fetchDayData(for: selectedDate)
            await fetchMonthlyData()
        } catch {
            errorMessage = "조정 삭제 실패: \(error.localizedDescription)"
        }
    }

    // MARK: - Helper Methods

    func getDaysInMonth() -> [Date?] {
        var days: [Date?] = []

        let startOfMonth = currentDate.startOfMonth()

        guard let range = Calendar.current.range(of: .day, in: .month, for: currentDate) else {
            return days
        }

        // 월의 첫날의 요일 (0: 일요일)
        let firstWeekday = Calendar.current.component(.weekday, from: startOfMonth)

        // 앞쪽 빈 칸 추가
        for _ in 1..<firstWeekday {
            days.append(nil)
        }

        // 실제 날짜 추가
        for day in range {
            if let date = Calendar.current.date(bySetting: .day, value: day, of: startOfMonth) {
                days.append(date)
            }
        }

        return days
    }

    func hasRecords(for date: Date) -> Bool {
        monthlyRecords.contains { $0.date.startOfDay() == date.startOfDay() }
    }

    func getTreatment(byId id: String) -> Treatment? {
        treatments.first { $0.id == id }
    }
}
