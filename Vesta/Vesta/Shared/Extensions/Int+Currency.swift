//
//  Int+Currency.swift
//  Vesta
//
//  Created on 2026-01-19.
//

import Foundation

extension Int {
    /// 금액을 한국식 축약 형식으로 변환
    /// - 50000원 → "5만원"
    /// - 3500원  → "3,500원"
    /// - 125000원 → "12만원"
    var formattedKoreanCurrency: String {
        if self >= 10000 {
            let man = self / 10000
            return "\(man)만원"
        }
        return "\(self.formattedWithComma)원"
    }

    /// 금액을 전체 형식으로 변환
    /// - 50000 → "₩50,000"
    var formattedCurrency: String {
        "₩\(self.formattedWithComma)"
    }

    /// 숫자를 천 단위 구분자로 포맷팅
    /// - 50000 → "50,000"
    var formattedWithComma: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

extension String {
    /// 쉼표가 포함된 문자열을 Int로 변환
    /// - "50,000" → 50000
    var intFromCurrencyString: Int? {
        let cleaned = self.replacingOccurrences(of: ",", with: "")
                          .replacingOccurrences(of: "₩", with: "")
                          .trimmingCharacters(in: .whitespaces)
        return Int(cleaned)
    }
}
