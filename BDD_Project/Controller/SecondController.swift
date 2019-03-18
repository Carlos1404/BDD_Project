//
//  SecondController.swift
//  BDD_Project
//
//  Created by lpiem on 22/02/2019.
//  Copyright © 2019 lpiem. All rights reserved.
//

import Foundation
import UIKit

class SecondController: UITableViewController {
    
    var delegate: SecondControllerDelegate?
    
    var itemToEdit: ItemList?
    var currentDate: Date?
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var creationDate: UILabel!
    @IBOutlet weak var modificationDate: UILabel!
    @IBOutlet weak var modificationCell: UITableViewCell!
    
    @IBAction func cancelButton(_ sender: Any) {
        delegate?.itemDetailViewControllerDidCancel(self)
    }
    @IBAction func doneAction(_ sender: Any) {
        if let itemToEdit = itemToEdit {
            itemToEdit.title = self.titleTextField.text!
            itemToEdit.descriptions = self.descriptionTextField.text!
            delegate?.itemDetailViewController(self, didFinishEditingItem: itemToEdit)
        } else {
            let itemList = ItemList(context: AppDelegate.viewContext)
            itemList.title = titleTextField.text!
            itemList.descriptions = descriptionTextField.text!
            itemList.creationDate = self.currentDate
            delegate?.itemDetailViewController(self, didFinishAddingItemList: itemList)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewDidLoad() {
        if(itemToEdit == nil){
            self.title = "Ajout"
            self.currentDate = getCurrentDate()
            self.creationDate.text = getStringOfDate(date: currentDate)
            self.modificationCell.isHidden = true
        } else {
            self.title = "Edition"
            titleTextField.text = itemToEdit?.title
            descriptionTextField.text = itemToEdit?.descriptions ?? ""
            self.creationDate.text = getStringOfDate(date: itemToEdit?.creationDate)
            self.currentDate = getCurrentDate()
            self.modificationDate.text = getStringOfDate(date: currentDate)
            self.doneButton.isEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        titleTextField.becomeFirstResponder()
    }
    
    func getCurrentDate() -> Date {
        // get the current date and time
        let currentDateTime = Date()
        return currentDateTime
    }
    
    func getStringOfDate(date: Date?) -> String {
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        
        if let date = date {
            return formatter.string(from: date)
        } else {
            return ""
        }
    }
    
}

protocol SecondControllerDelegate : class {
    func itemDetailViewControllerDidCancel(_ controller: SecondController)
    func itemDetailViewController(_ controller: SecondController, didFinishAddingItemList item: ItemList)
    func itemDetailViewController(_ controller:SecondController,didFinishEditingItem item: ItemList)
}

extension SecondController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldString = titleTextField.text!
        let newString = oldString.replacingCharacters(in: Range(range, in: oldString)!, with: string)
        checkFields(text: newString)
        return true
    }
    
    func checkFields(text: String){
        doneButton.isEnabled = !text.isEmpty
    }
    
}
