//
//  MonthAndYearPickerView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 13.10.2024.
//

import SwiftUI

struct MonthAndYearPickerView: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl
    
    @Binding var selectedMonth: Int
    @Binding var selectedYear: Int
    @Binding var selectedDay: Int
    @Binding var currentDate: Date
    @Binding var examTime: Date
    @State var showAlert: Bool = false
    
    var body: some View {
        VStack {
            Section {
                DatePicker("Select Date", selection: $currentDate, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .onChange(of: currentDate) {
                        updateSelectedDateComponents(from: currentDate)
                        if currentDate < Date().advanced(by: -1) {
                            currentDate = Date()
                            showAlert = true
                        }
                    }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Past Date"), message: Text("Please select a date in the future."))
            }
            .padding()
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .onAppear {
            updateSelectedDateComponents(from: currentDate)
        }
    }
    
    private func updateSelectedDateComponents(from date: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        selectedYear = components.year ?? selectedYear
        selectedMonth = components.month ?? selectedMonth
        selectedDay = components.day ?? selectedDay
        appCoordinator.selectedYear = selectedYear
        appCoordinator.selectedMonth = selectedMonth
    }
}

struct MonthAndYearPickerView_Previews: PreviewProvider {
    static var previews: some View {
        MonthAndYearPickerView(
            selectedMonth: .constant(5),
            selectedYear: .constant(2024),
            selectedDay: .constant(1),
            currentDate: .constant(Date()),
            examTime: .constant(Date())
        )
        .environmentObject(AppCoordinatorImpl())
        .padding()
    }
}
