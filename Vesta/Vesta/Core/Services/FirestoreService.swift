//
//  FirestoreService.swift
//  Vesta
//
//  Created on 2026-01-21.
//

import Foundation
import FirebaseFirestore

/// Firestore 기본 CRUD 유틸리티 서비스
class FirestoreService {
    // MARK: - Properties

    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    private init() {}

    // MARK: - User Collection Reference

    /// 사용자별 컬렉션 참조 생성
    /// - Parameters:
    ///   - userId: 사용자 ID
    ///   - collectionName: 컬렉션 이름 (treatments, dailyRecords, dailyAdjustments, expenseCategories, monthlyExpenses)
    /// - Returns: CollectionReference
    func getUserCollection(userId: String, collectionName: String) -> CollectionReference {
        return db.collection("users").document(userId).collection(collectionName)
    }

    // MARK: - Generic CRUD Operations

    /// 문서 추가
    /// - Parameters:
    ///   - data: Encodable 데이터
    ///   - userId: 사용자 ID
    ///   - collectionName: 컬렉션 이름
    /// - Returns: 생성된 문서 ID
    func addDocument<T: Encodable>(
        _ data: T,
        userId: String,
        collectionName: String
    ) async throws -> String {
        let collection = getUserCollection(userId: userId, collectionName: collectionName)

        do {
            let encoder = Firestore.Encoder()
            let encodedData = try encoder.encode(data)
            let docRef = try await collection.addDocument(data: encodedData)
            print("✅ [\(collectionName)] 문서 추가 성공: \(docRef.documentID)")
            return docRef.documentID
        } catch {
            print("❌ [\(collectionName)] 문서 추가 실패: \(error.localizedDescription)")
            throw FirestoreError.addFailed(error.localizedDescription)
        }
    }

    /// 문서 추가 (특정 ID로)
    /// - Parameters:
    ///   - data: Encodable 데이터
    ///   - documentId: 문서 ID
    ///   - userId: 사용자 ID
    ///   - collectionName: 컬렉션 이름
    func setDocument<T: Encodable>(
        _ data: T,
        documentId: String,
        userId: String,
        collectionName: String
    ) async throws {
        let docRef = getUserCollection(userId: userId, collectionName: collectionName)
            .document(documentId)

        do {
            let encoder = Firestore.Encoder()
            let encodedData = try encoder.encode(data)
            try await docRef.setData(encodedData)
            print("✅ [\(collectionName)] 문서 설정 성공: \(documentId)")
        } catch {
            print("❌ [\(collectionName)] 문서 설정 실패: \(error.localizedDescription)")
            throw FirestoreError.updateFailed(error.localizedDescription)
        }
    }

    /// 문서 업데이트
    /// - Parameters:
    ///   - documentId: 문서 ID
    ///   - data: 업데이트할 필드와 값
    ///   - userId: 사용자 ID
    ///   - collectionName: 컬렉션 이름
    func updateDocument(
        documentId: String,
        data: [String: Any],
        userId: String,
        collectionName: String
    ) async throws {
        let docRef = getUserCollection(userId: userId, collectionName: collectionName)
            .document(documentId)

        do {
            try await docRef.updateData(data)
            print("✅ [\(collectionName)] 문서 업데이트 성공: \(documentId)")
        } catch {
            print("❌ [\(collectionName)] 문서 업데이트 실패: \(error.localizedDescription)")
            throw FirestoreError.updateFailed(error.localizedDescription)
        }
    }

    /// 문서 삭제
    /// - Parameters:
    ///   - documentId: 문서 ID
    ///   - userId: 사용자 ID
    ///   - collectionName: 컬렉션 이름
    func deleteDocument(
        documentId: String,
        userId: String,
        collectionName: String
    ) async throws {
        let docRef = getUserCollection(userId: userId, collectionName: collectionName)
            .document(documentId)

        do {
            try await docRef.delete()
            print("✅ [\(collectionName)] 문서 삭제 성공: \(documentId)")
        } catch {
            print("❌ [\(collectionName)] 문서 삭제 실패: \(error.localizedDescription)")
            throw FirestoreError.deleteFailed(error.localizedDescription)
        }
    }

    /// 단일 문서 조회
    /// - Parameters:
    ///   - documentId: 문서 ID
    ///   - userId: 사용자 ID
    ///   - collectionName: 컬렉션 이름
    /// - Returns: Decodable 데이터
    func getDocument<T: Decodable>(
        documentId: String,
        userId: String,
        collectionName: String
    ) async throws -> T {
        let docRef = getUserCollection(userId: userId, collectionName: collectionName)
            .document(documentId)

        do {
            let snapshot = try await docRef.getDocument()

            guard snapshot.exists else {
                throw FirestoreError.documentNotFound
            }

            let decoder = Firestore.Decoder()
            let data = try decoder.decode(T.self, from: snapshot.data() ?? [:])
            print("✅ [\(collectionName)] 문서 조회 성공: \(documentId)")
            return data
        } catch {
            print("❌ [\(collectionName)] 문서 조회 실패: \(error.localizedDescription)")
            throw FirestoreError.fetchFailed(error.localizedDescription)
        }
    }

    /// 컬렉션 전체 조회
    /// - Parameters:
    ///   - userId: 사용자 ID
    ///   - collectionName: 컬렉션 이름
    ///   - orderBy: 정렬 필드 (선택)
    ///   - descending: 내림차순 여부 (기본: false)
    /// - Returns: Decodable 데이터 배열
    func getDocuments<T: Decodable>(
        userId: String,
        collectionName: String,
        orderBy: String? = nil,
        descending: Bool = false
    ) async throws -> [T] {
        var query: Query = getUserCollection(userId: userId, collectionName: collectionName)

        if let orderBy = orderBy {
            query = query.order(by: orderBy, descending: descending)
        }

        do {
            let snapshot = try await query.getDocuments()

            print("🔍 [\(collectionName)] Firestore에서 \(snapshot.documents.count)개 문서 가져옴")

            let documents = snapshot.documents.compactMap { doc -> T? in
                do {
                    // Firestore SDK의 내장 메서드 사용 - @DocumentID 자동 처리
                    let decoded = try doc.data(as: T.self)
                    return decoded
                } catch {
                    print("❌ [\(collectionName)] 디코딩 실패 - docId: \(doc.documentID), error: \(error)")
                    print("   데이터: \(doc.data())")
                    return nil
                }
            }

            print("✅ [\(collectionName)] \(documents.count)개 문서 조회 성공 (총 \(snapshot.documents.count)개 중)")
            return documents
        } catch {
            print("❌ [\(collectionName)] 문서 조회 실패: \(error.localizedDescription)")
            throw FirestoreError.fetchFailed(error.localizedDescription)
        }
    }

    /// 쿼리를 사용한 문서 조회
    /// - Parameters:
    ///   - userId: 사용자 ID
    ///   - collectionName: 컬렉션 이름
    ///   - field: 쿼리 필드
    ///   - isEqualTo: 비교 값
    /// - Returns: Decodable 데이터 배열
    func queryDocuments<T: Decodable>(
        userId: String,
        collectionName: String,
        field: String,
        isEqualTo value: Any
    ) async throws -> [T] {
        let query = getUserCollection(userId: userId, collectionName: collectionName)
            .whereField(field, isEqualTo: value)

        do {
            let snapshot = try await query.getDocuments()

            print("🔍 [\(collectionName)] 쿼리로 \(snapshot.documents.count)개 문서 가져옴")

            let documents = snapshot.documents.compactMap { doc -> T? in
                do {
                    // Firestore SDK의 내장 메서드 사용 - @DocumentID 자동 처리
                    let decoded = try doc.data(as: T.self)
                    return decoded
                } catch {
                    print("❌ [\(collectionName)] 디코딩 실패 - docId: \(doc.documentID), error: \(error)")
                    print("   데이터: \(doc.data())")
                    return nil
                }
            }

            print("✅ [\(collectionName)] 쿼리 결과 \(documents.count)개 문서 조회 성공 (총 \(snapshot.documents.count)개 중)")
            return documents
        } catch {
            print("❌ [\(collectionName)] 쿼리 실패: \(error.localizedDescription)")
            throw FirestoreError.fetchFailed(error.localizedDescription)
        }
    }

    /// 배치 업데이트 (순서 변경 등)
    /// - Parameters:
    ///   - updates: [(documentId, data)] 배열
    ///   - userId: 사용자 ID
    ///   - collectionName: 컬렉션 이름
    func batchUpdate(
        updates: [(documentId: String, data: [String: Any])],
        userId: String,
        collectionName: String
    ) async throws {
        let batch = db.batch()
        let collection = getUserCollection(userId: userId, collectionName: collectionName)

        for update in updates {
            let docRef = collection.document(update.documentId)
            batch.updateData(update.data, forDocument: docRef)
        }

        do {
            try await batch.commit()
            print("✅ [\(collectionName)] 배치 업데이트 성공: \(updates.count)개 문서")
        } catch {
            print("❌ [\(collectionName)] 배치 업데이트 실패: \(error.localizedDescription)")
            throw FirestoreError.updateFailed(error.localizedDescription)
        }
    }
}

// MARK: - Firestore Errors

enum FirestoreError: LocalizedError {
    case addFailed(String)
    case updateFailed(String)
    case deleteFailed(String)
    case fetchFailed(String)
    case documentNotFound
    case encodingFailed
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .addFailed(let message):
            return "데이터 추가 실패: \(message)"
        case .updateFailed(let message):
            return "데이터 업데이트 실패: \(message)"
        case .deleteFailed(let message):
            return "데이터 삭제 실패: \(message)"
        case .fetchFailed(let message):
            return "데이터 조회 실패: \(message)"
        case .documentNotFound:
            return "문서를 찾을 수 없습니다."
        case .encodingFailed:
            return "데이터 인코딩 실패"
        case .decodingFailed:
            return "데이터 디코딩 실패"
        }
    }
}
