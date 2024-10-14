//
//  AddExamPopUpVIew.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 14.10.2024.
//

import SwiftUI

struct AddExamPopUpVIew: View {
    
    @StateObject var vm = ExamListViewModel()
    let year: Int
    let month: Int
    let day: Int
    @State private var examSubject: String = ""
    @State private var examLocation: String = ""
    @State private var examTime: Date = Date()
    @Binding var isSelected: Bool
    
    var body: some View {
        VStack {
            TextField("Subject", text: $examSubject)
                .textInputAutocapitalization(.sentences)
                .disableAutocorrection(true)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6))) // Background for textfield
            
            TextField("Location", text: $examLocation)
                .textInputAutocapitalization(.sentences)
                .disableAutocorrection(true)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
            
            Section {
                DatePicker("Exam Time", selection: $examTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(CompactDatePickerStyle())
                    .frame(width: 250, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            Button(action: {
                let date = vm.generateDate(day: day, month: month, year: year, time: examTime)
                if let date {
                    let result = vm.addExam(subject: examSubject, date: date, location: examLocation)
                    if result {
                        isSelected = false
                    }
                }
            }) {
                Text("Save")
                    .frame(width: 100, height: 40)
                    .foregroundStyle(.white)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .frame(width: 300, height: 250)
        .background(Color.white) // Background for the entire popup
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

#Preview {
    AddExamPopUpVIew(year: 2024, month: 10, day: 20, isSelected: .constant(true))
}
