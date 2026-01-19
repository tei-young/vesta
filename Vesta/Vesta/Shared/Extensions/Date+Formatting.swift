//
//  Date+Formatting.swift
//  Vesta
//
//  Created on 2026-01-19.
//

import Foundation

extension Date {
    // MARK: - ISO String Formatting

    /// Date를 "yyyy-MM-dd" 형식 문자열로 변환
    func toISOString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = AppConstants.DateFormat.isoDate
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: self)
    }

    /// Date를 "yyyy-MM" 형식 문자열로 변환
    func toYearMonthString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = AppConstants.DateFormat.yearMonth
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: self)
    }

    // MARK: - Display Formatting

    /// Date를 "M월 d일" 형식으로 변환
    func toDisplayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = AppConstants.DateFormat.displayDate
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: self)
    }

    /// Date를 "yyyy년 M월" 형식으로 변환
    func toMonthDisplayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = AppConstants.DateFormat.displayMonth
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: self)
    }

    // MARK: - Parsing

    /// "yyyy-MM-dd" 문자열을 Date로 변환
    static func fromISOString(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = AppConstants.DateFormat.isoDate
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.date(from: string)
    }

    /// "yyyy-MM" 문자열을 Date로 변환 (해당 월의 1일)
    static func fromYearMonthString(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = AppConstants.DateFormat.yearMonth
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.date(from: string + "-01")
    }

    // MARK: - Date Manipulation

    /// 해당 날짜의 시작 시간 (00:00:00)
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }

    /// 해당 월의 시작 날짜
    func startOfMonth() -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components) ?? self
    }

    /// 해당 월의 마지막 날짜
    func endOfMonth() -> Date {
        guard let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: startOfMonth()),
              let endOfMonth = Calendar.current.date(byAdding: .day, value: -1, to: nextMonth) else {
            return self
        }
        return endOfMonth
    }

    // MARK: - Comparison

    /// 같은 날인지 확인
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    /// 오늘인지 확인
    func isToday() -> Bool {
        Calendar.current.isDateInToday(self)
    }
}
