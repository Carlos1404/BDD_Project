import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var items = [ItemList]()
    var searchItems = [ItemList]()
    var searching = false
    let coreDataManager = CoreDataManager.instance
    var editIndexPath: Int?
    
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
        reloadData()
    }
    
    func reloadData() {
        self.items = coreDataManager.loadChecklistItems()
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return searching ? searchItems.count : items.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListItemCell.identifier) as! ListItemCell
        cell.item = searching ? self.searchItems[indexPath.row] : self.items[indexPath.row]
        return cell
    }
    
    func configureCheckmark(for cell: ListItemCell, withItem item: ItemList){
        if(item.checked){ cell.checkItem.isHidden = false }
        else { cell.checkItem.isHidden = true }
    }
    
    func configureText(for cell: ListItemCell, withItem item: ItemList){
        cell.titleItem.text = item.title
        cell.dateItem.text = getStringOfDate(date: item.creationDate)
    }
    
    func getStringOfDate(date: Date?) -> String {
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        
        if let date = date { return formatter.string(from: date) }
        else { return "" }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.items[indexPath.row].checked = !self.items[indexPath.row].checked
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    //MARK: Swipe Item
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: "Edit", handler: { (action, indexPath) in
            self.editIndexPath = indexPath.row
            self.performSegue(withIdentifier: "EditItem", sender: self)
        })
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete"){(action, indexPath) in
            self.coreDataManager.deleteItem(item: self.items[indexPath.row])
            self.items.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [deleteAction, editAction]
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        /*
        if searchText.isEmpty{
            self.searching = false
        } else {
            searchItems = items.filter({$0.title?.lowercased().prefix(searchText.count) == searchText.lowercased()})
            self.searching = true
        }
        self.tableView.reloadData()
        */
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        tableView.reloadData()
    }
}

extension ViewController: SecondControllerDelegate {
    func itemDetailViewControllerDidCancel(_ controller: SecondController) { dismiss(animated: true) }
    
    func itemDetailViewController(_ controller: SecondController, didFinishAddingItemList item: ItemList) {
        reloadData()
        dismiss(animated: true)
    }
    
    func itemDetailViewController(_ controller: SecondController, didFinishEditingItem item: ItemList) {
        let indexPath = self.items.index(where: { $0 === item})
        items[indexPath!] = item
        tableView.reloadRows(at: [IndexPath(item: indexPath!, section: 0)], with: UITableView.RowAnimation.automatic)
        dismiss(animated: true)
    }
}
