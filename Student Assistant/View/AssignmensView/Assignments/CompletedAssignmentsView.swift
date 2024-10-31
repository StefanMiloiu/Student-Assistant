//
//  CompletedAssignmentsView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 16.10.2024.
//

import SwiftUI
import Charts

// MARK: - Display Modes Enum
enum DisplayModes: String, CaseIterable {
    case sevenDays = "Last 7 Days"
    case oneMonth = "Last Month"
    case oneYear = "Last Year"
}

// MARK: - CompletedAssignmentsView
struct CompletedAssignmentsView: View {

    // MARK: - Properties
    @EnvironmentObject var vm: AssignmentListViewModel
    @State private var displayMode: DisplayModes = .sevenDays
    @State private var selectedStatus = "Completed"

    // MARK: - Computed Properties
    var filteredAssignments: [Assignment] {
        switch displayMode {
        case .sevenDays:
            return vm.assignments.filter { Calendar.current.isDateInLastWeek($0.assignmentDate ?? Date()) }
        case .oneMonth:
            return vm.assignments.filter { Calendar.current.isDateInLastMonth($0.assignmentDate ?? Date()) }
        case .oneYear:
            return vm.assignments.filter { Calendar.current.isDateInLastYear($0.assignmentDate ?? Date()) }
        }
    }

    var assignmentCountsByDate: [(Date, Int)] {
        var counts: [Date: Int] = [:]
        let calendar = Calendar.current

        // Initialize counts based on display mode
        // Use the date range to initialize counts
            let dateRange = getDateRange(for: displayMode, using: calendar)
            for date in dateRange {
                counts[date] = 0 // Initialize with 0
            }

        // Count the assignments per day
        for assignment in filteredAssignments {
            if let date = assignment.assignmentDate {
                let day = calendar.startOfDay(for: date)
                counts[day, default: 0] += 1
            }
        }

        // Sort and return the counts by date
        return counts.sorted(by: { $0.key < $1.key })
    }

    var body: some View {
        VStack {
            if filteredAssignments.isEmpty {
                emptyStateView()
            } else {
                assignmentChart()
                AssignmentListView(selectedStatus: $selectedStatus, filteredForDate: filteredAssignments)
            }
        }
        .onChange(of: vm.assignments) {
            vm.fetchAssignments() // Fetch assignments when view appears
        }
    }

    // MARK: - Empty State View
    private func emptyStateView() -> some View {
        VStack {
            Text("No completed assignments yet")
                .font(.headline)
                .padding()

            Image(systemName: "newspaper")
                .resizable()
                .scaledToFit()
                .frame(width: 50)
        }
        .frame(width: 350, height: 400)
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 50))
    }

    // MARK: - Assignment Chart
    private func assignmentChart() -> some View {
        VStack {
            Picker("Display Mode", selection: $displayMode) {
                ForEach(DisplayModes.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            Chart {
                ForEach(assignmentCountsByDate, id: \.0) { date, count in
                    if assignmentCountsByDate.count == 1 {
                        /*PointMark(
                         x: .value("Date", date),
                         y: .value("Completed Assignments", count)
                         )*/
                        LineMark(
                            x: .value("Date", date),
                            y: .value("Completed Assignments", count)
                        )
                    } else {
                        LineMark(
                            x: .value("Date", date),
                            y: .value("Completed Assignments", count)
                        )
                    }
                }
            }
            .frame(height: 200)
            .padding(20)
        }
    }

    // MARK: - Get Date Range
    private func getDateRange(for mode: DisplayModes, using calendar: Calendar) -> [Date] {
        let today = calendar.startOfDay(for: Date())
        var dateRange: [Date] = []

        switch mode {
        case .sevenDays:
            dateRange = (0..<7).compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }
        case .oneMonth:
            dateRange = (0..<30).compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }
        case .oneYear:
            dateRange = (0..<12).compactMap { calendar.date(byAdding: .month, value: -$0, to: today) }
        }
        return dateRange
    }
}

// MARK: - Preview
#Preview {
    CompletedAssignmentsView()
}
