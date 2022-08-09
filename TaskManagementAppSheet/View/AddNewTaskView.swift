//
//  AddNewTaskView.swift
//  TaskManagementApp
//
//  Created by NilarWin on 01/08/2022.
//

import SwiftUI

struct AddNewTaskView: View {
    
    @EnvironmentObject var taskModel: TaskViewModel
    @Environment(\.self) var env
    @State var selectedDate = Date()
    @State var title = ""
    @State var showDatePicker: Bool = false
    
    @State var savedDate: Date? = Date()
    @State var taskType: String = "Basic"
    var body: some View {
        
        VStack(spacing: 12){
            Text("Edit Task")
                .font(.title3.bold())
                .frame(maxWidth: .infinity)
                .overlay(alignment: .leading){
                    Button(action: {
                        env.dismiss()
                    }, label: {
                        Image(systemName: "arrow.left")
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.black)
                    })
                }
                .overlay(alignment: .trailing){
                    Button(action: {
                        if let editTask = taskModel.editTask {
                            env.managedObjectContext.delete(editTask)
                            try? env.managedObjectContext.save()
                            env.dismiss()
                        }
                    }, label: {
                        Image(systemName: "trash")
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.red)
                    }).opacity(taskModel.editTask == nil ? 0 : 1)
                }
            
            VStack (alignment: .leading, spacing: 20){
                VStack (alignment: .leading, spacing: 20){
                    Text("Task Color")
                    HStack(spacing: 5){
                        let colors = ["Yellow", "Green", "Blue", "Purple", "Red", "Orange"]
                        ForEach(colors, id:\.self) { color in
                            Button(action: {
                                taskModel.taskColor = color
                            }, label: {
                                RoundedRectangle(cornerRadius: 50, style: .continuous).fill(Color(color))
                            })
                            .overlay(
                                RoundedRectangle(cornerRadius: 50, style: .continuous).strokeBorder(taskModel.taskColor == color ? Color.black : Color.white, lineWidth: 1)
                            )
                            .frame(width: 25, height: 25)
                        }
                    }
                    Divider()
                }.frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Task Deadline")
                    .font(.system(size: 12)).opacity(0.5)
                
                HStack {
                    Text(taskModel.taskDeadline.formatted(date: .abbreviated, time: .omitted) + ", " +  taskModel.taskDeadline.formatted(date: .omitted, time: .shortened))
                    .font(.callout)
                    .fontWeight(.semibold)
                    .padding(.top, 8)
                    .onTapGesture {
                        taskModel.showDatePicker.toggle()
                    }
                    Spacer()
                    Image(systemName: "calendar")
                }
                
                Divider()
                
                Text("Task Title")
                    .font(.system(size: 12)).opacity(0.5)
                
                TextField("Title", text: $taskModel.taskTitle)
                
                Rectangle().frame(height: 1)
                    .padding(.horizontal, 0).foregroundColor(Color.black.opacity(0.15))
                
                Text("Task Type").font(.system(size: 12)).opacity(0.5)
                
                HStack(spacing: 10){
                    let taskTypes = ["Basic", "Urgent", "Important"]
                    ForEach(taskTypes , id:\.self){tab in
                        Text(tab)
                            .font(.callout)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 8)
                            .foregroundColor(taskModel.taskType == tab ? .white : .black)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.black, lineWidth: 3)
                            )
                            .background{
                                if (taskModel.taskType == tab){
                                    Capsule()
                                        .background(Color.white)
                                        .clipped()
                                }
                            }
                            .clipShape(Capsule())
                            .onTapGesture {
                                taskModel.taskType = tab
                            }
                    }
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
            
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .overlay(alignment: .bottom){
            VStack(spacing:12){
                Button(action: {
                    if taskModel.addTask(context: env.managedObjectContext){
                        env.dismiss()
                    }
                }, label: {
                    Text("Save Task")
                })
                .frame(width: 300)
                .foregroundColor(.white)
                .padding(.vertical, 6)
                .background{
                    Capsule()
                        .background(Color.black)
                        .clipped()
                }
                .clipShape(Capsule())
            }
        }
        .overlay {
            ZStack {
                if taskModel.showDatePicker {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .onTapGesture {
                            taskModel.showDatePicker = false
                        }
                    
                    // MARK: Disabling Past Dates
                    DatePicker("",
                               selection: $taskModel.taskDeadline,
                               in: Date.now...Date.distantFuture)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .padding()
                    .background(.white, in: RoundedRectangle(cornerSize: .init(width: 12, height: 12), style: .continuous))
                    .padding()
                }
            }
            .animation(.easeInOut, value: taskModel.showDatePicker)
        }
    }
}

struct DatePickerWithButtons: View {
    
    @Binding var showDatePicker: Bool
    @Binding var savedDate: Date?
    @State var selectedDate: Date = Date()
    
    var body: some View {
        ZStack {
            VStack {
                DatePicker("Test", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(GraphicalDatePickerStyle())
                Divider()
                HStack {
                    
                    Button(action: {
                        showDatePicker = false
                    }, label: {
                        Text("Cancel")
                    })
                    
                    Spacer()
                    
                    Button(action: {
                        savedDate = selectedDate
                        showDatePicker = false
                    }, label: {
                        Text("Save".uppercased())
                            .bold()
                    })
                    
                }
                .padding(.horizontal)
            }
            .padding()
            .background(
                Color.white
                    .cornerRadius(30)
            )
        }

    }
}

struct AddNewTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewTaskView().environmentObject(TaskViewModel())
    }
}
