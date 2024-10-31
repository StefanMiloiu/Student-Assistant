//
//  CustomAssignmentIcon.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 13.10.2024.
//

import SwiftUI

struct CustomAssignmentIcon: View {
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.6))

            CustomNumberOfAssignments()
                .padding(.top, 10)
                .padding(.trailing, 70)

            Image(systemName: "graduationcap.circle.fill")
                .resizable()
                .foregroundStyle(.white.opacity(1.0), .myRed)
                .aspectRatio(contentMode: .fit)
                .frame(width: 30)
                .padding(10)
                .padding(.leading, 80)

            Text("Assignments")
                .fontWeight(.heavy)
                .font(.system(size: 20))
                .padding(.top, 60)
                .foregroundStyle(.black)

        }
        .frame(width: 160, height: 110, alignment: .topTrailing)
    }
}

struct CustomNumberOfAssignments: View {

    @StateObject var vm = AssignmentListViewModel()

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .foregroundStyle(.black)
                .opacity(0.6)
            Text("\(vm.assignments.count)")
                .foregroundStyle(.white)
        }
        .frame(width: 50, height: 30)
        .onAppear {
            vm.fetchAssignments()
        }
    }
}

#Preview {
    CustomAssignmentIcon()
}
