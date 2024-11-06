//
//  AddExamPopUpVIew.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 14.10.2024.
//

import SwiftUI

struct AddExamPopUpVIew: View {

    @EnvironmentObject var vm: ExamListViewModel
    @Binding var examSubject: String
    @Binding var examLocation: String
    @Binding var examTime: Date

    var body: some View {
        VStack {
            TextField("Subject", text: $examSubject)
                .textInputAutocapitalization(.sentences)
                .disableAutocorrection(true)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
            TextField("Location (room)", text: $examLocation)
                .textInputAutocapitalization(.sentences)
                .disableAutocorrection(true)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
            DatePicker("Exam Time", selection: $examTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(CompactDatePickerStyle())
                    .frame(width: 300, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            
        }
    }
}

#Preview {
    AddExamPopUpVIew(examSubject: .constant("Romana"), examLocation: .constant("A313"), examTime: .constant(Date()))
        .environmentObject(ExamListViewModel()) // Injecting the environment object

}
