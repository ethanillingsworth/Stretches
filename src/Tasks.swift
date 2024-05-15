import SwiftUI

struct CounterButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}


struct SubTaskView: View {
    @State var baseTasks: [BaseTask]
    @State var baseIndex: Int
    @State var index: Int
    @State var iconTapped: Bool = false
    @State private var showEdit: Bool = false
    @State private var showEditMenu: Bool = false
    @State private var editLabel: Bool = false
    @State private var editCount: Bool = false
    @State private var editIncrement: Bool = false
    @State private var editLimit: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    func reload() {
        if let save = SaveManager.load() {
            baseTasks = save
        }
    }
    
    
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(spacing: 0) {
                    switch baseTasks[baseIndex].subTasks[index].type.name {
                    case "checkbox":
                        if colorScheme == .dark {
                            Image(iconTapped ? "CheckboxCheckedDark" : "CheckboxDark")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .onTapGesture(perform: {
                                    iconTapped.toggle()
                                    
                                    reload()
                                    
                                    baseTasks[baseIndex].subTasks[index].type.checked = iconTapped
                                    
                                    SaveManager.save(baseTasks)
                                })
                                .onAppear() {
                                    iconTapped = baseTasks[baseIndex].subTasks[index].type.checked
                                }
                        }
                        else {
                            Image(iconTapped ? "CheckboxChecked" : "Checkbox")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .onTapGesture(perform: {
                                    iconTapped.toggle()
                                    
                                    reload()
                                    
                                    baseTasks[baseIndex].subTasks[index].type.checked = iconTapped
                                    
                                    SaveManager.save(baseTasks)
                                })
                                .onAppear() {
                                    iconTapped = baseTasks[baseIndex].subTasks[index].type.checked
                                }
                        }
                    case "duedate":
                        Text("Due Date")
                        Div(width: 150)
                        if Date.now >= baseTasks[baseIndex].subTasks[index].type.dateDue {
                            Text(baseTasks[baseIndex].subTasks[index].type.dateDue.formatted())
                                .foregroundStyle(.red)
                        }
                        else {
                            Text(baseTasks[baseIndex].subTasks[index].type.dateDue.formatted())
                        }
                    case "counter":
                        HStack {
                            ZStack {
                                Image(colorScheme == .dark ? "CounterBGDark" : "CounterBG")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                ZStack {
                                    HStack(spacing: 0) {
                                        Button(action: {
                                            reload()
                                            baseTasks[baseIndex].subTasks[index].type.counterValue -= baseTasks[baseIndex].subTasks[index].type.increment
                                            
                                            SaveManager.save(baseTasks)
                                            
                                        }) {
                                            Image(colorScheme == .dark ? "CounterMinusDark" : "CounterMinus")
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                        }
                                        .buttonStyle(CounterButtonStyle())
                                        
                                        Button(action: {
                                            reload()
                                            baseTasks[baseIndex].subTasks[index].type.counterValue += baseTasks[baseIndex].subTasks[index].type.increment
                                            SaveManager.save(baseTasks)
                                        }) {
                                            Image(colorScheme == .dark ? "CounterPlusDark" : "CounterPlus")
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                        }
                                        .buttonStyle(CounterButtonStyle())
                                    }
                                }
                            }
                            VStack(spacing: 0) {
                                if editCount {
                                    TextField("100", value: $baseTasks[baseIndex].subTasks[index].type.counterValue, format: .number)
                                        .onSubmit {
                                            editCount = false
                                            SaveManager.save(baseTasks)
                                        }
                                        .modifier(TextBoxMod())
                                        .frame(maxWidth: 75)
                                        
                                }
                                else {
                                    Text(baseTasks[baseIndex].subTasks[index].type.counterValue.formatted(.number))
                                }
                                Div(width: 50)
                                if editLimit {
                                    TextField("100", value: $baseTasks[baseIndex].subTasks[index].type.counterLimit, format: .number)
                                        .onSubmit {
                                            editLimit = false
                                            SaveManager.save(baseTasks)
                                        }
                                        .modifier(TextBoxMod())
                                        .frame(maxWidth: 75)
                                    
                                }
                                else {
                                    Text(baseTasks[baseIndex].subTasks[index].type.counterLimit.formatted(.number))
                                }
                            }
                        }
                        
                    default:
                        EmptyView()
                    }
                        
                }
                .onTapGesture() {
                    iconTapped.toggle()
                    
                }
                .bold()
                .animation(.easeInOut(duration: 0.25), value: iconTapped)
                
                
                Rectangle()
                    .frame(maxWidth: 2, maxHeight: .infinity)
                    .foregroundStyle(colorScheme == .dark ? Colors.gray2Dark : Colors.gray2)
                
                
                if editLabel {
                    TextField("You should put some text here", text: $baseTasks[baseIndex].subTasks[index].text, axis: .vertical)
                        .bold()
                        .font(.system(size: 20))
                        .onSubmit() {
                            editLabel = false
                            SaveManager.save(baseTasks)
                        }
                        .padding(5)
                        .border(Colors.gray3, width: 1)
                        
                }
                else {
                    Text(baseTasks[baseIndex].subTasks[index].text)
                        .bold()
                        .font(.system(size: 20))
                }
                Spacer()
                if showEdit {
                    
                    Image(colorScheme == .dark ? "EditDark" : "Edit")
                        .resizable()
                        .frame(maxWidth: 50, maxHeight: 50)
                        .onTapGesture() {
                            showEditMenu.toggle()
                        }
                    
                }
            }
            .frame(minHeight: 50, maxHeight: 50)
            .padding(10)
            .background(colorScheme == .dark ? Colors.grayDark : Colors.gray)
            .animation(.easeInOut(duration: 0.25), value: showEdit)
            .onTapGesture(perform: {
                showEdit.toggle()
            })
            
            .alert("Edit Task", isPresented: $showEditMenu, actions: {
                if baseTasks[baseIndex].subTasks[index].type.name == "timer" {
                    Button("Edit Time") {}
                }
                
                if baseTasks[baseIndex].subTasks[index].type.name == "counter" {
                    Button("Edit Count") { editCount = true }
                    Button("Edit Increment") { editIncrement = true }
                    Button("Edit Limit") { editLimit = true }
                }
                
                Button("Edit Label") {
                    
                    editLabel = true
                }
                    
                
                Button("Cancel", role: .cancel) {}
            })
            .alert("Change Increment", isPresented: $editIncrement, actions: {
                TextField("1", value: $baseTasks[baseIndex].subTasks[index].type.increment, format: .number)
                    .foregroundStyle(.white)
                Button("Cancel", role: .cancel) {}
                Button("Submit") {
                    editIncrement = false
                    SaveManager.save(baseTasks)
                }
            })
            
            Div()
            
        }
    }
}


struct TaskViewBack: View {
    @State var name: String
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                HStack {
                    
                    Image(systemName: "chevron.backward")
                        .bold()
                    Spacer()
                    Text(name)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 50)
                .font(.system(size: 26))
                .bold()
            })
            
            Div()
        }
        .background(colorScheme == .dark ? Colors.grayDark : Colors.gray)
    }
}

struct BaseTask: Codable, Equatable {
    var name: String
    var uuid: UUID = UUID()
    var subTasks: [SubTask] = []
    
    init(_ name: String) {
        self.name = name
    }
    
}

struct SubTask: Codable, Equatable {
    var text: String
    var uuid: UUID = UUID()
    var type: SubTaskType
    
    init(_ text: String, type: SubTaskType) {
        self.text = text
        self.type = type
    }
    
}

struct SubTaskType: Codable, Equatable, Hashable {
    
    // generic
    let name: String
    // checkbox
    var checked: Bool = false
    // timer (unused for now)
    var timeElapsed: Int = 300
    var timeLimit: Int = 300
    // due date
    var dateDue: Date = Date(timeIntervalSinceNow: 300)
    // counter
    var counterValue: Double = 05
    var increment: Double = 1
    var counterLimit: Double = 100
    init(_ name: String) {
        self.name = name
        
    }
    
    init(_ name: String, dateDue: Date, increment: Double, limit: Double) {
        self.name = name
        self.dateDue = dateDue
        self.increment = increment
        self.counterLimit = limit
    }
}
