import SwiftUI

struct TasksView: View {
    @State var tasks: [BaseTask] = [BaseTask("Hello")]
    @State var addTask: Bool = false
    @State var newTaskName: String = ""
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    VStack(spacing: 0) {
                        Text("Stretches")
                            .font(.system(size: 40))
                            .bold()
                            
                    }
                        
                    Spacer()
                    Button(action: {}, label: {
                        Image(colorScheme == .dark ? "CogDark" : "Cog")
                            .resizable()
                            .frame(width: 45, height: 45)
                    })
                    
                }
                .padding(.top, 10)
                .padding(.leading, 15)
                .padding(.trailing, 15)
                .padding(.bottom, 10)
                
                Div(color: Colors.gray3, colorDark: Colors.gray3Dark)
                    
                List {
                    
                    ForEach(tasks, id: \.uuid) {task in
                        let index = tasks.firstIndex(of: task)!
                        
                        VStack(spacing: 0) {
                            
                            HStack {
                                Text(task.name)
                                
                                
                                Spacer()
                                Image(systemName: "chevron.forward")
                                    .bold()
                                
                            }
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .font(.system(size: 26))
                            .bold()
                            .overlay {
                                NavigationLink(destination: SubTasksView(baseTasks: tasks, baseIndex: index), label: {})
                                    .opacity(0)
                                    
                            }
                            
                            Div()
                        }
                        .background(colorScheme == .dark ? Colors.grayDark : Colors.gray)
                        .listRowSeparator(.hidden)
                        
                            
                            
                    }
                    .onMove(perform: { indices, newOffset in
                        tasks.move(fromOffsets: indices, toOffset: newOffset)
                        SaveManager.save(tasks)
                    })
                    .onDelete(perform: { indexSet in
                        tasks.remove(atOffsets: indexSet)
                        SaveManager.save(tasks)
                    })
                    .listRowInsets(EdgeInsets())
                    
                }
                .listSectionSeparator(.hidden)
                .scrollContentBackground(.hidden)
                .listStyle(.inset)
                
                
                
                Spacer()
                PlusButton(action: { addTask.toggle() })
                    
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colorScheme == .dark ? Colors.backgroundDark :Colors.background)
            .onAppear() {
                if let save = SaveManager.load() {
                    tasks = save
                    
                    
                }
                
            }
            
        }
        .alert("Add Task", isPresented: $addTask, actions: {
            
            TextField("New Task name", text: $newTaskName)
                
                
            
            Button("Cancel", role: .cancel) {}
            Button("Submit") {
                if !newTaskName.isEmpty {
                    tasks.append(BaseTask(newTaskName))
                    
                    SaveManager.save(tasks)
                    newTaskName = ""
                }
            }
        })
        .foregroundStyle(colorScheme == .dark ? Colors.textColorDark : Colors.textColor)
        
        
    }
}
