//
//  RecordService.swift
//  Vesta
//
//  Created on 2026-01-21.
//

import Foundation
import Combine
import FirebaseFirestore

/// 일별 기록 관리 서비스
@MainActor
class RecordService: ObservableObject {
    // MARK: - Properties

    static let shared = RecordService()
    private let firestoreService = FirestoreService.shared
    private let collectionName = "dailyRecords"

    @Published var records: [DailyRecord] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private init() {}

    // MARK: - Fetch Records

    /// 특정 날짜의 기록 조회
    /// - Parameters:
    ///   - userId: 사용자 ID
    ///   - date: 조회할 날짜
    func fetchRecords(userId: String, date: Date) async {
        isLoading = true
        errorMessage = nil

        let targetDate = date.startOfDay()

        do {
            let fetchedRecords: [DailyRecord] = try await firestoreService.queryDocuments(
                userId: userId,
                collectionName: collectionName,
                field: "date",
                isEqualTo: Timestamp(date: targetDate)
            )

            self.records = fetchedRecords
            print("✅ [RecordService] \(fetchedRecords.count)개 기록 조회 완료 (\(date.toDisplayString()))")
        } catch {
            errorMessage = "기록 조회 실패: \(error.localizedDescription)"
            print("❌ [RecordService] 조회 실패: \(error.localizedDescription)")
        }

        isLoading = false
    }

    /// 월별 기록 조회
    /// - Parameters:
    ///   - userId: 사용자 ID
    ///   - year: 년
    ///   - month: 월 (1-12)
    func fetchMonthlyRecords(userId: String, year: Int, month: Int) async -> [DailyRecord] {
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
            // Firestore 쿼리: date >= startDate AND date <= endDate
            let query = firestoreService.getUserCollection(userId: userId, collectionName: collectionName)
                .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startDate.startOfDay()))
                .whereField("date", isLessThanOrEqualTo: Timestamp(date: endDate.endOfDay()))

            let snapshot = try await query.getDocuments()

            print("🔍 [RecordService] Firestore에서 \(snapshot.documents.count)개 문서 가져옴 (\(year)-\(String(format: "%02d", month)))")

            let monthlyRecords = snapshot.documents.compactMap { doc -> DailyRecord? in
                do {
                    let decoded = try doc.data(as: DailyRecord.self)
                    return decoded
                } catch {
                    print("❌ [RecordService] 디코딩 실패 - docId: \(doc.documentID), error: \(error)")
                    return nil
                }
            }

            print("✅ [RecordService] \(monthlyRecords.count)개 월별 기록 조회 완료 (총 \(snapshot.documents.count)개 중)")
            isLoading = false
            return monthlyRecords
        } catch {
            errorMessage = "월별 기록 조회 실패: \(error.localizedDescription)"
            print("❌ [RecordService] 월별 조회 실패: \(error.localizedDescription)")
            isLoading = false
            return []
        }
    }

    // MARK: - Add or Update Record

    /// 기록 추가 또는 업데이트
    /// - Parameters:
    ///   - userId: 사용자 ID
    ///   - date: 날짜
    ///   - treatmentId: 시술 ID
    ///   - price: 가격
    /// - Returns: 생성/업데이트된 기록 ID
    @discardableResult
    func addOrUpdateRecord(
        userId: String,
        date: Date,
        treatmentId: String,
        price: Int
    ) async throws -> String {
        isLoading = true
        errorMessage = nil

        let targetDate = date.startOfDay()

        // 해당 날짜 + 시술 ID로 기존 기록 찾기
        let existingRecord = records.first { record in
            record.date.startOfDay() == targetDate && record.treatmentId == treatmentId
        }

        do {
            if let existing = existingRecord, let existingId = existing.id {
                // 기존 기록 업데이트 (count +1)
                let newCount = existing.count + 1
                let newTotalAmount = existing.totalAmount + price

                let updateData: [String: Any] = [
                    "count": newCount,
                    "totalAmount": newTotalAmount,
                    "updatedAt": Timestamp(date: Date())
                ]

                try await firestoreService.updateDocument(
                    documentId: existingId,
                    data: updateData,
                    userId: userId,
                    collectionName: collectionName
                )

                // 로컬 배열 업데이트
                if let index = records.firstIndex(where: { $0.id == existingId }) {
                    records[index].count = newCount
                    records[index].totalAmount = newTotalAmount
                }

                print("✅ [RecordService] 기록 업데이트 성공: count=\(newCount)")
                isLoading = false
                return existingId
            } else {
                // 새 기록 추가
                let now = Date()
                var newRecord = DailyRecord(
                    date: targetDate,
                    treatmentId: treatmentId,
                    count: 1,
                    totalAmount: price,
                    createdAt: now
                )

                let documentId = try await firestoreService.addDocument(
                    newRecord,
                    userId: userId,
                    collectionName: collectionName
                )

                // 로컬 배열에 추가
                newRecord.id = documentId
                records.append(newRecord)

                print("✅ [RecordService] 기록 추가 성공")
                isLoading = false
                return documentId
            }
        } catch {
            errorMessage = "기록 추가/수정 실패: \(error.localizedDescription)"
            print("❌ [RecordService] 추가/수정 실패: \(error.localizedDescription)")
            isLoading = false
            throw error
        }
    }

    // MARK: - Update Record Count

    /// 기록 수량 변경
    /// - Parameters:
    ///   - id: 기록 ID
    ///   - count: 새 수량
    ///   - totalAmount: 새 총액
    ///   - userId: 사용자 ID
    func updateRecordCount(
        id: String,
        count: Int,
        totalAmount: Int,
        userId: String
    ) async throws {
        guard count > 0 else {
            // count가 0이면 삭제
            try await deleteRecord(id: id, userId: userId)
            return
        }

        isLoading = true
        errorMessage = nil

        let updateData: [String: Any] = [
            "count": count,
            "totalAmount": totalAmount,
            "updatedAt": Timestamp(date: Date())
        ]

        do {
            try await firestoreService.updateDocument(
                documentId: id,
                data: updateData,
                userId: userId,
                collectionName: collectionName
            )

            // 로컬 배열 업데이트
            if let index = records.firstIndex(where: { $0.id == id }) {
                records[index].count = count
                records[index].totalAmount = totalAmount
            }

            print("✅ [RecordService] 기록 수량 변경 성공: count=\(count)")
            isLoading = false
        } catch {
            errorMessage = "기록 수량 변경 실패: \(error.localizedDescription)"
            print("❌ [RecordService] 수량 변경 실패: \(error.localizedDescription)")
            isLoading = false
            throw error
        }
    }

    // MARK: - Delete Record

    /// 기록 삭제
    /// - Parameters:
    ///   - id: 기록 ID
    ///   - userId: 사용자 ID
    func deleteRecord(id: String, userId: String) async throws {
        isLoading = true
        errorMessage = nil

        do {
            try await firestoreService.deleteDocument(
                documentId: id,
                userId: userId,
                collectionName: collectionName
            )

            // 로컬 배열에서 제거
            records.removeAll { $0.id == id }

            print("✅ [RecordService] 기록 삭제 성공: \(id)")
            isLoading = false
        } catch {
            errorMessage = "기록 삭제 실패: \(error.localizedDescription)"
            print("❌ [RecordService] 삭제 실패: \(error.localizedDescription)")
            isLoading = false
            throw error
        }
    }

    // MARK: - Helper Methods

    /// 특정 날짜의 총 매출 계산
    /// - Parameter date: 날짜
    /// - Returns: 총 매출
    func getTotalRevenue(for date: Date) -> Int {
        let targetDate = date.startOfDay()
        return records
            .filter { $0.date.startOfDay() == targetDate }
            .reduce(0) { $0 + $1.totalAmount }
    }

    /// 기록 목록 초기화
    func clearRecords() {
        records.removeAll()
    }

    /// 시술별로 기록 그룹화
    /// - Returns: [treatmentId: [DailyRecord]]
    func groupRecordsByTreatment() -> [String: [DailyRecord]] {
        return Dictionary(grouping: records) { $0.treatmentId }
    }
}
