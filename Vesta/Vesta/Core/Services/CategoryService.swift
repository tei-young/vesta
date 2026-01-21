//
//  CategoryService.swift
//  Vesta
//
//  Created on 2026-01-21.
//

import Foundation
import FirebaseFirestore

/// 지출 카테고리 관리 서비스
@MainActor
class CategoryService: ObservableObject {
    // MARK: - Properties

    static let shared = CategoryService()
    private let firestoreService = FirestoreService.shared
    private let collectionName = "expenseCategories"

    @Published var categories: [ExpenseCategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private init() {}

    // MARK: - Fetch Categories

    /// 지출 카테고리 목록 조회
    /// - Parameter userId: 사용자 ID
    func fetchCategories(userId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedCategories: [ExpenseCategory] = try await firestoreService.getDocuments(
                userId: userId,
                collectionName: collectionName,
                orderBy: "order",
                descending: false
            )

            self.categories = fetchedCategories
            print("✅ [CategoryService] \(categories.count)개 카테고리 조회 완료")
        } catch {
            errorMessage = "카테고리 목록 조회 실패: \(error.localizedDescription)"
            print("❌ [CategoryService] 조회 실패: \(error.localizedDescription)")
        }

        isLoading = false
    }

    // MARK: - Add Category

    /// 지출 카테고리 추가
    /// - Parameters:
    ///   - name: 카테고리명
    ///   - icon: 아이콘 (이모지)
    ///   - userId: 사용자 ID
    /// - Returns: 생성된 카테고리 ID
    @discardableResult
    func addCategory(
        name: String,
        icon: String?,
        userId: String
    ) async throws -> String {
        isLoading = true
        errorMessage = nil

        // 현재 최대 order 값 계산
        let maxOrder = categories.map { $0.order }.max() ?? -1
        let newOrder = maxOrder + 1

        let now = Date()
        var newCategory = ExpenseCategory(
            name: name,
            icon: icon,
            order: newOrder,
            createdAt: now
        )

        do {
            let documentId = try await firestoreService.addDocument(
                newCategory,
                userId: userId,
                collectionName: collectionName
            )

            // ID 할당 후 로컬 배열에 추가
            newCategory.id = documentId
            categories.append(newCategory)
            categories.sort { $0.order < $1.order }

            print("✅ [CategoryService] 카테고리 추가 성공: \(name)")
            isLoading = false
            return documentId
        } catch {
            errorMessage = "카테고리 추가 실패: \(error.localizedDescription)"
            print("❌ [CategoryService] 추가 실패: \(error.localizedDescription)")
            isLoading = false
            throw error
        }
    }

    // MARK: - Update Category

    /// 지출 카테고리 수정
    /// - Parameters:
    ///   - category: 수정할 카테고리 객체
    ///   - userId: 사용자 ID
    func updateCategory(_ category: ExpenseCategory, userId: String) async throws {
        guard let documentId = category.id else {
            throw CategoryError.invalidId
        }

        isLoading = true
        errorMessage = nil

        let updateData: [String: Any] = [
            "name": category.name,
            "icon": category.icon as Any,
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
            if let index = categories.firstIndex(where: { $0.id == documentId }) {
                categories[index] = category
            }

            print("✅ [CategoryService] 카테고리 수정 성공: \(category.name)")
            isLoading = false
        } catch {
            errorMessage = "카테고리 수정 실패: \(error.localizedDescription)"
            print("❌ [CategoryService] 수정 실패: \(error.localizedDescription)")
            isLoading = false
            throw error
        }
    }

    // MARK: - Delete Category

    /// 지출 카테고리 삭제
    /// - Parameters:
    ///   - id: 카테고리 ID
    ///   - userId: 사용자 ID
    func deleteCategory(id: String, userId: String) async throws {
        isLoading = true
        errorMessage = nil

        do {
            try await firestoreService.deleteDocument(
                documentId: id,
                userId: userId,
                collectionName: collectionName
            )

            // 로컬 배열에서 제거
            categories.removeAll { $0.id == id }

            print("✅ [CategoryService] 카테고리 삭제 성공: \(id)")
            isLoading = false
        } catch {
            errorMessage = "카테고리 삭제 실패: \(error.localizedDescription)"
            print("❌ [CategoryService] 삭제 실패: \(error.localizedDescription)")
            isLoading = false
            throw error
        }
    }

    // MARK: - Reorder Categories

    /// 카테고리 순서 변경
    /// - Parameters:
    ///   - reorderedCategories: 순서가 변경된 카테고리 배열
    ///   - userId: 사용자 ID
    func reorderCategories(_ reorderedCategories: [ExpenseCategory], userId: String) async throws {
        isLoading = true
        errorMessage = nil

        // order 값 재할당
        var updates: [(documentId: String, data: [String: Any])] = []

        for (index, category) in reorderedCategories.enumerated() {
            guard let documentId = category.id else { continue }

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
            self.categories = reorderedCategories.enumerated().map { index, category in
                var updatedCategory = category
                updatedCategory.order = index
                return updatedCategory
            }

            print("✅ [CategoryService] 카테고리 순서 변경 성공")
            isLoading = false
        } catch {
            errorMessage = "카테고리 순서 변경 실패: \(error.localizedDescription)"
            print("❌ [CategoryService] 순서 변경 실패: \(error.localizedDescription)")
            isLoading = false
            throw error
        }
    }

    // MARK: - Helper Methods

    /// ID로 카테고리 찾기
    /// - Parameter id: 카테고리 ID
    /// - Returns: ExpenseCategory 객체 (없으면 nil)
    func getCategory(byId id: String) -> ExpenseCategory? {
        return categories.first { $0.id == id }
    }

    /// 카테고리 목록 초기화
    func clearCategories() {
        categories.removeAll()
    }

    // MARK: - Default Categories

    /// 기본 카테고리 생성 (최초 로그인 시)
    /// - Parameter userId: 사용자 ID
    func createDefaultCategories(userId: String) async throws {
        let defaultCategories: [(name: String, icon: String)] = [
            ("재료비", "🧴"),
            ("인건비", "👤"),
            ("월세", "🏠"),
            ("관리비", "🔧"),
            ("기타", "💰")
        ]

        for (index, category) in defaultCategories.enumerated() {
            let now = Date()
            var newCategory = ExpenseCategory(
                name: category.name,
                icon: category.icon,
                order: index,
                createdAt: now
            )

            do {
                let documentId = try await firestoreService.addDocument(
                    newCategory,
                    userId: userId,
                    collectionName: collectionName
                )

                newCategory.id = documentId
                categories.append(newCategory)
            } catch {
                print("❌ [CategoryService] 기본 카테고리 생성 실패: \(category.name)")
            }
        }

        print("✅ [CategoryService] \(defaultCategories.count)개 기본 카테고리 생성 완료")
    }
}

// MARK: - Category Errors

enum CategoryError: LocalizedError {
    case invalidId
    case notFound

    var errorDescription: String? {
        switch self {
        case .invalidId:
            return "유효하지 않은 카테고리 ID입니다."
        case .notFound:
            return "카테고리를 찾을 수 없습니다."
        }
    }
}
