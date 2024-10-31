//
//  CustomExamIcon.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 13.10.2024.
//

import SwiftUI

struct CustomExamIcon: View {
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.6))

            CustomNumberOfExams()
                .padding(.top, 10)
                .padding(.trailing, 70)

            Image(systemName: "graduationcap.circle.fill")
                .resizable()
                .foregroundStyle(.white.opacity(1.0), .lightBlue)
                .aspectRatio(contentMode: .fit)
                .frame(width: 30)
                .padding(10)
                .padding(.leading, 80)

            Text("Exams Plan")
                .fontWeight(.heavy)
                .font(.system(size: 20))
                .padding(.top, 60)
                .foregroundStyle(.black)

        }
        .frame(width: 160, height: 110, alignment: .topTrailing)
    }
}

struct CustomNumberOfExams: View {

    @EnvironmentObject var vm: ExamListViewModel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .foregroundStyle(.black)
                .opacity(0.6)
            Text("\(vm.exams.count)")
                .foregroundStyle(.white)
        }
        .frame(width: 50, height: 30)
        .onAppear {
            vm.fetchExams()
        }
    }
}

#Preview {
    CustomExamIcon()
}
