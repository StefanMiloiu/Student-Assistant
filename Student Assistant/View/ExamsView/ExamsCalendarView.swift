//
//  ExamsCalendarView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 13.10.2024.
//

import SwiftUI

struct ExamsCalendarView: View {
    
    @StateObject var vm = ExamListViewModel()
    @State private var currentDate = Date()
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedDay: Int = Calendar.current.component(.day, from: Date())
    @State private var selectedTime = Date()
    @State var isSelected: Bool = false
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    var body: some View {
        VStack {
            // Header with month picker
            displayDate
            Spacer()
            header
            Spacer()
            // Days of the week
            daysOfWeek
            // Days in the month
            if !isSelected {
                daysInMonth
            } else {
                AddExamPopUpVIew(year: selectedYear, month: selectedMonth, day: selectedDay, isSelected: $isSelected)
            }
            Spacer()

        }
        .onAppear {
            print(vm.fetchExams())
        }
        .padding()
    }
    
    // Header with month and year pickers
    private var header: some View {
        MonthAndYearPickerView(selectedMonth: $selectedMonth, selectedYear: $selectedYear, currentDate: $currentDate, examTime: $selectedTime)
    }
    
    private var displayDate: some View {
        Text("Exams \n \(String(selectedYear)) / \(selectedMonth)")
            .font(.title)
            .fontWeight(.heavy)
            .multilineTextAlignment(.center)
    }
    
    // Days of the week
    private var daysOfWeek: some View {
        HStack {
            ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                Text(day)
                    .frame(maxWidth: .infinity)
                    .fontWeight(.bold)
            }
        }
    }
    
    // Days in the month
    private var daysInMonth: some View {
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentDate)!
        let firstDayOfMonth = calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth))!
        let startingOffset = calendar.component(.weekday, from: firstDayOfMonth) - 1
        
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
            ForEach(0..<startingOffset, id: \.self) { _ in
                Text("")
            }
            ForEach(1...daysInMonth.count, id: \.self) { day in
                DayInMonth(day: day, month: selectedMonth, year: selectedYear)
                    .onLongPressGesture {
                        print(day, selectedYear, selectedMonth)
                        selectedDay = day
                        isSelected = true
                    }
                    .onTapGesture {
                        
                    }
            }
            
        }
    }
    
  
}


#Preview {
    ExamsCalendarView()
}
