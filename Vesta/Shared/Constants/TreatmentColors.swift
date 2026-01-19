//
//  TreatmentColors.swift
//  Vesta
//
//  Created on 2026-01-19.
//

import SwiftUI

struct TreatmentColorOption: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let value: String  // HEX 색상 코드
    let emoji: String

    var color: Color {
        Color(hex: value)
    }
}

struct TreatmentColors {
    static let palette: [TreatmentColorOption] = [
        TreatmentColorOption(name: "메인 핑크", value: "#FFA0B9", emoji: "💗"),
        TreatmentColorOption(name: "어두운 핑크", value: "#F28AA5", emoji: "💕"),
        TreatmentColorOption(name: "로즈 핑크", value: "#FF6B9D", emoji: "🌹"),
        TreatmentColorOption(name: "코랄 핑크", value: "#FF8FAB", emoji: "🪸"),
        TreatmentColorOption(name: "라벤더", value: "#E0BBE4", emoji: "💜"),
        TreatmentColorOption(name: "피치", value: "#FFB6C1", emoji: "🍑"),
        TreatmentColorOption(name: "레드", value: "#FF3B30", emoji: "🔴"),
        TreatmentColorOption(name: "오렌지", value: "#FF9500", emoji: "🟠"),
        TreatmentColorOption(name: "옐로우", value: "#FFCC00", emoji: "🟡"),
        TreatmentColorOption(name: "민트", value: "#30D158", emoji: "💚"),
        TreatmentColorOption(name: "스카이블루", value: "#5AC8FA", emoji: "🩵"),
        TreatmentColorOption(name: "퍼플", value: "#AF52DE", emoji: "🟣"),
        TreatmentColorOption(name: "브라운", value: "#A2845E", emoji: "🟤"),
        TreatmentColorOption(name: "그레이", value: "#8E8E93", emoji: "⚫"),
        TreatmentColorOption(name: "라이트그레이", value: "#C7C7CC", emoji: "⚪")
    ]

    /// HEX 코드로 색상 이름 찾기
    static func name(for hex: String) -> String? {
        palette.first(where: { $0.value.uppercased() == hex.uppercased() })?.name
    }

    /// HEX 코드로 Color 생성
    static func color(for hex: String) -> Color {
        Color(hex: hex)
    }
}
