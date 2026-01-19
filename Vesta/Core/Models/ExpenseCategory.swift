//
//  ExpenseCategory.swift
//  Vesta
//
//  Created on 2026-01-19.
//

import Foundation
import FirebaseFirestore

struct ExpenseCategory: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var icon: String?
    var order: Int
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case icon
        case order
        case createdAt = "created_at"
    }
}

extension ExpenseCategory {
    /// 새 카테고리 생성을 위한 초기화
    init(name: String, icon: String? = nil, order: Int) {
        self.name = name
        self.icon = icon
        self.order = order
        self.createdAt = Date()
    }
}
