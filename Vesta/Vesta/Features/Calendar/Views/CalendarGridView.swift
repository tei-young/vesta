//
//  CalendarGridView.swift
//  Vesta
//
//  Created on 2026-01-22.
//

import SwiftUI

struct CalendarGridView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: CalendarViewModel
    let days: [Date?]

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    // MARK: - Body

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(0..<days.count, id: \.self) { index in
                if let date = days[index] {
                    DayCell(
                        date: date,
                        isToday: date.isToday(),
                        isSelected: Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate),
                        hasRecords: viewModel.hasRecords(for: date),
                        onTap: {
                            viewModel.selectDate(date)
                        }
                    )
                } else {
                    DayCell(
                        date: nil,
                        isToday: false,
                        isSelected: false,
                        hasRecords: false,
                        onTap: {}
                    )
                }
            }
        }
        .padding(.horizontal)
    }
}
