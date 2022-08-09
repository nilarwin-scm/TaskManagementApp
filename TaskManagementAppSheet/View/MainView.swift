//
//  MainView.swift
//  TaskManagementApp
//
//  Created by NilarWin on 03/08/2022.
//

import SwiftUI
import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

// 1.
struct ListSheet: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> ViewController {
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        ViewController()
    }
}

struct MainView: View {
    
    var body: some View {
        NavigationView(content: {
            ListSheet()
       })
       .navigationTitle("View")
       .navigationBarTitle("Text")
    }
}

struct Country {
    var isoCode: String
    var name: String
}

class ViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate ,UITableViewDataSource, UITableViewDelegate{
    
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheetsReadonly]
    private var service = GTLRSheetsService()
    let signInButton = GIDSignInButton()
    let output = UITextView()
    let driveFull = "https://www.googleapis.com/auth/drive"
    let sheetsFull = "https://www.googleapis.com/auth/spreadsheets"
    let spreadsheetId = "102ZqPIBX5x2uRYxDwYTMsEZVHUiwrjUSnRWcfFhk8ds"
    
    let tableView: UITableView = {
       let table = UITableView()
       table.translatesAutoresizingMaskIntoConstraints = false
       table.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
       table.layer.backgroundColor = UIColor.white.cgColor
       table.tableFooterView = UIView(frame: .zero)
       return table
    }()
    
    var sheetArray = [[Any]]()
    var searchValue = ""
    var textField: UITextField = UITextField()
    var googleSheetOriginArray = [[Any]]()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().clientID = "1076152026149-d62l2h4o6o92b4n9201pjfsv7sfctpmd.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance()?.scopes = [driveFull, sheetsFull]
        GIDSignIn.sharedInstance().signIn()
        
        // Add the sign-in button.
        view.addSubview(signInButton)
        output.frame = view.bounds
        output.isEditable = false
        output.contentInset = UIEdgeInsets(top: 200, left: 0, bottom: 20, right: 0)
        output.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        output.textAlignment = .center
        output.isHidden = true
        view.addSubview(output)
        print(googleSheetOriginArray.count)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        service = GTLRSheetsService()
        sheetArray = [[Any]]()
        googleSheetOriginArray = [[Any]]()
        textField.text = ""
        for view in self.view.subviews {
            view.removeFromSuperview()
        }
    }
    
    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    }
    
    func setUpHeaderView() {
        let label = UILabel(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: 40))
        label.textAlignment = .center
        label.text = "Task Management"
        label.font = label.font.withSize(20)
        self.view.addSubview(label)
        
        let datePicker: UIDatePicker = {
          let datePicker = UIDatePicker(frame: .zero)
          datePicker.datePickerMode = .date
          datePicker.timeZone = TimeZone.current
          return datePicker
        }()
        
        let textView: UITextField = {
            let textView = UITextField(frame: CGRect(x: 20, y: 60, width: self.view.frame.width - 40, height: 30))
            textView.placeholder = "04-08-2022"
            textView.layer.cornerRadius = 10
            textView.layer.borderWidth = 1
            textView.layer.borderColor = UIColor.black.cgColor
            textView.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textView.frame.height))
            textView.leftViewMode = .always
            textView.inputView = datePicker
            let doneButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(self.doneAction))
            let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 44))
            toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
            textView.inputAccessoryView = toolBar
            return textView
        }()
            
        let searchButton: UIButton = {
            let button = UIButton(frame: CGRect(x: 90, y: 100, width: self.view.frame.width - 180, height: 40))
            button.backgroundColor = UIColor(red: 23/255, green: 197/255, blue: 157/255, alpha: 1)
            button.setTitle("Search", for: UIControl.State.normal)
            button.layer.cornerRadius = 8
            button.addTarget(self, action: #selector(searchClick), for: .touchUpInside)
            return button
        }()
        let addRecordButton: UIButton = {
            let button = UIButton(frame: CGRect(x: 90, y: 150, width: self.view.frame.width - 180, height: 40))
            button.backgroundColor = UIColor(red: 23/255, green: 197/255, blue: 157/255, alpha: 1)
            button.setTitle("New Record", for: UIControl.State.normal)
            button.layer.cornerRadius = 8
            button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
            return button
        }()
        self.textField = textView
        self.view.addSubview(self.textField)
        self.view.addSubview(searchButton)
        self.view.addSubview(addRecordButton)
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
    }
    
    @objc func searchClick() {
        let searchValue: String = textField.text!
        if !(searchValue.isEmpty){
            let filterData = googleSheetOriginArray.filter{
                let row = $0
                let dateCell: String = row[2] as! String
                return dateCell.contains(searchValue)
            }
            sheetArray = filterData
            tableView.reloadData()
            if sheetArray.isEmpty {
                output.text = "No data found."
                tableView.isHidden = true
            }else{
                tableView.isHidden = false
            }
        }
    }
    
    @objc func cancelAction() {
        self.textField.resignFirstResponder()
    }

    @objc func doneAction() {
        if let datePickerView = self.textField.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let dateString = dateFormatter.string(from: datePickerView.date)
            self.textField.text = dateString
            self.textField.resignFirstResponder()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sheetArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        let row = sheetArray[indexPath.row]
        if row.count > 2 {
            cell.name?.text = row[1] as? String
            cell.assignDate?.text = row[2] as? String
        }
        if (row.count > 3) {
            if (row[3] as! String == "Finish" ){
                cell.doneButton.isHidden = true
            }else{
                cell.doneButton.isHidden = false
                cell.doneButton.addTarget(self, action: #selector(doneButtonPressed(sender:)), for: .touchUpInside)
            }
        }else {
            cell.doneButton.isHidden = false
            cell.doneButton.addTarget(self, action: #selector(doneButtonPressed(sender:)), for: .touchUpInside)
        }
        cell.deleteButton.addTarget(self, action: #selector(deleteButtonPressed(sender: )), for: .touchUpInside)
        cell.selectionStyle = .none
        return cell
    }
    
    @objc func deleteButtonPressed(sender: UIButton) {
        let rowIndex = getReturnIndex(sender: sender)
        let toDelete = GTLRSheets_DeleteRangeRequest.init()
        let gridRange = GTLRSheets_GridRange.init()
        toDelete.range = gridRange
        gridRange.sheetId =  0
        gridRange.startRowIndex = (rowIndex - 1) as NSNumber
        gridRange.endRowIndex = (rowIndex ) as NSNumber
        toDelete.shiftDimension = kGTLRSheets_DeleteRangeRequest_ShiftDimension_Rows
         
        let batchUpdate = GTLRSheets_BatchUpdateSpreadsheetRequest.init()
            let request = GTLRSheets_Request.init()
            request.deleteRange = toDelete
            batchUpdate.requests = [request]
        
        let deleteQuery = GTLRSheetsQuery_SpreadsheetsBatchUpdate.query(withObject: batchUpdate, spreadsheetId: spreadsheetId)
        service.executeQuery(deleteQuery) { (ticket, result, error) in
            if let error = error {
                self.showAlert(title: "Delete Error", message: error.localizedDescription)
                print("Delete Error : \(error.localizedDescription)")
                print(error.localizedDescription)
                return
            } else {
                self.showAlert(title: "Delete is Successfully", message: "Your progress is Done!")
                self.listMajors()
            }
            self.tableView.reloadData()
        }
    }
    
    func getReturnIndex(sender: UIButton) -> Int{
        var superview = sender.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UITableViewCell else {
            print("button is not contained in a table view cell")
            return 0
        }
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return 0
        }
        
        let index = indexPath.row + 2
        return index
    }
    
    @objc func doneButtonPressed(sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UITableViewCell else {
            print("button is not contained in a table view cell")
            return
        }
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return
        }
        
        let index = indexPath.row + 2
        let range = "Users!D\(index):D\(index)"
        let spreadsheetId = "102ZqPIBX5x2uRYxDwYTMsEZVHUiwrjUSnRWcfFhk8ds"
        let descriptions: [String: Any] = ["range" : range,
                                      "majorDimension" : "ROWS",
                                      "values" : [["Finish" as Any]]
                                     ]
        let valueRange = GTLRSheets_ValueRange(json: descriptions)
        let query = GTLRSheetsQuery_SpreadsheetsValuesUpdate.query(withObject: valueRange, spreadsheetId: spreadsheetId, range: range)
        query.valueInputOption = "USER_ENTERED"
        service.executeQuery(query) { (ticket, response, error) in
            self.showAlert(title: "Success", message: "Your progress is Done!")
            if self.sheetArray[indexPath.row].count > 3 {
                self.sheetArray[indexPath.row][3] = "Finish"
            }else{
                var rowData = self.sheetArray[indexPath.row]
                rowData.append("Finish")
                self.sheetArray[indexPath.row] = rowData
            }
            self.tableView.reloadData()
        }
    }
    
    @objc func buttonTapped(sender : UIButton) {
        //Write button action here
        let rowIndex = googleSheetOriginArray.count + 2
        let vc = UIHostingController(rootView: AddNewRecordView(rowIndex : rowIndex, service : service))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            self.service.authorizer = nil
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            print("Authentication Error : \(error.localizedDescription)")
            print(error.localizedDescription)
            return
        } else {
            self.signInButton.isHidden = true
            self.output.isHidden = false
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            let alert = UIAlertController(title: nil, message: "Getting sheet data...", preferredStyle: .alert)

            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.gray
            loadingIndicator.startAnimating();

            alert.view.addSubview(loadingIndicator)
            present(alert, animated: true, completion: nil)
            
            listMajors()
        }
    }

    func listMajors() {
       // output.text = "Getting sheet data..."
        let spreadsheetId = "102ZqPIBX5x2uRYxDwYTMsEZVHUiwrjUSnRWcfFhk8ds"
        let range = "Users!A2:D1000"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range:range)
        service.executeQuery(query, delegate: self, didFinish: #selector(ViewController.displayResultWithTicket(ticket:finishedWithObject:error:)))
    }

    // Process the response and display output
    @objc func displayResultWithTicket(ticket: GTLRServiceTicket, finishedWithObject result : GTLRSheets_ValueRange, error : NSError?) {
        dismiss(animated: false, completion: nil)
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            print(error.localizedDescription)
            return
        }
        let rows = result.values!
        sheetArray = rows
        googleSheetOriginArray = rows
        print("viewDidAppear : \(googleSheetOriginArray.count)")
        if sheetArray.count > 0 {
            setUpHeaderView()
            setUpTableView()
            tableView.reloadData()
            tableView.isHidden = false
        }
        if rows.isEmpty {
            output.text = "No data found."
            tableView.isHidden = true
            return
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

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
