//
//  HomeView.swift
//  TaskManagementApp
//
//  Created by NilarWin on 01/08/2022.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @StateObject var taskModel: TaskViewModel = TaskViewModel()
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: Task.entity(), sortDescriptors: [NSSortDescriptor(key: "deadline", ascending: true)])
    var tasks: FetchedResults<Task>
    
    // MARK: Environment Values
    @Environment(\.self) var env
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                VStack(alignment: .leading, spacing: 8){
                    Text("Welcom Back").font(.callout)
                    Text("Here's Update Today.").font(.title2.bold())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical)
                
                CustomSegmentBar()
                    .padding(.top, 5)
                TaskList()
                    .padding(.top, 10)
            }.padding()
        }.overlay(alignment: .bottom) {
            Button(action: {
                taskModel.openEditTask.toggle()
            }, label: {
                Label(title: {
                    Text("Add Task")
                }, icon: {
                    Image(systemName: "plus.app.fill")
                }).padding(.horizontal, 8)
                    .font(.system(size: 14))
            })
            .foregroundColor(.white)
            .padding(.all, 6)
            .background{
                Capsule()
                    .background(Color.black)
                    .clipped()
            }
            .clipShape(Capsule())
        }.fullScreenCover(isPresented: $taskModel.openEditTask) {
            taskModel.resetTaskData()
        }content: {
            AddNewTaskView().environmentObject(taskModel)
        }
    }
    
    @ViewBuilder
    func TaskList() -> some View{
        LazyVStack{
            DynamicFilteredView(currentTab: taskModel.currentTabs) { (task: Task) in
                VStack(alignment: .leading, spacing: 5) {
                    HStack{
                        Text(task.type ?? "").font(.system(size: 15))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.white.opacity(0.3))
                            .cornerRadius(15)
                        Spacer()
                        if !task.isCompleted && taskModel.currentTabs != "Failed" {
                            Button(action: {
                                taskModel.editTask = task
                                taskModel.openEditTask = true
                                taskModel.setupTask()
                            }, label: {
                                Image(systemName: "square.and.pencil")
                            }).foregroundColor(.black)
                        }
                    }
                    Text(task.title ?? "").padding(.vertical, 10).font(.callout.bold()).foregroundColor(.black)
                    HStack{
                        Image(systemName: "calendar")
                        Text((task.deadline ?? Date()).formatted(date: .long, time: .omitted))
                    }.font(.system(size: 12))
                    HStack {
                        HStack{
                            Image(systemName: "clock")
                            Text((task.deadline ?? Date()).formatted(date: .omitted, time: .shortened))
                        }.font(.system(size: 12))
                        
                        Spacer()
                        if !task.isCompleted && taskModel.currentTabs != "Failed" {
                            Button(action: {
                                task.isCompleted.toggle()
                                try? env.managedObjectContext.save()
                            }, label: {
                                Circle().stroke(Color.black)
                            }).frame(width: 15 ,height: 15, alignment: .trailing)
                        }
                    }
                    
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.all, 15)
                    .background{
                        RoundedRectangle(cornerRadius: 12.0, style: .continuous)
                            .fill(Color(task.color ?? "Yellow"))
                    }
            }
        }
    }
    
    @ViewBuilder
    func CustomSegmentBar() -> some View{
        let tabList = ["Today", "Upcoming", "Task Done", "Failed"]
        HStack(spacing: 10) {
            ForEach(tabList, id:\.self) {tab in
                Text(tab)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 8)
                    .foregroundColor(taskModel.currentTabs == tab ? .white : .black)
                    .background{
                        if (taskModel.currentTabs == tab){
                            Capsule()
                                .background(Color.white)
                                .clipped()
                        }
                    }
                    .clipShape(Capsule())
                    .onTapGesture {
                        withAnimation{
                            taskModel.currentTabs = tab
                        }
                    }
            }
        }
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
