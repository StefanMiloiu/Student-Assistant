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
    @ObservedObject var vm = AssignmentListViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var dueDate: Date = Date()
    @State private var dueHour: Date = Date()
    @State private var showAlert: Bool = false
    @FocusState private var focusField: Focus?

    var body: some View {
        VStack(spacing: 10) {
            // Title
            Text("Add New Assignment")
                .font(.largeTitle)
                .fontWeight(.bold)

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
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                            .datePickerStyle(DefaultDatePickerStyle())
                            .tint(.myRed.opacity(0.6))

                        DatePicker("Due Time", selection: $dueHour, displayedComponents: .hourAndMinute)
                            .tint(.myRed)
                    }
                }
            }
            .onAppear {
                // Set initial focus
                focusField = .title
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Not created"), message: Text("Assignment must have a title and a description."))
            }

            // MARK: - Create Assignment Button
            Button(action: createAssignment) {
                Text("Create Assignment")
                    .font(.body)
                    .fontWeight(.heavy)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .foregroundColor(.white)
                    .background(Color.myRed)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
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

        if vm.addAssignment(title: title, description: description, dueDate: finalDate) {
            // Reset fields after creating assignment
            title = ""
            description = ""
            dueDate = Date()
            dueHour = Date()
            presentationMode.wrappedValue.dismiss() // Dismiss the view
        } else {
            showAlert.toggle() // Show alert if assignment creation fails
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
