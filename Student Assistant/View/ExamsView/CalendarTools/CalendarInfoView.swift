//
//  CalendarInfoView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 14.10.2024.
//

import SwiftUI

struct CalendarInfoView: View {
    var body: some View {
        Form {
            Section {
                Text("Long press on the date to add an exam")
                HStack {
                    Text("14")
                        .frame(width: 50, height: 50)
                        .background(.gray)
                        .clipShape(Circle())
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: "arrowshape.right")
                    
                    Text("14")
                        .frame(width: 50, height: 50)
                        .background(.gray)
                        .clipShape(Circle())
                        .frame(width: 50, height: 50)
                        .padding(.bottom)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                    
                    Text("Exam day marked with red")
                        .multilineTextAlignment(.center)
                }
            } header: {
                Text("Adding a new exam")
            }
            
            Section {
                
                Text("Tap on the date to view exam details")
                
                HStack {
                    Text("14")
                        .frame(width: 50, height: 50)
                        .background(.gray)
                        .clipShape(Circle())
                        .frame(width: 50, height: 50)
                        .padding(.bottom)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                    
                    VStack {
                        Text("Exam Subject")
                            .font(.title)
                        Spacer()
                        
                        ScrollView {
                            Text("Exam Location")
                        }
                        .padding()
                        .frame(width: 250, height: 100)
                        .background(Color.white) // Background for the entire popup
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        
                        Spacer()
                        
                        HStack {
                            Text("Date   \n\(Date(), formatter: formatter())")
                                .multilineTextAlignment(.center)
                                .fontWeight(.heavy)
                            
                        }
                    }
                    .padding()
                    .frame(width: 270, height: 250)
                    .background(Color.white) // Background for the entire popup
                    .cornerRadius(20)
                    .shadow(radius: 10)
                }
            } header: {
                Text("Adding a new exam")
            }
            
        }
    }
    
    private func formatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy hh:mm"
        return formatter
    }
}

#Preview {
    CalendarInfoView()
}
