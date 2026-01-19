//
//  CalendarTabView.swift
//  Vesta
//
//  Created on 2026-01-19.
//

import SwiftUI

struct CalendarTabView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("📅")
                    .font(.system(size: 60))

                Text("캘린더 탭")
                    .font(.title)
                    .foregroundColor(AppColors.textPrimary)

                Text("곧 구현될 예정입니다")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }
            .navigationTitle("캘린더")
        }
    }
}

#Preview {
    CalendarTabView()
}
