//
//  AddNewRecordView.swift
//  TaskManagementAppSheet
//
//  Created by NilarWin on 05/08/2022.
//

import SwiftUI
import UIKit
import GoogleAPIClientForREST
import GoogleSignIn


struct AnotherControllerView : UIViewControllerRepresentable {
    typealias UIViewControllerType = AnotherController
    var savePhotoDelegate: AnotherController? = AnotherController()

    func savePhoto(task: String, assignDate: String , rowIndex: Int, service :GTLRSheetsService){
        savePhotoDelegate?.savePhoto(task: task, assignDate: assignDate, rowIndex: rowIndex, service :service)
    }
    
    func dismissVC() {
        savePhotoDelegate?.dismissVC()
    }
    
    func makeUIViewController(context: Context) -> AnotherController {
        return AnotherController()
    }
    
    func updateUIViewController(_ uiViewController: AnotherController, context: Context) { }
}

struct AddNewRecordView: View {
    @State var assignDate = Date()
    @State var task = ""
    @State var showDatePicker = false
    var rowIndex : Int
    var service = GTLRSheetsService()
    @State private var taskNull = false
    
    let anotherControllerView = AnotherControllerView()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 12){
            Text("Add New Task")
                .font(.title3.bold())
                .frame(maxWidth: .infinity)
            
            VStack (alignment: .leading, spacing: 20){
                
                Text("Assign Date ")
                    .font(.system(size: 12)).opacity(0.5)
                
                HStack {
                    Text(assignDate.formatted(date: .abbreviated, time: .omitted) + ", " +  assignDate.formatted(date: .omitted, time: .shortened))
                    .font(.callout)
                    .fontWeight(.semibold)
                    .padding(.top, 8)
                    .onTapGesture {
                        showDatePicker = true
                    }
                    Spacer()
                    Image(systemName: "calendar")
                }
                Divider()
                Text("Task Title")
                    .font(.system(size: 12)).opacity(0.5)
                TextField("Title", text: $task)
                Rectangle().frame(height: 1)
                    .padding(.horizontal, 0).foregroundColor(Color.black.opacity(0.15))
   
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .overlay(alignment: .bottom){
            VStack(spacing:12){
                Button(action: {
                    taskNull = task.isEmpty
                    if taskNull == false{
                        saveRecord()
                    }
                }, label: {
                    Text("Save Task")
                })
                .alert("Task is required field", isPresented: $taskNull) {
                     Button("OK", role: .cancel) { }
                 }
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
                if showDatePicker {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showDatePicker = false
                        }
                    
                    // MARK: Disabling Past Dates
                    DatePicker("",
                               selection: $assignDate,
                               in: Date.now...Date.distantFuture)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .padding()
                    .background(.white, in: RoundedRectangle(cornerSize: .init(width: 12, height: 12), style: .continuous))
                    .padding()
                }
            }
            .animation(.easeInOut, value: showDatePicker)
        }
    }
    
    func saveRecord() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateString = dateFormatter.string(from: assignDate)
        self.anotherControllerView.savePhoto(task: task, assignDate: "\(dateString)", rowIndex: rowIndex, service :service)
        presentationMode.wrappedValue.dismiss()
    }
}

class AnotherController : UIViewController {
    var service = GTLRSheetsService()
    let driveFull = "https://www.googleapis.com/auth/drive"
    let sheetsFull = "https://www.googleapis.com/auth/spreadsheets"
    var presentedControllers : UINavigationController?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let hostVC = UIHostingController(rootView: AddNewRecordView(rowIndex : 22, service : self.service))
           let navVC = UINavigationController(rootViewController: hostVC)
            self.presentedControllers = navVC
       }
    }
    
    
        
    func dismissVC() {
       // presentedControllers?.popViewController(animated: true)
        print("dismissVC")
        //self.presentingViewController?.dismiss(animated: true, completion: nil)
//        presentedControllers?.dismiss(animated: false, completion: nil)
        let vc = UIHostingController(rootView: MainView())
        self.navigationController?.pushViewController(vc, animated: true)
    }
        
    func savePhoto(task: String, assignDate: String , rowIndex: Int, service : GTLRSheetsService){
        self.service = service
        let range = "Users!A\(rowIndex):D\(rowIndex)"
        let spreadsheetId = "102ZqPIBX5x2uRYxDwYTMsEZVHUiwrjUSnRWcfFhk8ds"
        let descriptions: [String: Any] = ["range" : range,
                                      "majorDimension" : "ROWS",
                                      "values" : [["\(rowIndex - 1)", task, assignDate]]
                                     ]
        let valueRange = GTLRSheets_ValueRange(json: descriptions)
        let query = GTLRSheetsQuery_SpreadsheetsValuesUpdate.query(withObject: valueRange, spreadsheetId: spreadsheetId, range: range)
        query.valueInputOption = "USER_ENTERED"
        service.executeQuery(query) { (ticket, response, error) in
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                print(error.localizedDescription)
                return
            }
        }
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController( title: title, message: message,preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}

