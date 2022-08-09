//
//  TaskViewModel.swift
//  TaskManagementApp
//
//  Created by NilarWin on 01/08/2022.
//

import SwiftUI
import CoreData

class TaskViewModel: ObservableObject {
    @Published var currentTabs : String = "Today"
    
    // New Task Properties
    @Published var openEditTask : Bool = false
    @Published var taskTitle : String = ""
    @Published var taskColor : String = "Yellow"
    @Published var taskDeadline : Date = Date()
    @Published var taskType : String = "Basic"
    @Published var showDatePicker : Bool = false
    
    // Editing Existing Task Data
    @Published var editTask: Task?
    
    // Adding Task To Core Data
    func addTask(context: NSManagedObjectContext)-> Bool {
        var task: Task!
        if let editTask = editTask {
            task = editTask
        }else{
            task = Task(context: context)
        }
        task.title = taskTitle
        task.color = taskColor
        task.deadline = taskDeadline
        task.type = taskType
        task.isCompleted = false
        if let _ = try? context.save() {
            return true
        }
        return false
    }
    
    func resetTaskData() {
        taskType = "Basic"
        taskColor = "Yellow"
        taskTitle = ""
        taskDeadline = Date()
    }
    
    // edit task is avaiable then setting existing data
    func setupTask() {
        if let editTask = editTask {
            taskType = editTask.type ?? "Basic"
            taskColor = editTask.color ?? "Yellow"
            taskTitle = editTask.title ?? ""
            taskDeadline = editTask.deadline ?? Date()
        }
    }
}

