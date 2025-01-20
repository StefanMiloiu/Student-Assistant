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
            if !viewModel.exams.isEmpty {
                List {
                    ForEach(viewModel.exams, id: \.id) { exam in
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
                .scrollContentBackground(.hidden)
                .padding(.top, 20)
                .navigationTitle("Exams")
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
                
            } else {
                ZStack {
                    ZStack {
                        Image("ColoredBoardImage")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding()
                        HStack {
                            Spacer()
                            Image("ArrowImage")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .padding()
                                .offset(y: -150) // Move the view 50 points upward (adjust as needed)
                        }
                    }
                    ContentUnavailableView("No exams added yet",
                                           systemImage: "calendar.badge.exclamationmark",
                                           description: Text("If you want to add an exam,\n tap the plus button.")
                    )
                    .foregroundStyle(.black)
                    .padding(.bottom)
                    .offset(y: -25) // Move the view 50 points upward (adjust as needed)

                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            appCoordinator.push(.addExam)
                        } label: {
                            Image(systemName: "plus")
                                .tint(.primary)
                        }
                    }
                }
                .padding(.top, 20)
            }
        }
        .tint(.appCambridgeBlue)
        .onAppear {
            viewModel.fetchExams()
        }
    }
    
    // MARK: - Delete Exams Function
    private func deleteExam(at offsets: IndexSet) {
        offsets.forEach { index in
            let exam = viewModel.exams[index]
            DispatchQueue.main.async {
                viewModel.deleteExam(exam)
            }
        }
    }
}

#Preview {
    ExamsMainView()
        .environmentObject(ExamListViewModel())
        .environmentObject(AppCoordinatorImpl())
}
