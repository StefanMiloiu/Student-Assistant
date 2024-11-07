//
//  AddExamView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 02.11.2024.
//

import SwiftUI
import MapKit

struct AddExamView: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl
    @State var showAlert: Bool = false
    
    @State private var examSubject: String = ""
    @State private var examLocation: String = ""
    @State private var examTime: Date = Date()
    
    @State private var currentDate = Date() // Current date
    @State private var selectedMonth: Int = Calendar.current.component(.month,
                                                                       from: Date()) // Selected month
    @State private var selectedYear: Int = Calendar.current.component(.year,
                                                                      from: Date()) // Selected year
    @State private var selectedDay: Int = Calendar.current.component(.day,
                                                                     from: Date()) // Selected day
    var body: some View {
        VStack(spacing: 10) {
            Form {
                VStack {
                    AddExamPopUpVIew(examSubject: $examSubject,
                                     examLocation: $examLocation,
                                     examTime: $examTime)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    
                    
                    MonthAndYearPickerView(selectedMonth: $selectedMonth,
                                           selectedYear: $selectedYear,
                                           selectedDay: $selectedDay,
                                           currentDate: $currentDate,
                                           examTime: $examTime)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .padding()
                .background(Color.appCambridgeBlue.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .padding(.bottom, 50)
                
                
                Button {
                    guard examSubject != "" && examLocation != "" else {
                        showAlert.toggle()
                        return
                    }
                    appCoordinator.pushCustom(
                        AddExamMapView(examSubject: $examSubject,
                                       examLocation: $examLocation,
                                       examTime: $examTime,
                                       currentDate: $currentDate))
                } label: {
                    Text("Add the location")
                        .font(.body)
                        .fontWeight(.heavy)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .foregroundColor(.white)
                        .background(Color.appCambridgeBlue)
                        .cornerRadius(10)
                }
                .alert(isPresented: $showAlert ) {
                    Alert(title: Text("Uppps!"), message: Text("Please enter a subject and location."), dismissButton: .default(Text("OK")))
                }
                .listRowBackground(Color.clear)

            }
            .scrollDisabled(true)
            .listRowSeparator(.hidden)
        }
        .navigationTitle("Add new exam")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AddExamView()
        .environmentObject(AppCoordinatorImpl())
}
