//
//  AppConstants.swift
//  Vesta
//
//  Created on 2026-01-19.
//

import Foundation

struct AppConstants {
    // MARK: - App Info

    static let appName = "Vesta"
    static let appVersion = "1.0.0"

    // MARK: - Spacing

    struct Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let s: CGFloat = 12
        static let m: CGFloat = 16
        static let l: CGFloat = 24
        static let xl: CGFloat = 32
    }

    // MARK: - Animation

    struct Animation {
        static let defaultDuration: Double = 0.3
        static let fastDuration: Double = 0.2
        static let slowDuration: Double = 0.5
    }

    // MARK: - Limits

    struct Limits {
        static let treatmentNameMaxLength = 30
        static let expenseCategoryNameMaxLength = 20
        static let iconMaxLength = 2
        static let adjustmentReasonMaxLength = 50
    }

    // MARK: - Date Format

    struct DateFormat {
        static let yearMonth = "yyyy-MM"         // "2026-01"
        static let isoDate = "yyyy-MM-dd"        // "2026-01-19"
        static let displayDate = "M월 d일"       // "1월 19일"
        static let displayMonth = "yyyy년 M월"   // "2026년 1월"
    }
}
