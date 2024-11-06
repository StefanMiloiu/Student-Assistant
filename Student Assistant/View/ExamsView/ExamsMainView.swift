//
//  ExamsMainView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 01.11.2024.
//

import SwiftUI
import MapKit

struct ExamsMainView: View {
    @EnvironmentObject var viewModel: ExamListViewModel
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl
    
    @Namespace private var animation
    
    var body: some View  {
        NavigationView {
            List {
                    ForEach(viewModel.exams, id: \.self) { exam in
                        Button {
                            appCoordinator.pushCustom(DetailedExamsView(exam: exam, animation: animation))
                        } label: {
                            
                                CustomExam_MapCell(exam: exam)
                                    .frame(height: 225) // Ensure consistent height
                                    .allowsHitTesting(false)
                                    .tint(Color.appJordyBlue)
                        }
                        .frame(height: 225) // Match height of CustomExam_MapCell
                        .listRowInsets(EdgeInsets()) // Remove default padding for rows
                        .listRowSeparator(.hidden)
                    }
                    .onDelete(perform: deleteExam)
            }
            .padding(.top, 20)
            .navigationTitle("Exams")
            .scrollContentBackground(.hidden)
            .listRowSpacing(20)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        appCoordinator.push(.addExam)
                    } label: {
                        Image(systemName: "plus")
                            .tint(.primary)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                        .tint(.primary)
                }
            }
        }
        .tint(.appCambridgeBlue)
        .onAppear {
            viewModel.fetchExams()
            print(viewModel.exams.count)
        }
    }
    
    // MARK: - Delete Exams Function
    private func deleteExam(at offsets: IndexSet) {
        offsets.forEach { index in
            let exam = viewModel.exams[index]
            viewModel.deleteExam(exam)
        }
    }
}

#Preview {
    ExamsMainView()
        .environmentObject(ExamListViewModel())
        .environmentObject(AppCoordinatorImpl())
}
