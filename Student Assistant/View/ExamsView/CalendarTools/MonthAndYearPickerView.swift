//
//  MonthAndYearPickerView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 13.10.2024.
//

import SwiftUI

struct MonthAndYearPickerView: View {

    @EnvironmentObject var appCoordinator: AppCoordinatorImpl

    private var calendar: Calendar {
        Calendar.current
    }

    @Binding var selectedMonth: Int
    @Binding var selectedYear: Int
    @Binding var currentDate: Date
    @Binding var examTime: Date

    var body: some View {
        VStack {
            Form {
                Section {
                    // Year Picker
                    HStack(spacing: 100) {
                        Picker("Year", selection: $selectedYear) {
                            ForEach(2020...2100, id: \.self) { year in
                                Text("\(String(year))").tag(year)
                            }
                        }
                    }
                    .onChange(of: selectedYear) {
                        updateCurrentDate()
                    }
                }

                // Month Picker
                Section {
                    Picker("Month", selection: $selectedMonth) {
                        ForEach(1...12, id: \.self) { month in
                            Text(calendar.monthSymbols[month - 1])
                                .tag(month)
                        }
                    }
                    .onChange(of: selectedMonth) {
                        updateCurrentDate()
                    }
                }
                .onChange(of: appCoordinator.selectedMonth) {
                    updateCurrentDataCoordinator()
                }
                .onChange(of: appCoordinator.selectedYear) {
                    updateCurrentDataCoordinator()
                }

            }
            .scrollDisabled(true)
            .frame(width: 350, height: 200, alignment: .center)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }

    private func updateCurrentDate() {
        if let newDate = calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth)) {
            currentDate = newDate
        }
    }

    private func updateCurrentDataCoordinator() {
        if let newDate = calendar.date(from: DateComponents(year: appCoordinator.selectedYear, month: appCoordinator.selectedMonth)) {
            currentDate = newDate
        }
    }
}

struct MonthAndYearPickerView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview with constant bindings for selected month and year
        MonthAndYearPickerView(selectedMonth: .constant(5), selectedYear: .constant(2024), currentDate: .constant(Date()), examTime: .constant(Date()))
            .padding() // Optional: to add some padding around the preview
    }
}
