import SwiftUI

struct SubTasksView: View {
    @State var baseTasks: [BaseTask]
    @State var baseIndex: Int
    @State private var addSubTask: Bool = false
    @State private var newSubTaskName: String = ""
    @State private var timeLimit: String = "12:10:08"
    @State private var newSubTaskType: SubTaskType = SubTaskType("checkbox")
    @State private var newSubTaskTypeName: String = "Checkbox"
    @State private var subTaskTypes: [String] = ["Checkbox", "Due Date", "Counter"]
    @State private var dueDate: Date = Date(timeIntervalSinceNow: 300)
    @State private var dateComponents: DatePickerComponents = .date
    
    @State private var increment: Double = 1
    @State private var limit: Double = 100
    
    @State private var hidden: Bool = false
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    func calcTimeLimit() {
        var finalTime = 0
        var times = 0
        for time in timeLimit.split(separator: ":") {
            
            
            if Int(time) != nil {
                switch times {
                case 0:
                    // hours
                    print(time)
                    finalTime += Int(time)! * 3600
                case 1:
                    // minutes
                    finalTime += Int(time)! * 60
                case 2:
                    // seconds
                    finalTime += Int(time)!
                default:
                    break
                }
                
            }
            times += 1
        }
        newSubTaskType.timeLimit = finalTime
    }
    @State private var searchText: String = ""
    @State private var sortMethod: String = "Default"
    private let sortMethods: [String] = ["Default", "A-Z", "Z-A"]
    var searchResults: [SubTask] {
        if searchText.isEmpty {
            return baseTasks[baseIndex].subTasks
        } else {
            let filteredList = baseTasks[baseIndex].subTasks.filter { $0.text.lowercased().contains(searchText.lowercased()) }
            
            return filteredList
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            TaskViewBack(name: baseTasks[baseIndex].name)
            
            HStack() {
                
                Image(colorScheme == .dark ? "FilterIconDark" : "FilterIcon")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .overlay {
                        Picker("Default", selection: $sortMethod) {
                            ForEach(sortMethods, id: \.self) { method in 
                                Text(method)
                            }
                            
                        }
                        .opacity(0.02)
                        .frame(width: 30, height: 30)
                        
                    }
                    
                    
                
                TextField("Search something here", text: $searchText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(colorScheme == .dark ? Colors.gray2Dark : Colors.gray2)
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: 30)
            .padding(10)
            .background(colorScheme == .dark ? Colors.grayDark : Colors.gray)
            Div()
            List {
                ForEach(searchResults.sorted(by: {
                    switch sortMethod {
                    case "A-Z":
                        $0.text < $1.text
                    case "Z-A":
                        $0.text > $1.text
                    default:
                        false
                    }
                }), id: \.uuid) {subTask in
                    let index = baseTasks[baseIndex].subTasks.firstIndex(of: subTask)!
                    
                    SubTaskView(baseTasks: baseTasks, baseIndex: baseIndex, index: index)
                    
                    
                }
                .onDelete(perform: { indexSet in
                    baseTasks[baseIndex].subTasks.remove(atOffsets: indexSet)
                    SaveManager.save(baseTasks)
                })
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                
                
                
            }
            .listSectionSeparator(.hidden)
            .scrollContentBackground(.hidden)
            .listStyle(.inset)
            
            
            Spacer()
            PlusButton(action: { addSubTask.toggle() })
        }
        .navigationBarBackButtonHidden()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorScheme == .dark ? Colors.backgroundDark : Colors.background)
        .sheet(isPresented: $addSubTask) {
            VStack {
                Text("Add Sub Task")
                    .font(.title)
                    .bold()
                Spacer()
                HStack {
                    Text("Label:")
                    TextField("Label", text: $newSubTaskName, axis: .vertical)
                        .modifier(TextBoxMod())
                        
                }
                HStack {
                    Text("Type:")
                    Spacer()
                    Picker("Checkbox", selection: $newSubTaskTypeName, content: {
                        ForEach(subTaskTypes, id: \.self) {name in 
                            Text(name)
                        }
                        
                    })
                    .pickerStyle(.segmented)
                    .buttonStyle(BorderedButtonStyle())
                    
                    .onChange(of: newSubTaskTypeName) {
                        newSubTaskType = SubTaskType(newSubTaskTypeName.lowercased().replacingOccurrences(of: " ", with: ""), dateDue: dueDate, increment: increment, limit: limit)
                        
                    }
                }
                
                if newSubTaskType.name == "timer" {
                    HStack {
                        Text("Time Limit:")
                        TextField("", text: $timeLimit)
                            .modifier(TextBoxMod())
                            .onChange(of: timeLimit, {
                                calcTimeLimit()
                            })
                    }
                }
                
                if newSubTaskType.name == "duedate" {
                    HStack {
                        
                        DatePicker("Due Date:", selection: $dueDate, displayedComponents: dateComponents)
                            
                        Image(systemName: "repeat")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .onTapGesture(perform: {
                                if dateComponents == .date {
                                    dateComponents = .hourAndMinute
                                }
                                else {
                                    dateComponents = .date
                                }
                                
                            })
                    }
                }
                
                if newSubTaskType.name == "counter" {
                    VStack {
                        HStack {
                            Text("Increment:")
                            TextField("", value: $increment, format: .number)
                                .modifier(TextBoxMod())
                        }
                        HStack {
                            Text("Limit:")
                            TextField("", value: $limit, format: .number)
                                .modifier(TextBoxMod())
                        }
                    }
                    
                }
                
                Button("Finish") {
                    if !newSubTaskName.isEmpty {
                        
                        addSubTask = false
                        baseTasks[baseIndex].subTasks.append(SubTask(newSubTaskName, type: newSubTaskType))
                        
                        newSubTaskName = ""
                        
                        SaveManager.save(baseTasks)
                        
                    }
                    
                }
                .buttonStyle(BorderedButtonStyle())
                
                
                Spacer()
            }
            .presentationBackground(colorScheme == .dark ? Colors.backgroundDark : Colors.background)
            .presentationDetents([.height(300)])
            .padding()
            .onAppear() {
                
                if let save = SaveManager.load() {
                    baseTasks = save
                    
                }
                
            }
        }
        
    }
}
