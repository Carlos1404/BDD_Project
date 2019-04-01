import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var items = [ItemList]()
    var searchItems = [ItemList]()
    var searching = false
    let coreDataManager = CoreDataManager()
    var editIndexPath: Int?
    var categories = [Category]()
    
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
        self.categories = CoreDataManager.shared.loadCategories()
        reloadData()
    }
    
    func reloadData() {
        self.items = coreDataManager.loadChecklistItems()
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searching ? searchItems.count : items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListItemCell.identifier) as! ListItemCell
        cell.item = searching ? self.searchItems[indexPath.row] : self.items[indexPath.row]
        return cell
    }
    
    func configureCheckmark(for cell: ListItemCell, withItem item: ItemList){
        if(item.checked){
            cell.checkItem.isHidden = false
        } else {
            cell.checkItem.isHidden = true
        }
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
        
        if let date = date {
            return formatter.string(from: date)
        } else {
            return ""
        }
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
            self.items.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            //self.dataManager.saveChecklistItems(list: self.items)
            self.coreDataManager.saveChecklistItem()
        }
        return [deleteAction, editAction]
    }
    
    func addItem(item: ItemList){
        /*self.tableView.insertRows(at: [IndexPath(row: self.items.count - 1, section: 0)], with: .automatic)
        print(self.items.count)*/
        self.coreDataManager.saveChecklistItem()
        self.reloadData()
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        /*if searchText.isEmpty{
            self.searching = false
        } else {
            searchItems = items.filter({$0.title.lowercased().prefix(searchText.count) == searchText.lowercased()})
            self.searching = true
        }
        self.tableView.reloadData()*/
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
    
    @objc(itemDetailViewController:didFinishAddingItemList:) func itemDetailViewController(_ controller: SecondController, didFinishAddingItemList item: ItemList) {
        self.addItem(item: item)
        dismiss(animated: true)
    }
    
    func itemDetailViewController(_ controller: SecondController, didFinishEditingItem item: ItemList) {
        let indexPath = self.items.index(where: { $0 === item})
        self.items[indexPath!] = item
        tableView.reloadRows(at: [IndexPath(item: indexPath!, section: 0)], with: UITableView.RowAnimation.automatic)
        dismiss(animated: true)
    }
}

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    
    @IBAction func categoryButton(_ sender: Any) {
        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 300)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 300))
        pickerView.delegate = self
        pickerView.dataSource = self
        vc.view.addSubview(pickerView)
        let editRadiusAlert = UIAlertController(title: "Choisir", message: "", preferredStyle: UIAlertController.Style.alert)
        editRadiusAlert.setValue(vc, forKey: "contentViewController")
        editRadiusAlert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: nil))
        self.present(editRadiusAlert, animated: true)
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.categories[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
}
