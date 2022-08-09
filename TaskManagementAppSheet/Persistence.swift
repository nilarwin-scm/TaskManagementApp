//
//  Persistence.swift
//  TaskManagementApp
//
//  Created by NilarWin on 01/08/2022.
//

import Foundation
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container : NSPersistentContainer
    init() {
        container = NSPersistentContainer(name: "TaskManager")
        container.loadPersistentStores{ (storedDescription, error) in
            if let error = error {
                fatalError("Container load failed: \(error)")
            }
            
        }
    }
}
