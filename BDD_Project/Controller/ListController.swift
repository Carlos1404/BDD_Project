import UIKit
import Firebase

enum PickerViewType {
    case category, sort
}

class ListController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var listTableView: UITableView!
    
    var items = [ItemList]()
    var searchItems = [ItemList]()
    let coreDataManager = CoreDataManager.instance
    var editIndexPath: Int?
    var categories = [Category]()
    var sortList: String?
    
    var sortType = ["Date", "Titre"]
    var pickerViewType = PickerViewType.category
    
    var rootRef: DatabaseReference?
    
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
        rootRef = Database.database().reference()
    }
    
    func reloadData() {
        self.items = coreDataManager.loadChecklistItems()
        tableView.reloadData()
    }
}

extension ListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return items.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListItemCell.identifier) as! ListItemCell
        cell.item = self.items[indexPath.row]
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
        if !searchText.isEmpty{
            self.items = coreDataManager.loadChecklistItems(searchText.lowercased())
            searchItems = items.filter({( item : ItemList) -> Bool in return item.title?.lowercased().contains(searchText.lowercased()) ?? false})
        } else {
            self.items = coreDataManager.loadChecklistItems()
        }
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
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
        self.rootRef?.child("Items").childByAutoId().setValue(item.toDictionary())
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
        self.sortList = self.categories.first?.title
        displayPickerView()
    }
    
    @IBAction func sortButton(_ sender: Any) {
        self.pickerViewType = PickerViewType.sort
        self.sortList = self.sortType.first
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
        editRadiusAlert.addAction(UIAlertAction(title: "Valider", style: .default, handler: { (UIAlertAction) in
            if(self.sortList == "No filter"){
                self.items = CoreDataManager.instance.loadChecklistItems()
            } else {
                if(self.pickerViewType == PickerViewType.category){
                    let list = CoreDataManager.instance.loadChecklistItems().filter({ item -> Bool in
                        item.category == self.sortList
                    })
                    self.items = list
                } else {
                    if self.sortList == "Titre" {
                        let list = self.items.sorted { $0.title! < $1.title! }
                        self.items = list
                    }
                    else if self.sortList == "Date" {
                        let list = self.items.sorted { $0.creationDate?.compare($1.creationDate!) == .orderedDescending }
                        self.items = list
                    }
                }
            }
            self.listTableView.reloadData()
            self.dismiss(animated: true)
        }))
        self.present(editRadiusAlert, animated: true)
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerViewType == PickerViewType.category){
            return self.categories.count + 1
        } else {
            return self.sortType.count + 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerViewType == PickerViewType.category){
            var list = self.categories.filter({ (category: Category) -> Bool in
                category.title != nil
            }).map { (category: Category) -> String in
                return category.title!
            }
            list.append("No filter")
            return list[row]
        } else {
            var list = self.sortType
            list.append("No filter")
            return list[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerViewType {
        case PickerViewType.category:
            var list = self.categories.filter({ (category: Category) -> Bool in
                category.title != nil
            }).map { (category: Category) -> String in
                return category.title!
            }
            list.append("No filter")
            self.sortList = list[row]
        case PickerViewType.sort:
            var list = self.sortType
            list.append("No filter")
            self.sortList = list[row]
        }
    }
    
}

