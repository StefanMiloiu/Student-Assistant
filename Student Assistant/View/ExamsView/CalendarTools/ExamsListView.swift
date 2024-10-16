//
//  ExamsListView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 14.10.2024.
//

import SwiftUI

struct ExamsListView: View {
    
    @StateObject var vm = ExamListViewModel()
    
    var body: some View {
        Form {
            EditButton()
                .frame(maxWidth: .infinity)
                .frame(alignment: .center)
            
            List {
                ForEach(vm.exams, id: \.examID) { exam in
                    Section {
                        VStack {
                            Text(exam.examSubject ?? "Could not get subject")
                                .font(.title2)
                            Text(exam.examLocation ?? "Could not get location")
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

#Preview {
    ExamsListView()
}
