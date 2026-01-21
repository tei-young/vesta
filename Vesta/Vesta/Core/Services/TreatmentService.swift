//
//  TreatmentService.swift
//  Vesta
//
//  Created on 2026-01-21.
//

import Foundation
import Combine
import FirebaseFirestore

/// 시술 관리 서비스
@MainActor
class TreatmentService: ObservableObject {
    // MARK: - Properties

    static let shared = TreatmentService()
    private let firestoreService = FirestoreService.shared
    private let collectionName = "treatments"

    @Published var treatments: [Treatment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private init() {}

    // MARK: - Fetch Treatments

    /// 시술 목록 조회
    /// - Parameter userId: 사용자 ID
    func fetchTreatments(userId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedTreatments: [Treatment] = try await firestoreService.getDocuments(
                userId: userId,
                collectionName: collectionName,
                orderBy: "order",
                descending: false
            )

            self.treatments = fetchedTreatments
            print("✅ [TreatmentService] \(treatments.count)개 시술 조회 완료")
        } catch {
            errorMessage = "시술 목록 조회 실패: \(error.localizedDescription)"
            print("❌ [TreatmentService] 조회 실패: \(error.localizedDescription)")
        }

        isLoading = false
    }

    // MARK: - Add Treatment

    /// 시술 추가
    /// - Parameters:
    ///   - name: 시술명
    ///   - price: 가격
    ///   - icon: 아이콘 (이모지)
    ///   - color: 색상 (HEX)
    ///   - userId: 사용자 ID
    /// - Returns: 생성된 시술 ID
    @discardableResult
    func addTreatment(
        name: String,
        price: Int,
        icon: String?,
        color: String,
        userId: String
    ) async throws -> String {
        isLoading = true
        errorMessage = nil

        // 현재 최대 order 값 계산
        let maxOrder = treatments.map { $0.order }.max() ?? -1
        let newOrder = maxOrder + 1

        let now = Date()
        var newTreatment = Treatment(
            name: name,
            price: price,
            icon: icon,
            color: color,
            order: newOrder,
            createdAt: now,
            updatedAt: now
        )

        do {
            let documentId = try await firestoreService.addDocument(
                newTreatment,
                userId: userId,
                collectionName: collectionName
            )

            // ID 할당 후 로컬 배열에 추가
            newTreatment.id = documentId
            treatments.append(newTreatment)
            treatments.sort { $0.order < $1.order }

            print("✅ [TreatmentService] 시술 추가 성공: \(name)")
            isLoading = false
            return documentId
        } catch {
            errorMessage = "시술 추가 실패: \(error.localizedDescription)"
            print("❌ [TreatmentService] 추가 실패: \(error.localizedDescription)")
            isLoading = false
            throw error
        }
    }

    // MARK: - Update Treatment

    /// 시술 수정
    /// - Parameters:
    ///   - treatment: 수정할 시술 객체
    ///   - userId: 사용자 ID
    func updateTreatment(_ treatment: Treatment, userId: String) async throws {
        guard let documentId = treatment.id else {
            throw TreatmentError.invalidId
        }

        isLoading = true
        errorMessage = nil

        let updateData: [String: Any] = [
            "name": treatment.name,
            "price": treatment.price,
            "icon": treatment.icon as Any,
            "color": treatment.color,
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
            if let index = treatments.firstIndex(where: { $0.id == documentId }) {
                var updatedTreatment = treatment
                updatedTreatment.updatedAt = Date()
                treatments[index] = updatedTreatment
            }

            print("✅ [TreatmentService] 시술 수정 성공: \(treatment.name)")
            isLoading = false
        } catch {
            errorMessage = "시술 수정 실패: \(error.localizedDescription)"
            print("❌ [TreatmentService] 수정 실패: \(error.localizedDescription)")
            isLoading = false
            throw error
        }
    }

    // MARK: - Delete Treatment

    /// 시술 삭제
    /// - Parameters:
    ///   - id: 시술 ID
    ///   - userId: 사용자 ID
    func deleteTreatment(id: String, userId: String) async throws {
        isLoading = true
        errorMessage = nil

        do {
            try await firestoreService.deleteDocument(
                documentId: id,
                userId: userId,
                collectionName: collectionName
            )

            // 로컬 배열에서 제거
            treatments.removeAll { $0.id == id }

            print("✅ [TreatmentService] 시술 삭제 성공: \(id)")
            isLoading = false
        } catch {
            errorMessage = "시술 삭제 실패: \(error.localizedDescription)"
            print("❌ [TreatmentService] 삭제 실패: \(error.localizedDescription)")
            isLoading = false
            throw error
        }
    }

    // MARK: - Reorder Treatments

    /// 시술 순서 변경
    /// - Parameters:
    ///   - reorderedTreatments: 순서가 변경된 시술 배열
    ///   - userId: 사용자 ID
    func reorderTreatments(_ reorderedTreatments: [Treatment], userId: String) async throws {
        isLoading = true
        errorMessage = nil

        // order 값 재할당
        var updates: [(documentId: String, data: [String: Any])] = []

        for (index, treatment) in reorderedTreatments.enumerated() {
            guard let documentId = treatment.id else { continue }

            let updateData: [String: Any] = [
                "order": index,
                "updatedAt": Timestamp(date: Date())
            ]

            updates.append((documentId: documentId, data: updateData))
        }

        do {
            try await firestoreService.batchUpdate(
                updates: updates,
                userId: userId,
                collectionName: collectionName
            )

            // 로컬 배열 업데이트
            self.treatments = reorderedTreatments.enumerated().map { index, treatment in
                var updatedTreatment = treatment
                updatedTreatment.order = index
                updatedTreatment.updatedAt = Date()
                return updatedTreatment
            }

            print("✅ [TreatmentService] 시술 순서 변경 성공")
            isLoading = false
        } catch {
            errorMessage = "시술 순서 변경 실패: \(error.localizedDescription)"
            print("❌ [TreatmentService] 순서 변경 실패: \(error.localizedDescription)")
            isLoading = false
            throw error
        }
    }

    // MARK: - Helper Methods

    /// ID로 시술 찾기
    /// - Parameter id: 시술 ID
    /// - Returns: Treatment 객체 (없으면 nil)
    func getTreatment(byId id: String) -> Treatment? {
        return treatments.first { $0.id == id }
    }

    /// 시술 목록 초기화
    func clearTreatments() {
        treatments.removeAll()
    }
}

// MARK: - Treatment Errors

enum TreatmentError: LocalizedError {
    case invalidId
    case notFound

    var errorDescription: String? {
        switch self {
        case .invalidId:
            return "유효하지 않은 시술 ID입니다."
        case .notFound:
            return "시술을 찾을 수 없습니다."
        }
    }
}
