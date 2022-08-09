//
//  ContentView.swift
//  TaskManagementApp
//
//  Created by NilarWin on 01/08/2022.
//

import SwiftUI
import CoreData

struct ContentView: View {

    var body: some View {
        NavigationView {
            HomeView()
                .navigationBarTitle("Task Management")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
