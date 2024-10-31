//
//  ExamsListView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 14.10.2024.
//

import SwiftUI

struct ExamsListView: View {

    @EnvironmentObject var vm: ExamListViewModel
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl
    @Binding var selectedYear: Int?
    @Binding var selectedMonth: Int?
    var body: some View {
        Form {
            if !vm.exams.isEmpty {
                EditButton()
                    .frame(maxWidth: .infinity)
                    .frame(alignment: .center)
            } else {
                emptyStateView(message: "No exams found", imageName: "text.page.slash.fill", color: .red.opacity(0.1))
                    .padding(.horizontal, 25)
            }

            List {
                ForEach(vm.exams, id: \.examID) { exam in
                    Section {
                        Button(action: {
                            guard let examDate = exam.examDate else { return }

                            let newYear = examYearFormatter(date: examDate)
                            let newMonth = examMonthFormatter(date: examDate)

                            // Update the properties
                            selectedYear = newYear
                            selectedMonth = newMonth
                            appCoordinator.dismissSheet()
                        }) {
                            VStack {
                                Text(exam.examSubject ?? "Could not get subject")
                                    .font(.title2)
                                Text(exam.examLocation ?? "Could not get location")
                            }
                        }
                    }
                    header: {
                        Text(exam.examDate ?? Date(), formatter: examDateFormatter)
                    }
                    .listRowSeparator(.hidden)
                }
                .onDelete(perform: deleteExam)
                .listSectionSeparator(.hidden)
            }
        }
        .navigationBarItems(leading: EditButton())

        .onAppear {
            vm.fetchExams() // Fetch exams when view appears
        }
    }

    // MARK: - Empty State View
    private func emptyStateView(message: String, imageName: String, color: Color) -> some View {
        VStack {
            Text(message)
                .font(.headline)
                .padding()

            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 50)
        }
        .frame(width: 325, height: 300, alignment: .center)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 50))
    }

    private func deleteExam(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                // Perform the deletion from the array
                let examToDelete = vm.exams[index]
                vm.deleteExam(examToDelete)
                vm.fetchExams()
            }
        }
    }
}

private let examDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

private func examYearFormatter(date: Date) -> Int {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy"
    return Int(formatter.string(from: date))!
}

private func examMonthFormatter(date: Date) -> Int {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM"
    return Int(formatter.string(from: date))!
}

#Preview {
    ExamsListView(selectedYear: .constant(2024), selectedMonth: .constant(10))
        .environmentObject(ExamListViewModel()) // Provide a mock or real instance of the view model

}
