//
//  LShapedDashboard.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 28.10.2024.
//

import SwiftUI
import MapKit

struct ExamsMap: View {
    @EnvironmentObject var viewModel: ExamListViewModel
    
    var body: some View {
        ZStack {
            if let firstExam = viewModel.exams.first {
                CustomExam_MapCell(exam: firstExam)
            } else {
                Text("No exam coming ☺️")
            }
        }
        .onAppear {
            viewModel.fetchExams()
        }
    }
}

#Preview {
    ExamsMap()
}
