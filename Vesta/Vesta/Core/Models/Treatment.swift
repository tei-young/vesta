//
//  Treatment.swift
//  Vesta
//
//  Created on 2026-01-19.
//

import Foundation
import FirebaseFirestore

struct Treatment: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var price: Int
    var icon: String?
    var color: String
    var order: Int
    var createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case price
        case icon
        case color
        case order
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

extension Treatment {
    /// 새 시술 생성을 위한 초기화
    init(name: String, price: Int, icon: String? = nil, color: String, order: Int) {
        self.name = name
        self.price = price
        self.icon = icon
        self.color = color
        self.order = order
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
