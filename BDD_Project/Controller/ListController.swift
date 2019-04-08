import UIKit

enum PickerViewType {
    case category, sort
}

class ListController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var listTableView: UITableView!
    
    var items = [ItemList]()
    var searchItems = [ItemList]()
    var searching = false
    let coreDataManager = CoreDataManager.instance
    var editIndexPath: Int?
    var categories = [Category]()
    
    var sortType = ["Date", "Titre"]
    var pickerViewType = PickerViewType.category
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddItem" {
            let navVC = segue.destination as! UINavigationController
            let destVC = navVC.topViewController as! EditController
            destVC.delegate = self
        }
        else if segue.identifier == "EditItem"{
            let navVC = segue.destination as! UINavigationController
            let destVC = navVC.topViewController as! EditController
            if let indexPath = editIndexPath { destVC.itemToEdit = self.items[indexPath] }
            destVC.delegate = self
        }
        else if segue.identifier == "DetailItem"{
            let destVC = segue.destination as! ListDetailController
            let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
            destVC.itemToEdit = self.items[indexPath.row]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.categories = coreDataManager.loadCategories()
        reloadData()
    }
    
    func reloadData() {
        self.items = coreDataManager.loadChecklistItems()
        tableView.reloadData()
    }
}

extension ListController: UITableViewDelegate, UITableViewDataSource {
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

extension ListController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            self.searching = false
        } else {
            searchItems = items.filter({( item : ItemList) -> Bool in return item.title?.lowercased().contains(searchText.lowercased()) ?? false})
            self.searching = true
        }
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        tableView.reloadData()
    }
}

extension ListController: SecondControllerDelegate {
    func itemDetailViewControllerDidCancel(_ controller: EditController) {
        self.categories = coreDataManager.loadCategories()
        dismiss(animated: true)
    }
    
    func itemDetailViewController(_ controller: EditController, didFinishAddingItemList item: ItemList) {
        reloadData()
        self.categories = coreDataManager.loadCategories()
        dismiss(animated: true)
    }
    
    func itemDetailViewController(_ controller: EditController, didFinishEditingItem item: ItemList) {
        let indexPath = self.items.index(where: { $0 === item})
        items[indexPath!] = item
        self.categories = coreDataManager.loadCategories()
        tableView.reloadRows(at: [IndexPath(item: indexPath!, section: 0)], with: UITableView.RowAnimation.automatic)
        dismiss(animated: true)
    }
}

extension ListController: UIPickerViewDataSource, UIPickerViewDelegate{
    
    @IBAction func categoryButton(_ sender: Any) {
        self.pickerViewType = PickerViewType.category
        displayPickerView()
    }
    
    @IBAction func sortButton(_ sender: Any) {
        self.pickerViewType = PickerViewType.sort
        displayPickerView()
    }
    
    func displayPickerView(){
        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 300)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 300))
        pickerView.delegate = self
        pickerView.dataSource = self
        vc.view.addSubview(pickerView)
        let editRadiusAlert = UIAlertController(title: "Choisir", message: "", preferredStyle: UIAlertController.Style.alert)
        editRadiusAlert.setValue(vc, forKey: "contentViewController")
        editRadiusAlert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: nil))
        editRadiusAlert.addAction(UIAlertAction(title: "Réinitialiser", style: .default, handler: { (UIAlertAction) in
            self.items = CoreDataManager.instance.loadChecklistItems()
            self.listTableView.reloadData()
        }))
        self.present(editRadiusAlert, animated: true)
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerViewType == PickerViewType.category){
            return self.categories.count
        } else {
            return self.sortType.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerViewType == PickerViewType.category){
            return self.categories[row].title
        } else {
            return self.sortType[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerViewType == PickerViewType.category){
            let list = CoreDataManager.instance.loadChecklistItems().filter({ item -> Bool in
                item.category == self.categories[row].title
            })
            self.items = list
        } else {
            if self.sortType[row] == "Titre" {
                let list = self.items.sorted { $0.title! < $1.title! }
                self.items = list
            }
            else if self.sortType[row] == "Date" {
                let list = self.items.sorted { $0.creationDate?.compare($1.creationDate!) == .orderedDescending }
                self.items = list
            }
        }
        self.listTableView.reloadData()
        dismiss(animated: true)
    }
    
}
