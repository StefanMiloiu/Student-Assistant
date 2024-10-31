//
//  ExamsCalendarView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 13.10.2024.
//

import SwiftUI
import ObiletCalendar
// MARK: - ExamsCalendarView
struct ExamsCalendarView: View {

    // MARK: - Environment Objects
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl // App coordinator for navigation
    @EnvironmentObject var vm: ExamListViewModel // View model for managing exams

    // MARK: - State Properties
    @State private var currentDate = Date() // Current date
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date()) // Selected month
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date()) // Selected year
    @State private var selectedDay: Int = Calendar.current.component(.day, from: Date()) // Selected day
    @State private var selectedTime = Date() // Selected time for exams
    @State var isSelected: Bool = false // State for showing the Add Exam popup
    @State var isTapped: Bool = false // State for showing detailed exam view

    private var calendar: Calendar {
        Calendar.current // Current calendar
    }

    // MARK: - Body
    var body: some View {
        VStack {
            // Header displaying the month and year
            displayDate
            Spacer()
            header // Month and year picker
            Spacer()

            // Conditional views based on selection state
            if isSelected {
                // Popup for adding an exam
                AddExamPopUpVIew(year: selectedYear,
                                 month: selectedMonth,
                                 day: selectedDay,
                                 isSelected: $isSelected)
                .animation(.easeInOut(duration: 0.75), value: isSelected) // Smooth animation
            }
            if isTapped {
                // Detailed view for a selected exam
                DetailedExamsView(isTapped: $isTapped,
                                  day: selectedDay,
                                  month: selectedMonth,
                                  year: selectedYear)
                .animation(.easeInOut(duration: 0.75), value: isTapped) // Smooth animation
            }
            if !(isSelected || isTapped) {
                daysOfWeek // Display the days of the week
                ZStack {
                    // Background for the days in the month
                    Color.gray.opacity(0.15)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .scaleEffect(y: 1)
                    calendarView // Days in the selected month
                }
            }
            Spacer()
        }
        .padding() // Padding for the entire view
    }

    // MARK: - Header with Month and Year Pickers
    private var header: some View {
        MonthAndYearPickerView(selectedMonth: $selectedMonth,
                               selectedYear: $selectedYear,
                               currentDate: $currentDate,
                               examTime: $selectedTime)
    }

    // MARK: - Display Date Header
    private var displayDate: some View {
        HStack {
            Spacer()
            // Button to present exams list
            Button(action: {
                presentExamsList() // Action to present exams list
            }) {
                Image(systemName: "list.dash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30) // Icon size
            }

            Spacer()
            // Display current month and year
            Text("Exams \n \(String(selectedYear)) / \(selectedMonth)")
                .font(.title)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)

            Spacer()
            // Button to present calendar info
            Button(action: {
                appCoordinator.presentSheet(.calendarInfo) // Action to present calendar info
            }) {
                Image(systemName: "info.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30) // Icon size
            }
            Spacer()
        }
    }

    // MARK: - Days of the Week
    private var daysOfWeek: some View {
        HStack {
            ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                Text(day) // Display each day of the week
                    .frame(maxWidth: .infinity)
                    .fontWeight(.bold)
            }
        }
    }

    // MARK: - Days in the Month
    private var calendarView: some View {
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentDate)! // Number of days in the month
        let firstDayOfMonth = calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth))! // First day of the month
        let startingOffset = calendar.component(.weekday, from: firstDayOfMonth) - 1 // Starting offset for the month
        
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
            // Create empty spaces for the starting offset
            ForEach(0..<startingOffset, id: \.self) { _ in
                Text("")
            }
            // Create days in the month
            ForEach(1...daysInMonth.count, id: \.self) { day in
                DayInMonth(day: day, month: selectedMonth, year: selectedYear)
                    .onLongPressGesture {
                        selectedDay = day // Update selected day on long press
                        withAnimation {
                            isSelected = true // Show Add Exam popup
                        }
                    }
                    .onTapGesture {
                        withAnimation {
                            selectedDay = day // Update selected day on tap
                            // Check if an exam exists for the selected day
                            if !vm.fetchExam(day: day, month: selectedMonth, year: selectedYear).isEmpty {
                                isTapped = true // Show detailed exam view
                            }
                        }
                    }
            }
        }
    }
    
    // MARK: - Present Exams List
    private func presentExamsList() {
        // Update the AppCoordinator with the selected year and month
        appCoordinator.selectedYear = selectedYear
        appCoordinator.selectedMonth = selectedMonth
        appCoordinator.presentSheet(.examsList) // Present the sheet with ExamsListView
    }
}

// MARK: - Preview
#Preview {
    ExamsCalendarView()
        .environmentObject(AppCoordinatorImpl()) // Provide environment objects for preview
}
