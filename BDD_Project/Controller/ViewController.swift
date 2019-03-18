import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var items = [Item]()
    var searchItems = [Item]()
    var searching = false
    var editIndexPath: Int?
    
    let dataManager = DataManager()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "AddItem" {
            let navVC = segue.destination as! UINavigationController
            let destVC = navVC.topViewController as! SecondController
            destVC.delegate = self
        }
        else if segue.identifier == "EditItem"{
            let navVC = segue.destination as! UINavigationController
            let destVC = navVC.topViewController as! SecondController
            if let indexPath = editIndexPath { destVC.itemToEdit = self.items[indexPath] }
            destVC.delegate = self
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.items = dataManager.loadChecklistItems()
    }
    
    //MARK: Actions

    @IBAction func addItem(_ sender: Any) {
        
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
        cell.titleItem.text = item.title
        cell.dateItem.text = getStringOfDate(date: item.creationDate)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.items[indexPath.row].checkItem()
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
        dataManager.saveChecklistItems(list: self.items)
    }
    
    //MARK: Swipe Item
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit", handler: { (action, indexPath) in
            self.editIndexPath = indexPath.row
            self.performSegue(withIdentifier: "EditItem", sender: self)
        })
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete"){(action, indexPath) in
            self.items.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.dataManager.saveChecklistItems(list: self.items)
        }
        
        return [deleteAction, editAction]
    }
    
    func addItem(item: Item){
        self.items.append(item)
        self.tableView.insertRows(at: [IndexPath(row: self.items.count - 1, section: 0)], with: .automatic)
        print(self.items.count)
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            self.searching = false
        } else {
            searchItems = items.filter({$0.title.lowercased().prefix(searchText.count) == searchText.lowercased()})
            self.searching = true
        }
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searching = false
        self.tableView.reloadData()
    }
}

extension ViewController: SecondControllerDelegate {
    func itemDetailViewControllerDidCancel(_ controller: SecondController) {
        dismiss(animated: true)
    }
    
    func itemDetailViewController(_ controller: SecondController, didFinishAddingItem item: Item) {
        self.addItem(item: item)
        dismiss(animated: true)
    }
    
    func itemDetailViewController(_ controller: SecondController, didFinishEditingItem item: Item) {
        let indexPath = self.items.index(where: { $0 === item})
        self.items[indexPath!] = item
        tableView.reloadRows(at: [IndexPath(item: indexPath!, section: 0)], with: UITableView.RowAnimation.automatic)
        dismiss(animated: true)
    }
}
