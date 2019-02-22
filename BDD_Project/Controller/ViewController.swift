import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var items = [Item]()
    var searchItems = [Item]()
    var searching = false
    
    let dataManager = DataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.items = dataManager.loadChecklistItems()
    }
    
    //MARK: Actions

    @IBAction func addItem(_ sender: Any) {
        let alertController = UIAlertController(title: "Add Item", message: "Write the name of the new item", preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default){ (action) in
            if let text = alertController.textFields?.first?.text, !text.isEmpty {
                self.items.append(Item(text: text))
                self.tableView.reloadData()
                self.dataManager.saveChecklistItems(list: self.items)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        alertController.addTextField()
        
        present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchItems.count
        } else {
            return items.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ListItemCell.identifier) as! ListItemCell
        if searching {
            configureText(for: cell, withItem: self.searchItems[indexPath.row])
            configureCheckmark(for: cell, withItem: self.searchItems[indexPath.row])
        } else {
            configureText(for: cell, withItem: self.items[indexPath.row])
            configureCheckmark(for: cell, withItem: self.items[indexPath.row])
        }
        
        return cell
    }
    
    func configureCheckmark(for cell: ListItemCell, withItem item: Item){
        if(item.checked){
            cell.checkItem.isHidden = false
        } else {
            cell.checkItem.isHidden = true
        }
    }
    
    func configureText(for cell: ListItemCell, withItem item: Item){
        cell.labelItem.text = item.text
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.items[indexPath.row].checkItem()
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
        dataManager.saveChecklistItems(list: self.items)
    }
    
    //MARK: Swipe Item
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit", handler: { (action, indexPath) in
            
            let alert = UIAlertController(title: "Edit", message: "Edit list item", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textItem) in
                textItem.text = self.items[indexPath.row].text
            })
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (updateAction) in
                self.items[indexPath.row].text = alert.textFields!.first!.text!
                self.tableView.reloadRows(at: [indexPath], with: .fade)
                self.dataManager.saveChecklistItems(list: self.items)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: false)
            
        })
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete"){(action, indexPath) in
            self.items.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.dataManager.saveChecklistItems(list: self.items)
        }
        
        return [deleteAction, editAction]
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            self.searching = false
        } else {
            searchItems = items.filter({$0.text.lowercased().prefix(searchText.count) == searchText.lowercased()})
            self.searching = true
        }
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searching = false
        self.tableView.reloadData()
    }
}
