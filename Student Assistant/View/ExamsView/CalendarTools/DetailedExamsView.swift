//
//  DetailedExamsView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 14.10.2024.
//

import SwiftUI

struct DetailedExamsView: View {
    
    @StateObject var vm = ExamListViewModel()
    @Binding var isTapped: Bool
    let day: Int
    let month: Int
    let year: Int
    @State var exam: Exam?
    var body: some View {
        VStack {
            Text("\(exam?.examSubject ?? "No exam found")")
                .font(.title)
            Spacer()
            
            ScrollView {
                Text("\(exam?.examLocation ?? "No location found")")
            }
            .padding()
            .frame(width: 250, height: 100)
            .background(Color.white) // Background for the entire popup
            .cornerRadius(20)
            .shadow(radius: 5)
            
            Spacer()
            
            HStack {
                Button(action: {
                    isTapped = false
                }) {
                    Text("Back")
                        .frame(width: 100, height: 40)
                        .foregroundStyle(.white)
                        .background(Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Text("Date   \n\(exam?.examDate ?? Date(), formatter: formatter())")
                    .multilineTextAlignment(.center)
                    .fontWeight(.heavy)
            }
        }
        .onAppear {
            self.exam = vm.fetchExam(day: day, month: month, year: year)
        }
        .padding()
        .frame(width: 300, height: 250)
        .background(Color.white) // Background for the entire popup
        .cornerRadius(20)
        .shadow(radius: 10)
    }
    
    private func formatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy hh:mm"
        return formatter
    }
}

#Preview {
    DetailedExamsView(isTapped: .constant(false), day: 2, month: 10, year: 2024)
}
