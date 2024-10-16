//
//  AddAssignmentView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 12.10.2024.
//
import SwiftUI

enum Focus {
    case title
    case description
}

struct AddAssignmentView: View {
    
    @ObservedObject var vm = AssignmentListViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var dueDate: Date = Date()
    @State private var dueHour: Date = Date()
    @State private var showAlert: Bool = false
    @FocusState var focusField: Focus?
    
    var body: some View {
        
        VStack(spacing: 10) {
            Text("Add New Assignment")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            TextField("Assignment Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocorrectionDisabled()
                .padding()
                .focused($focusField, equals: .title)
            
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $description)
                    .autocorrectionDisabled()
                    .frame(minHeight: 140)
                    .cornerRadius(8)
                    .padding(1)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .focused($focusField, equals: .description)
                
                if description.isEmpty {
                    Text("Enter assignment description...")
                        .foregroundColor(Color.gray)
                        .padding(.horizontal, 25)
                        .padding(.top, 10)
                }
            }
            
            // DatePicker inside VStack
            VStack {
                DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    .datePickerStyle(DefaultDatePickerStyle())
                    .tint(.myRed.opacity(0.6))
                    .padding(.horizontal)
                
                DatePicker("Due Time", selection: $dueHour, displayedComponents: .hourAndMinute)
                    .tint(.lightBlue)
                    .padding(.horizontal)
            }
            .padding(.vertical, 10) // Add some spacing
            
            Button(action: {
                let calendar = Calendar.current
                let finalDate = calendar.date(bySettingHour: calendar.component(.hour, from: dueHour),
                                              minute: calendar.component(.minute, from: dueHour),
                                              second: 0,
                                              of: dueDate) ?? Date()
                
                if vm.addAssignment(title: title, description: description, dueDate: finalDate) {
                    title = ""
                    description = ""
                    dueDate = Date()
                    dueHour = Date()
                    presentationMode.wrappedValue.dismiss()
                } else {
                    showAlert.toggle()
                }
            }) {
                Text("Create Assignment")
                    .font(.body)
                    .fontWeight(.heavy)
                    .frame(width: 200, height: 50)
                    .foregroundColor(.white)
                    .background(Color.myRed)
                    .cornerRadius(10)
            }
            .padding(.top)
            
            .padding()
        }
        .onAppear {
            focusField = .title
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Not created"), message: Text("Assignment must have a title and a description."))
        }
        .onTapGesture {
            dismissKeyboard()
        }
    }
    
    // Function to dismiss the keyboard
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    AddAssignmentView()
}
