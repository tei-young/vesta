//
//  DailyAdjustment.swift
//  Vesta
//
//  Created on 2026-01-19.
//

import Foundation
import FirebaseFirestore

struct DailyAdjustment: Identifiable, Codable {
    @DocumentID var id: String?
    var date: Date
    var amount: Int         // 음수: 할인, 양수: 팁/추가금액
    var reason: String?
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case amount
        case reason
        case createdAt = "created_at"
    }
}

extension DailyAdjustment {
    /// 새 조정 생성을 위한 초기화
    init(date: Date, amount: Int, reason: String? = nil) {
        self.date = date.startOfDay()
        self.amount = amount
        self.reason = reason
        self.createdAt = Date()
    }

    /// 할인인지 여부
    var isDiscount: Bool {
        amount < 0
    }

    /// 추가금액인지 여부
    var isAddition: Bool {
        amount > 0
    }

    /// 절대값
    var absoluteAmount: Int {
        abs(amount)
    }

    /// 표시용 타입 문자열
    var typeDescription: String {
        isDiscount ? "할인" : "추가금액"
    }
}
