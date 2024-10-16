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
    @State var isTapped: Bool = false
    @State var showInfo: Bool = false
    @State var showList: Bool = false
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    var body: some View {
        VStack {
            // Header with month picker
            displayDate
                .sheet(isPresented: $showList, content: {
                    ExamsListView()
                })
            Spacer()
            header
                .sheet(isPresented: $showInfo, content: {
                    CalendarInfoView()
                })
            Spacer()
            
            if isSelected {
                AddExamPopUpVIew(year: selectedYear,
                                 month: selectedMonth,
                                 day: selectedDay,
                                 isSelected: $isSelected)
                .transition(.move(edge: .bottom)) // Add animation for appearing and disappearing
                .animation(.easeInOut(duration: 0.15), value: isSelected)
            }
            if isTapped {
                DetailedExamsView(isTapped: $isTapped,
                                  day: selectedDay,
                                  month: selectedMonth,
                                  year: selectedYear)
            }
            if !(isSelected || isTapped) {
                daysOfWeek
                ZStack {
                    Color.gray.opacity(0.15)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .scaleEffect(y: 1)
                    daysInMonth
                }
            }
            Spacer()
        }
        .presentationDetents([.medium])
        .padding()
    }
    
    // Header with month and year pickers
    private var header: some View {
        MonthAndYearPickerView(selectedMonth: $selectedMonth, selectedYear: $selectedYear, currentDate: $currentDate, examTime: $selectedTime)
    }
    
    private var displayDate: some View {
        HStack {
            Spacer()
            Button(action : {
                showInfo = false
                showList = true
            }) {
                Image(systemName: "list.dash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }
            
            Spacer()
            Text("Exams \n \(String(selectedYear)) / \(selectedMonth)")
                .font(.title)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
            
            Spacer()
            Button(action: {
                showList = false
                showInfo = true
            }){
                Image(systemName: "info.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }
            Spacer()
            
        }
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
                        selectedDay = day
                        withAnimation {
                            isSelected = true
                        }
                    }
                    .onTapGesture {
                        selectedDay = day
                        if vm.fetchExam(day: day, month: selectedMonth, year: selectedYear) != nil {
                            isTapped = true
                        }
                    }
            }
        }
        
        
    }
}


#Preview {
    ExamsCalendarView()
}
