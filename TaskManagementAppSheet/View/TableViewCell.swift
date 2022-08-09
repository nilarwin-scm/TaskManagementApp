//
//  TableViewCell.swift
//  TaskManagementApp
//
//  Created by NilarWin on 04/08/2022.
//

import Foundation
import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var taskCellView: UIView!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var assignDate: UILabel!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        taskCellView.layer.cornerRadius = 10
        taskCellView.layer.borderColor = UIColor.green.cgColor
        taskCellView.layer.borderWidth = 1.0
    }
 
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

