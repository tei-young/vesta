//
//  DailyRecord.swift
//  Vesta
//
//  Created on 2026-01-19.
//

import Foundation
import FirebaseFirestore

struct DailyRecord: Identifiable, Codable {
    @DocumentID var id: String?
    var date: Date
    var treatmentId: String
    var count: Int
    var totalAmount: Int
    var createdAt: Date

    // 로컬 조인용 (Firestore에 저장되지 않음)
    var treatment: Treatment?

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case treatmentId = "treatment_id"
        case count
        case totalAmount = "total_amount"
        case createdAt = "created_at"
    }
}

extension DailyRecord {
    /// 새 기록 생성을 위한 초기화
    init(date: Date, treatmentId: String, count: Int, totalAmount: Int) {
        self.date = date.startOfDay()
        self.treatmentId = treatmentId
        self.count = count
        self.totalAmount = totalAmount
        self.createdAt = Date()
    }

    /// 단가 계산
    var unitPrice: Int {
        guard count > 0 else { return 0 }
        return totalAmount / count
    }
}
