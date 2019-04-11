//
//  CoreDataManager.swift
//  BDD_Project
//
//  Created by lpiem on 18/03/2019.
//  Copyright © 2019 lpiem. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Firebase

class CoreDataManager {
    
    static var instance = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataBase")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? { fatalError("Unresolved error \(error), \(error.userInfo)") }
        })
        return container
    }()
    
    var viewContext: NSManagedObjectContext { return persistentContainer.viewContext }
    
    //get items' list
    func loadChecklistItems(_ query: String? = nil) -> [ItemList] {
        let request: NSFetchRequest<ItemList> = NSFetchRequest<ItemList>(entityName: "ItemList")
        if let query = query {
            request.predicate = NSPredicate(format: "title contains[cd]", query)
        }
        var result = [ItemList]()
        do {
            let itemsList = try viewContext.fetch(request)
            result = itemsList as [ItemList]
        } catch let error as NSError { print("Could not fetch :  \(error)") }
        return result
    }
    
    func loadCategories() -> [Category]{
        let request: NSFetchRequest<Category> = NSFetchRequest<Category>(entityName: "Category")
        var result = [Category]()
        do {
            let categories = try viewContext.fetch(request)
            result = categories as [Category]
        } catch let error as NSError {
            print("Could not fetch :  \(error)")
        }
        return result
    }
    
    //get item's details
    func loadChecklistItem() -> Int { return 0 }
    
    //save item
    func saveData () {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //add an item
    func addItem(title: String, descriptions: String = "", category: String, image: Data?) -> ItemList {
        let item = ItemList(context: viewContext)
        item.title = title
        item.descriptions = descriptions
        item.creationDate = Date()
        item.modificationDate = Date()
        item.category = category
        item.image = image
        item.checked = false
        saveData()
        return item
    }
    
    //delete an item
    func deleteItem(item: NSManagedObject) {
        viewContext.delete(item)
        saveData()
    }
}
