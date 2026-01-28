//
//  SettlementViewModel.swift
//  Vesta
//
//  Created on 2026-01-25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class SettlementViewModel: ObservableObject {
    // MARK: - Properties

    @Published var currentDate: Date = Date()
    @Published var monthlyRecords: [DailyRecord] = []
    @Published var monthlyAdjustments: [DailyAdjustment] = []
    @Published var expenses: [MonthlyExpense] = []
    @Published var categories: [ExpenseCategory] = []
    @Published var treatments: [Treatment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    var authService: AuthService
    private let recordService = RecordService.shared
    private let adjustmentService = AdjustmentService.shared
    private let expenseService = ExpenseService.shared
    private let categoryService = CategoryService.shared
    private let treatmentService = TreatmentService.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties

    var currentYear: Int {
        Calendar.current.component(.year, from: currentDate)
    }

    var currentMonth: Int {
        Calendar.current.component(.month, from: currentDate)
    }

    var yearMonthString: String {
        String(format: "%04d-%02d", currentYear, currentMonth)
    }

    var monthDisplayString: String {
        currentDate.toMonthDisplayString()
    }

    /// 총 매출 (시술 기록 + 조정 금액)
    var totalRevenue: Int {
        let recordsAmount = monthlyRecords.reduce(0) { $0 + $1.totalAmount }
        let adjustmentsAmount = monthlyAdjustments.reduce(0) { $0 + $1.amount }
        return recordsAmount + adjustmentsAmount
    }

    /// 총 지출
    var totalExpense: Int {
        expenses.reduce(0) { $0 + $1.amount }
    }

    /// 순이익
    var netProfit: Int {
        totalRevenue - totalExpense
    }

    /// 시술별 매출
    var revenueByTreatment: [(treatmentId: String, name: String, color: String, amount: Int)] {
        // 시술 ID별로 금액 합산
        var revenueDict: [String: Int] = [:]

        for record in monthlyRecords {
            revenueDict[record.treatmentId, default: 0] += record.totalAmount
        }

        // 시술 정보와 결합
        let result = revenueDict.compactMap { (treatmentId, amount) -> (String, String, String, Int)? in
            guard let treatment = getTreatment(byId: treatmentId) else {
                return nil
            }
            return (treatmentId, treatment.name, treatment.color, amount)
        }

        // 금액 내림차순 정렬
        return result.sorted { $0.3 > $1.3 }
    }

    // MARK: - Initialization

    init(authService: AuthService) {
        self.authService = authService
        subscribeToServices()
    }

    // MARK: - Subscribe to Services

    private func subscribeToServices() {
        // ExpenseService의 expenses 변화 구독
        expenseService.$expenses
            .sink { [weak self] fetchedExpenses in
                self?.expenses = fetchedExpenses
            }
            .store(in: &cancellables)

        // CategoryService의 categories 변화 구독
        categoryService.$categories
            .sink { [weak self] fetchedCategories in
                self?.categories = fetchedCategories
            }
            .store(in: &cancellables)

        // TreatmentService의 treatments 변화 구독
        treatmentService.$treatments
            .sink { [weak self] fetchedTreatments in
                self?.treatments = fetchedTreatments
            }
            .store(in: &cancellables)
    }

    // MARK: - Fetch Data

    /// 월별 데이터 조회 (매출, 지출, 카테고리, 시술)
    func fetchMonthlyData() async {
        guard let userId = authService.currentUser?.id else {
            print("❌ [SettlementViewModel] userId가 없습니다.")
            return
        }

        isLoading = true
        errorMessage = nil

        print("🔍 [SettlementViewModel] 월별 데이터 조회 시작 - \(yearMonthString)")

        async let recordsTask = recordService.fetchMonthlyRecords(
            userId: userId,
            year: currentYear,
            month: currentMonth
        )
        async let adjustmentsTask = adjustmentService.fetchMonthlyAdjustments(
            userId: userId,
            year: currentYear,
            month: currentMonth
        )

        // 동시에 실행
        let (records, adjustments) = await (recordsTask, adjustmentsTask)

        self.monthlyRecords = records
        self.monthlyAdjustments = adjustments

        // 지출, 카테고리, 시술 조회
        await expenseService.fetchExpenses(userId: userId, yearMonth: yearMonthString)
        await categoryService.fetchCategories(userId: userId)
        await treatmentService.fetchTreatments(userId: userId)

        print("✅ [SettlementViewModel] 월별 데이터 조회 완료")
        print("   매출: \(totalRevenue.formattedCurrency), 지출: \(totalExpense.formattedCurrency), 순이익: \(netProfit.formattedCurrency)")

        isLoading = false
    }

    // MARK: - Navigation

    func navigateToPreviousMonth() {
        guard let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) else {
            return
        }
        currentDate = previousMonth
        Task {
            await fetchMonthlyData()
        }
    }

    func navigateToNextMonth() {
        guard let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) else {
            return
        }
        currentDate = nextMonth
        Task {
            await fetchMonthlyData()
        }
    }

    func navigateToCurrentMonth() {
        currentDate = Date()
        Task {
            await fetchMonthlyData()
        }
    }

    // MARK: - Expense Management

    /// 특정 카테고리의 지출 금액 가져오기
    func getExpenseAmount(for categoryId: String) -> Int {
        expenses.first { $0.categoryId == categoryId }?.amount ?? 0
    }

    /// 지출 추가/업데이트
    func updateExpense(categoryId: String, amount: Int) async {
        guard let userId = authService.currentUser?.id else {
            print("❌ [SettlementViewModel] userId가 없습니다.")
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await expenseService.upsertExpense(
                userId: userId,
                yearMonth: yearMonthString,
                categoryId: categoryId,
                amount: amount
            )
            print("✅ [SettlementViewModel] 지출 업데이트 완료: \(amount.formattedCurrency)")
        } catch {
            errorMessage = "지출 업데이트 실패: \(error.localizedDescription)"
            print("❌ [SettlementViewModel] 지출 업데이트 실패: \(error)")
        }

        isLoading = false
    }

    /// 전월 지출 복사
    func copyExpensesFromPreviousMonth() async {
        guard let userId = authService.currentUser?.id else {
            print("❌ [SettlementViewModel] userId가 없습니다.")
            return
        }

        // 전월 계산
        guard let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) else {
            return
        }

        let previousYear = Calendar.current.component(.year, from: previousMonth)
        let previousMonthNumber = Calendar.current.component(.month, from: previousMonth)
        let previousYearMonth = String(format: "%04d-%02d", previousYear, previousMonthNumber)

        isLoading = true
        errorMessage = nil

        do {
            try await expenseService.copyFromPreviousMonth(
                userId: userId,
                fromYearMonth: previousYearMonth,
                toYearMonth: yearMonthString
            )

            // 복사 후 다시 조회
            await expenseService.fetchExpenses(userId: userId, yearMonth: yearMonthString)

            print("✅ [SettlementViewModel] 전월 지출 복사 완료")
        } catch {
            errorMessage = "전월 지출 복사 실패: \(error.localizedDescription)"
            print("❌ [SettlementViewModel] 전월 지출 복사 실패: \(error)")
        }

        isLoading = false
    }

    // MARK: - Helper Methods

    func getTreatment(byId id: String) -> Treatment? {
        treatments.first { $0.id == id }
    }

    func getCategory(byId id: String) -> ExpenseCategory? {
        categories.first { $0.id == id }
    }

    // MARK: - Category Management

    /// 카테고리 추가
    func addCategory(name: String, icon: String) async {
        guard let userId = authService.currentUser?.id else {
            print("❌ [SettlementViewModel] userId가 없습니다.")
            return
        }

        isLoading = true
        errorMessage = nil

        // 빈 문자열은 nil로 변환
        let iconValue = icon.isEmpty ? nil : icon

        do {
            try await categoryService.addCategory(name: name, icon: iconValue, userId: userId)
            await categoryService.fetchCategories(userId: userId)
            print("✅ [SettlementViewModel] 카테고리 추가 완료: \(name)")
        } catch {
            errorMessage = "카테고리 추가 실패: \(error.localizedDescription)"
            print("❌ [SettlementViewModel] 카테고리 추가 실패: \(error)")
        }

        isLoading = false
    }

    /// 카테고리 수정
    func updateCategory(_ category: ExpenseCategory, name: String, icon: String) async {
        guard let userId = authService.currentUser?.id,
              let categoryId = category.id else {
            print("❌ [SettlementViewModel] userId 또는 categoryId가 없습니다.")
            return
        }

        isLoading = true
        errorMessage = nil

        var updated = category
        updated.name = name
        updated.icon = icon.isEmpty ? nil : icon

        do {
            try await categoryService.updateCategory(updated, userId: userId)
            await categoryService.fetchCategories(userId: userId)
            print("✅ [SettlementViewModel] 카테고리 수정 완료: \(name)")
        } catch {
            errorMessage = "카테고리 수정 실패: \(error.localizedDescription)"
            print("❌ [SettlementViewModel] 카테고리 수정 실패: \(error)")
        }

        isLoading = false
    }

    /// 카테고리 삭제
    func deleteCategory(_ category: ExpenseCategory) async {
        guard let userId = authService.currentUser?.id,
              let categoryId = category.id else {
            print("❌ [SettlementViewModel] userId 또는 categoryId가 없습니다.")
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await categoryService.deleteCategory(id: categoryId, userId: userId)
            await categoryService.fetchCategories(userId: userId)
            print("✅ [SettlementViewModel] 카테고리 삭제 완료")
        } catch {
            errorMessage = "카테고리 삭제 실패: \(error.localizedDescription)"
            print("❌ [SettlementViewModel] 카테고리 삭제 실패: \(error)")
        }

        isLoading = false
    }
}
