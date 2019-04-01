//
//  CategoryController.swift
//  BDD_Project
//
//  Created by lpiem on 01/04/2019.
//  Copyright © 2019 lpiem. All rights reserved.
//

import Foundation
import UIKit

class CategoryController: UITableViewController {
    
    var list = [Category]()
    @IBOutlet var listTableView: UITableView!
    
    var delegate: CategoryControllerDelegate?
    @IBAction func addButton(_ sender: Any) {
        showInputDialog()
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadData()
    }
    
    func reloadData() {
        self.list = CoreDataManager.instance.loadCategories()
        self.listTableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "Category", for: indexPath)
        let text = list[indexPath.row].title
        cell.textLabel?.text = text
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.categoryController(self, didFinishChoosingItem: list[indexPath.row].title ?? "No category")
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.list.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete"){(action, indexPath) in
            self.list.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [deleteAction]
    }
    
    func showInputDialog() {
    
        let alertController = UIAlertController(title: "Nouvelle catégorie", message: "Entrer une catégorie", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Ajouter", style: .default) { (_) in
            
            //getting the input values from user
            let name = alertController.textFields?[0].text
            let categoryList = Category(context: CoreDataManager.instance.viewContext)
            categoryList.title = name
            CoreDataManager.instance.saveData()
            self.list.append(categoryList)
            self.listTableView.reloadData()
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Catégorie"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
}

protocol CategoryControllerDelegate : class {
    func categoryController(_ controller: CategoryController, didFinishChoosingItem item: String)
}
