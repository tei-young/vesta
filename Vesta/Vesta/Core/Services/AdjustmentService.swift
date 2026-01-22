//
//  AdjustmentService.swift
//  Vesta
//
//  Created on 2026-01-21.
//

import Foundation
import Combine
import FirebaseFirestore

/// 조정 금액 관리 서비스 (할인, 팁 등)
@MainActor
class AdjustmentService: ObservableObject {
    // MARK: - Properties

    static let shared = AdjustmentService()
    private let firestoreService = FirestoreService.shared
    private let collectionName = "dailyAdjustments"

    @Published var adjustments: [DailyAdjustment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private init() {}

    // MARK: - Fetch Adjustments

    /// 특정 날짜의 조정 조회
    /// - Parameters:
    ///   - userId: 사용자 ID
    ///   - date: 조회할 날짜
    func fetchAdjustments(userId: String, date: Date) async {
        isLoading = true
        errorMessage = nil

        let targetDate = date.startOfDay()

        do {
            let fetchedAdjustments: [DailyAdjustment] = try await firestoreService.queryDocuments(
                userId: userId,
                collectionName: collectionName,
                field: "date",
                isEqualTo: Timestamp(date: targetDate)
            )

            self.adjustments = fetchedAdjustments
            print("✅ [AdjustmentService] \(fetchedAdjustments.count)개 조정 조회 완료 (\(date.toDisplayString()))")
        } catch {
            errorMessage = "조정 조회 실패: \(error.localizedDescription)"
            print("❌ [AdjustmentService] 조회 실패: \(error.localizedDescription)")
        }

        isLoading = false
    }

    /// 월별 조정 조회
    /// - Parameters:
    ///   - userId: 사용자 ID
    ///   - year: 년
    ///   - month: 월 (1-12)
    func fetchMonthlyAdjustments(userId: String, year: Int, month: Int) async -> [DailyAdjustment] {
        isLoading = true
        errorMessage = nil

        // 해당 월의 시작일과 종료일
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1

        guard let startDate = Calendar.current.date(from: components),
              let endDate = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startDate) else {
            isLoading = false
            return []
        }

        do {
            let query = firestoreService.getUserCollection(userId: userId, collectionName: collectionName)
                .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startDate.startOfDay()))
                .whereField("date", isLessThanOrEqualTo: Timestamp(date: endDate.endOfDay()))

            let snapshot = try await query.getDocuments()
            let decoder = Firestore.Decoder()

            let monthlyAdjustments = snapshot.documents.compactMap { doc -> DailyAdjustment? in
                try? decoder.decode(DailyAdjustment.self, from: doc.data())
            }

            print("✅ [AdjustmentService] \(monthlyAdjustments.count)개 월별 조정 조회 완료 (\(year)-\(String(format: "%02d", month)))")
            isLoading = false
            return monthlyAdjustments
        } catch {
            errorMessage = "월별 조정 조회 실패: \(error.localizedDescription)"
            print("❌ [AdjustmentService] 월별 조회 실패: \(error.localizedDescription)")
            isLoading = false
            return []
        }
    }

    // MARK: - Add Adjustment

    /// 조정 추가
    /// - Parameters:
    ///   - userId: 사용자 ID
    ///   - date: 날짜
    ///   - amount: 금액 (음수: 할인, 양수: 팁/추가금액)
    ///   - reason: 사유 (선택)
    /// - Returns: 생성된 조정 ID
    @discardableResult
    func addAdjustment(
        userId: String,
        date: Date,
        amount: Int,
        reason: String?
    ) async throws -> String {
        isLoading = true
        errorMessage = nil

        let targetDate = date.startOfDay()
        let now = Date()

        var newAdjustment = DailyAdjustment(
            date: targetDate,
            amount: amount,
            reason: reason,
            createdAt: now
        )

        do {
            let documentId = try await firestoreService.addDocument(
                newAdjustment,
                userId: userId,
                collectionName: collectionName
            )

            // 로컬 배열에 추가
            newAdjustment.id = documentId
            adjustments.append(newAdjustment)

            let type = amount < 0 ? "할인" : "추가금액"
            print("✅ [AdjustmentService] \(type) 추가 성공: \(amount.formattedCurrency)")
            isLoading = false
            return documentId
        } catch {
            errorMessage = "조정 추가 실패: \(error.localizedDescription)"
            print("❌ [AdjustmentService] 추가 실패: \(error.localizedDescription)")
            isLoading = false
            throw error
        }
    }

    // MARK: - Update Adjustment

    /// 조정 수정
    /// - Parameters:
    ///   - adjustment: 수정할 조정 객체
    ///   - userId: 사용자 ID
    func updateAdjustment(_ adjustment: DailyAdjustment, userId: String) async throws {
        guard let documentId = adjustment.id else {
            throw AdjustmentError.invalidId
        }

        isLoading = true
        errorMessage = nil

        let updateData: [String: Any] = [
            "amount": adjustment.amount,
            "reason": adjustment.reason as Any,
            "updatedAt": Timestamp(date: Date())
        ]

        do {
            try await firestoreService.updateDocument(
                documentId: documentId,
                data: updateData,
                userId: userId,
                collectionName: collectionName
            )

            // 로컬 배열 업데이트
            if let index = adjustments.firstIndex(where: { $0.id == documentId }) {
                adjustments[index] = adjustment
            }

            print("✅ [AdjustmentService] 조정 수정 성공")
            isLoading = false
        } catch {
            errorMessage = "조정 수정 실패: \(error.localizedDescription)"
            print("❌ [AdjustmentService] 수정 실패: \(error.localizedDescription)")
            isLoading = false
            throw error
        }
    }

    // MARK: - Delete Adjustment

    /// 조정 삭제
    /// - Parameters:
    ///   - id: 조정 ID
    ///   - userId: 사용자 ID
    func deleteAdjustment(id: String, userId: String) async throws {
        isLoading = true
        errorMessage = nil

        do {
            try await firestoreService.deleteDocument(
                documentId: id,
                userId: userId,
                collectionName: collectionName
            )

            // 로컬 배열에서 제거
            adjustments.removeAll { $0.id == id }

            print("✅ [AdjustmentService] 조정 삭제 성공: \(id)")
            isLoading = false
        } catch {
            errorMessage = "조정 삭제 실패: \(error.localizedDescription)"
            print("❌ [AdjustmentService] 삭제 실패: \(error.localizedDescription)")
            isLoading = false
            throw error
        }
    }

    // MARK: - Helper Methods

    /// 특정 날짜의 총 조정 금액 계산
    /// - Parameter date: 날짜
    /// - Returns: 총 조정 금액 (음수면 할인, 양수면 추가)
    func getTotalAdjustment(for date: Date) -> Int {
        let targetDate = date.startOfDay()
        return adjustments
            .filter { $0.date.startOfDay() == targetDate }
            .reduce(0) { $0 + $1.amount }
    }

    /// 할인 금액만 계산
    /// - Parameter date: 날짜
    /// - Returns: 총 할인 금액 (음수)
    func getTotalDiscount(for date: Date) -> Int {
        let targetDate = date.startOfDay()
        return adjustments
            .filter { $0.date.startOfDay() == targetDate && $0.amount < 0 }
            .reduce(0) { $0 + $1.amount }
    }

    /// 추가 금액만 계산
    /// - Parameter date: 날짜
    /// - Returns: 총 추가 금액 (양수)
    func getTotalExtra(for date: Date) -> Int {
        let targetDate = date.startOfDay()
        return adjustments
            .filter { $0.date.startOfDay() == targetDate && $0.amount > 0 }
            .reduce(0) { $0 + $1.amount }
    }

    /// 조정 목록 초기화
    func clearAdjustments() {
        adjustments.removeAll()
    }
}

// MARK: - Adjustment Errors

enum AdjustmentError: LocalizedError {
    case invalidId
    case notFound

    var errorDescription: String? {
        switch self {
        case .invalidId:
            return "유효하지 않은 조정 ID입니다."
        case .notFound:
            return "조정을 찾을 수 없습니다."
        }
    }
}
