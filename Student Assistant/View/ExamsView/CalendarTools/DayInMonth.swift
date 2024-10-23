//
//  DayInMonth.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 13.10.2024.
//

import SwiftUI

struct DayInMonth: View {
    
    @EnvironmentObject var vm: ExamListViewModel
    let day: Int
    let month: Int
    let year: Int
    @State private var exams: [Exam] = []
    
    var body: some View {
        VStack {
            if !exams.isEmpty {
                Text("\(day)")
                    .frame(width: 45, height: 45)
                    .background(.gray)
                    .clipShape(Circle())
                    .frame(width: 45, height: 45)
                    .padding(.bottom)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
            } else {
                Text("\(day)")
                    .frame(width: 45, height: 45)
                    .background(.gray)
                    .clipShape(Circle())
                    .frame(width: 65, height: 65)
            }
        }
        .onAppear {
            exams = vm.fetchExam(day: day, month: month, year: year)
        }
        .onChange(of: month) {
            exams = vm.fetchExam(day: day, month: month, year: year)
        }
        .onChange(of: year) {
            exams = vm.fetchExam(day: day, month: month, year: year)
        }
        .onChange(of: vm.exams) { // Notify on exams change
            exams = vm.fetchExam(day: day, month: month, year: year)
        }
    }
}

#Preview {
    DayInMonth(day: 14, month: 10, year: 2024)
        .environmentObject(ExamListViewModel()) // Injecting the environment object
    
}
