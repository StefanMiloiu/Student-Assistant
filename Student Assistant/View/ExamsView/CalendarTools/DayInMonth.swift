//
//  DayInMonth.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 13.10.2024.
//

import SwiftUI

struct DayInMonth: View {
    
    @StateObject var vm = ExamListViewModel()
    let day: Int
    let month: Int
    let year: Int
    @State private var exam: Exam? = nil
    
    var body: some View {
        VStack {
            if exam != nil {
                Text("\(day)")
                    .frame(width: 50, height: 50)
                    .background(.gray)
                    .clipShape(Circle())
                    .frame(width: 50, height: 50)
                    .padding(.bottom)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
            } else {
                Text("\(day)")
                    .frame(width: 50, height: 50)
                    .background(.gray)
                    .clipShape(Circle())
                    .frame(width: 70, height: 70)
            }
        }
        .onAppear {
            exam = vm.fetchExam(day: day, month: month, year: year)
        }
        .onChange(of: month) {
            exam = vm.fetchExam(day: day, month: month, year: year)
        }
        .onChange(of: year) {
            exam = vm.fetchExam(day: day, month: month, year: year)
        }
    }
}

#Preview {
    DayInMonth(day: 14, month: 10, year: 2024)
}
