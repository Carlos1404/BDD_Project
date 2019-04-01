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
    var category: String = ""
    let imagePicker = UIImagePickerController()
    var imageUrl: Data?
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var creationDate: UILabel!
    @IBOutlet weak var modificationDate: UILabel!
    @IBOutlet weak var modificationCell: UITableViewCell!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    @IBAction func cancelButton(_ sender: Any) { delegate?.itemDetailViewControllerDidCancel(self) }
    
    @IBAction func doneAction(_ sender: Any) {
        if let itemToEdit = itemToEdit {
            itemToEdit.title = titleTextField.text!
            itemToEdit.descriptions = descriptionTextField.text!
            itemToEdit.modificationDate = Date()
            CoreDataManager.instance.saveData()
            itemToEdit.category = self.categoryLabel.text
            delegate?.itemDetailViewController(self, didFinishEditingItem: itemToEdit)
        } else {
            let itemList = CoreDataManager.instance.addItem(title: titleTextField.text!, descriptions: descriptionTextField.text!)
            let itemList = ItemList(context: AppDelegate.viewContext)
            itemList.title = titleTextField.text!
            itemList.descriptions = descriptionTextField.text!
            itemList.category = category
            itemList.image = imageUrl
            itemList.creationDate = self.currentDate
            delegate?.itemDetailViewController(self, didFinishAddingItemList: itemList)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "AddCategory" {
            let destVC = segue.destination as! CategoryController
            destVC.delegate = self
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { tableView.deselectRow(at: indexPath, animated: true) }
    
    override func viewDidLoad() {
        if(itemToEdit == nil){
            self.title = "Ajout"
            self.creationDate.text = getStringOfDate(date: getCurrentDate())
            self.modificationCell.isHidden = true
        } else {
            self.title = "Edition"
            titleTextField.text = itemToEdit?.title
            descriptionTextField.text = itemToEdit?.descriptions ?? ""
            self.creationDate.text = getStringOfDate(date: itemToEdit?.creationDate)
            self.currentDate = getCurrentDate()
            self.modificationDate.text = getStringOfDate(date: currentDate)
            self.categoryLabel.text = itemToEdit?.category ?? "Category"
            if let image = itemToEdit?.image {
                self.image.image = UIImage(data: image)
            }
            self.doneButton.isEnabled = true
        }
        self.imagePicker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) { titleTextField.becomeFirstResponder() }
    
    func getCurrentDate() -> Date {
        let currentDateTime = Date()
        return currentDateTime
    }
    
    func getStringOfDate(date: Date?) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        
        if let date = date { return formatter.string(from: date) }
        else { return "" }
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
        doneButton.isEnabled = !text.isEmpty && !self.category.isEmpty
    }
}

extension SecondController: CategoryControllerDelegate {
    
    func categoryController(_ controller: CategoryController, didFinishChoosingItem item: String) {
        self.categoryLabel.text = item
        self.category = item
        doneButton.isEnabled = !titleTextField.text!.isEmpty && !self.category.isEmpty
        dismiss(animated: true)
    }
}

extension SecondController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBAction func pickAPicture(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = false
            
            present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let url = info[UIImagePickerController.InfoKey.imageURL] {
            let data = try? Data(contentsOf: url as! URL)
            self.image.image = UIImage(data: data!)
            self.imageUrl = data
        }
        
        dismiss(animated: true)
    }
    
}
