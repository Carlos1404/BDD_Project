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

class CoreDataManager {
    
    //get items' list
    func loadChecklistItems() -> [ItemList] {
        let request: NSFetchRequest<ItemList> = NSFetchRequest<ItemList>(entityName: "ItemList")
        var result = [ItemList]()
        do {
            let itemsList = try AppDelegate.viewContext.fetch(request)
            result = itemsList as [ItemList]
        } catch let error as NSError {
            print("Could not fetch :  \(error)")
        }
        return result
    }
    
    //set items' list
    func saveChecklistItemsCDM(items: [ItemList]) {
        
    }
    
    //get item's details
    func loadChecklistItem() -> Int {
        
        return 0
    }
    
    //save item
    func saveChecklistItem() {
        try? AppDelegate.viewContext.save()
    }
    
    //update an item
    func updateItem(item: ItemList) {
        
    }
    
    //delete an item
    func deleteItem(item: ItemList) {
        
    }
}
