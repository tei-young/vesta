//
//  ExpenseService.swift
//  Vesta
//
//  Created on 2026-01-21.
//

import Foundation
import FirebaseFirestore

/// 월별 지출 관리 서비스
@MainActor
class ExpenseService: ObservableObject {
    // MARK: - Properties

    static let shared = ExpenseService()
    private let firestoreService = FirestoreService.shared
    private let collectionName = "monthlyExpenses"

    @Published var expenses: [MonthlyExpense] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private init() {}

    // MARK: - Fetch Expenses

    /// 월별 지출 조회
    /// - Parameters:
    ///   - userId: 사용자 ID
    ///   - yearMonth: 년월 (예: "2026-01")
    func fetchExpenses(userId: String, yearMonth: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedExpenses: [MonthlyExpense] = try await firestoreService.queryDocuments(
                userId: userId,
                collectionName: collectionName,
                field: "yearMonth",
                isEqualTo: yearMonth
            )

            self.expenses = fetchedExpenses
            print("✅ [ExpenseService] \(expenses.count)개 지출 조회 완료 (\(yearMonth))")
        } catch {
            errorMessage = "지출 목록 조회 실패: \(error.localizedDescription)"
            print("❌ [ExpenseService] 조회 실패: \(error.localizedDescription)")
        }

        isLoading = false
    }

    // MARK: - Upsert Expense

    /// 지출 추가 또는 업데이트
    /// - Parameters:
    ///   - userId: 사용자 ID
    ///   - yearMonth: 년월 (예: "2026-01")
    ///   - categoryId: 카테고리 ID
    ///   - amount: 금액
    /// - Returns: 생성/업데이트된 지출 ID
    @discardableResult
    func upsertExpense(
        userId: String,
        yearMonth: String,
        categoryId: String,
        amount: Int
    ) async throws -> String {
        isLoading = true
        errorMessage = nil

        // 해당 월 + 카테고리로 기존 지출 찾기
        let existingExpense = expenses.first { expense in
            expense.yearMonth == yearMonth && expense.categoryId == categoryId
        }

        do {
            if let existing = existingExpense, let existingId = existing.id {
                // 기존 지출 업데이트
                let updateData: [String: Any] = [
                    "amount": amount,
                    "updatedAt": Timestamp(date: Date())
                ]

                try await firestoreService.updateDocument(
                    documentId: existingId,
                    data: updateData,
                    userId: userId,
                    collectionName: collectionName
                )

                // 로컬 배열 업데이트
                if let index = expenses.firstIndex(where: { $0.id == existingId }) {
                    expenses[index].amount = amount
                }

                print("✅ [ExpenseService] 지출 업데이트 성공: \(amount.formattedCurrency)")
                isLoading = false
                return existingId
            } else {
                // 새 지출 추가
                let now = Date()
                var newExpense = MonthlyExpense(
                    yearMonth: yearMonth,
                    categoryId: categoryId,
                    amount: amount,
                    createdAt: now
                )

                let documentId = try await firestoreService.addDocument(
                    newExpense,
                    userId: userId,
                    collectionName: collectionName
                )

                // 로컬 배열에 추가
                newExpense.id = documentId
                expenses.append(newExpense)

                print("✅ [ExpenseService] 지출 추가 성공: \(amount.formattedCurrency)")
                isLoading = false
                return documentId
            }
        } catch {
            errorMessage = "지출 추가/수정 실패: \(error.localizedDescription)"
            print("❌ [ExpenseService] 추가/수정 실패: \(error.localizedDescription)")
            isLoading = false
            throw error
        }
    }

    // MARK: - Delete Expense

    /// 지출 삭제
    /// - Parameters:
    ///   - id: 지출 ID
    ///   - userId: 사용자 ID
    func deleteExpense(id: String, userId: String) async throws {
        isLoading = true
        errorMessage = nil

        do {
            try await firestoreService.deleteDocument(
                documentId: id,
                userId: userId,
                collectionName: collectionName
            )

            // 로컬 배열에서 제거
            expenses.removeAll { $0.id == id }

            print("✅ [ExpenseService] 지출 삭제 성공: \(id)")
            isLoading = false
        } catch {
            errorMessage = "지출 삭제 실패: \(error.localizedDescription)"
            print("❌ [ExpenseService] 삭제 실패: \(error.localizedDescription)")
            isLoading = false
            throw error
        }
    }

    // MARK: - Copy From Previous Month

    /// 전월 지출 복사
    /// - Parameters:
    ///   - userId: 사용자 ID
    ///   - fromYearMonth: 복사할 년월 (예: "2026-01")
    ///   - toYearMonth: 대상 년월 (예: "2026-02")
    func copyFromPreviousMonth(
        userId: String,
        fromYearMonth: String,
        toYearMonth: String
    ) async throws {
        isLoading = true
        errorMessage = nil

        do {
            // 전월 지출 조회
            let previousExpenses: [MonthlyExpense] = try await firestoreService.queryDocuments(
                userId: userId,
                collectionName: collectionName,
                field: "yearMonth",
                isEqualTo: fromYearMonth
            )

            guard !previousExpenses.isEmpty else {
                print("⚠️ [ExpenseService] 전월 지출 데이터가 없습니다.")
                isLoading = false
                return
            }

            // 현재 월 지출이 이미 있는지 확인
            let currentExpenses: [MonthlyExpense] = try await firestoreService.queryDocuments(
                userId: userId,
                collectionName: collectionName,
                field: "yearMonth",
                isEqualTo: toYearMonth
            )

            // 현재 월에 이미 지출이 있으면 중복되지 않은 카테고리만 복사
            let existingCategoryIds = Set(currentExpenses.map { $0.categoryId })

            let now = Date()
            var copiedCount = 0

            for previousExpense in previousExpenses {
                // 이미 존재하는 카테고리는 건너뛰기
                if existingCategoryIds.contains(previousExpense.categoryId) {
                    continue
                }

                var newExpense = MonthlyExpense(
                    yearMonth: toYearMonth,
                    categoryId: previousExpense.categoryId,
                    amount: previousExpense.amount,
                    createdAt: now
                )

                do {
                    let documentId = try await firestoreService.addDocument(
                        newExpense,
                        userId: userId,
                        collectionName: collectionName
                    )

                    newExpense.id = documentId
                    expenses.append(newExpense)
                    copiedCount += 1
                } catch {
                    print("❌ [ExpenseService] 지출 복사 실패 (categoryId: \(previousExpense.categoryId))")
                }
            }

            print("✅ [ExpenseService] \(copiedCount)개 지출 복사 완료: \(fromYearMonth) → \(toYearMonth)")
            isLoading = false
        } catch {
            errorMessage = "전월 지출 복사 실패: \(error.localizedDescription)"
            print("❌ [ExpenseService] 복사 실패: \(error.localizedDescription)")
            isLoading = false
            throw error
        }
    }

    // MARK: - Helper Methods

    /// 특정 월의 총 지출 계산
    /// - Parameter yearMonth: 년월 (예: "2026-01")
    /// - Returns: 총 지출
    func getTotalExpense(for yearMonth: String) -> Int {
        return expenses
            .filter { $0.yearMonth == yearMonth }
            .reduce(0) { $0 + $1.amount }
    }

    /// 카테고리별 지출 금액 조회
    /// - Parameters:
    ///   - yearMonth: 년월
    ///   - categoryId: 카테고리 ID
    /// - Returns: 지출 금액 (없으면 0)
    func getExpenseAmount(yearMonth: String, categoryId: String) -> Int {
        return expenses.first { $0.yearMonth == yearMonth && $0.categoryId == categoryId }?.amount ?? 0
    }

    /// 지출 목록 초기화
    func clearExpenses() {
        expenses.removeAll()
    }

    /// 카테고리별로 지출 그룹화
    /// - Returns: [categoryId: MonthlyExpense]
    func groupExpensesByCategory() -> [String: MonthlyExpense] {
        var grouped: [String: MonthlyExpense] = [:]
        for expense in expenses {
            grouped[expense.categoryId] = expense
        }
        return grouped
    }
}

// MARK: - Expense Errors

enum ExpenseError: LocalizedError {
    case invalidYearMonth
    case invalidCategoryId
    case notFound

    var errorDescription: String? {
        switch self {
        case .invalidYearMonth:
            return "유효하지 않은 년월 형식입니다."
        case .invalidCategoryId:
            return "유효하지 않은 카테고리 ID입니다."
        case .notFound:
            return "지출을 찾을 수 없습니다."
        }
    }
}
