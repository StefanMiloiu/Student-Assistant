import SwiftUI

// MARK: - Focus Enum
enum Focus {
    case title
    case description
    case subject
}

// MARK: - AddAssignmentView
struct AddAssignmentView: View {
    
    // MARK: - Properties
    @EnvironmentObject var vm: AssignmentListViewModel
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl
    @Environment(\.presentationMode) var presentationMode
    
    @State var title: String = ""
    @State var description: String = ""
    @State var dueDate: Date = Date()
    @State var dueHour: Date = Date()
    @State private var showAlert: Bool = false
    @State var isModified: Bool = false
    var assignment: Assignment? = nil
    @FocusState private var focusField: Focus?
    
    
    var body: some View {
        VStack(spacing: 10) {
            // Form for entering assignment details
            Form {
                // MARK: - Title Section
                Section {
                    TextField("Assignment Title", text: $title)
                        .autocorrectionDisabled()
                        .focused($focusField, equals: .title)
                }
                
                // MARK: - Description Section
                Section {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $description)
                            .autocorrectionDisabled()
                            .frame(minHeight: 140)
                            .cornerRadius(8)
                            .focused($focusField, equals: .description)
                        
                        // Placeholder for description
                        if description.isEmpty {
                            Text("Enter assignment description...")
                                .foregroundColor(Color.gray)
                                .padding(.top, 10)
                        }
                    }
                }
                
                // MARK: - Due Date and Time Section
                Section {
                    VStack {
                        DatePicker("Due Date", selection: $dueDate, in: Date()..., displayedComponents: .date)
                            .datePickerStyle(DefaultDatePickerStyle())
                            .tint(.appTiffanyBlue.opacity(0.6))
                        
                        DatePicker("Due Time", selection: $dueHour, displayedComponents: .hourAndMinute)
                            .tint(.appTiffanyBlue)
                    }
                }
            }
            .onAppear {
                // Set initial focus
                focusField = .title
                if assignment != nil {
                    isModified.toggle()
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Not created"), message: Text("Assignment must have a title and a description."))
            }
            
            // MARK: - Create Assignment Button
            Button(action: createAssignment) {
                Text("\(isModified ? "Modify" : "Create Assignment")")
                    .font(.body)
                    .fontWeight(.heavy)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .foregroundColor(.white)
                    .background(Color.appTiffanyBlue)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .padding(.bottom, 5)
        }
        .background(.gray.opacity(0.1))
        .navigationTitle("\(isModified ? "Modify Assignment" : "Add New Assignment")")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            dismissKeyboard() // Dismiss keyboard on tap outside
        }
    }
    
    // MARK: - Functions
    /// Create a new assignment and dismiss the view
    private func createAssignment() {
        let calendar = Calendar.current
        let finalDate = calendar.date(bySettingHour: calendar.component(.hour, from: dueHour),
                                      minute: calendar.component(.minute, from: dueHour),
                                      second: 0,
                                      of: dueDate) ?? Date()
        if let assignment {
            if vm.updateAssignment(assignment, title: title, description: description, dueDate: finalDate) {
                title = ""
                description = ""
                dueDate = Date()
                dueHour = Date()
                appCoordinator.pop()
            } else {
                showAlert.toggle() // Show alert if assignment creation fails
            }
        } else {
            print("Add assignment")
            if vm.addAssignment(title: title, description: description, dueDate: finalDate) {
                // Reset fields after creating assignment
                title = ""
                description = ""
                dueDate = Date()
                dueHour = Date()
                appCoordinator.pop()
            } else {
                showAlert.toggle() // Show alert if assignment creation fails
            }
        }
    }
    
    /// Function to dismiss the keyboard
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    AddAssignmentView()
}
