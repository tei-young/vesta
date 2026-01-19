//
//  MonthlyExpense.swift
//  Vesta
//
//  Created on 2026-01-19.
//

import Foundation
import FirebaseFirestore

struct MonthlyExpense: Identifiable, Codable {
    @DocumentID var id: String?
    var yearMonth: String       // "yyyy-MM" 형식
    var categoryId: String
    var amount: Int
    var createdAt: Date

    // 로컬 조인용 (Firestore에 저장되지 않음)
    var category: ExpenseCategory?

    enum CodingKeys: String, CodingKey {
        case id
        case yearMonth = "year_month"
        case categoryId = "category_id"
        case amount
        case createdAt = "created_at"
    }
}

extension MonthlyExpense {
    /// 새 지출 생성을 위한 초기화
    init(yearMonth: String, categoryId: String, amount: Int) {
        self.yearMonth = yearMonth
        self.categoryId = categoryId
        self.amount = amount
        self.createdAt = Date()
    }
}
