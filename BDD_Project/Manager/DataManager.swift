//
//  DataManager.swift
//  BDD_Project
//
//  Created by lpiem on 22/02/2019.
//  Copyright © 2019 lpiem. All rights reserved.
//

import Foundation

class DataManager {
    
    /*
    static var documentDirectory: URL { return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! }
    static var dataFileUrl: URL { return DataManager.documentDirectory.appendingPathComponent("List").appendingPathExtension("json") }
    
    func saveChecklistItems(list: [ItemList]){
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(list)
            try data.write(to: DataManager.dataFileUrl, options: [])
        }
        catch {print(error)}
    }
    
    func loadChecklistItems() -> [ItemList] {
        do {
            let data = try Data(contentsOf: DataManager.dataFileUrl)
            let decoder = JSONDecoder()
            let list = try decoder.decode([ItemList].self, from: data)
            return list
        }
        catch {
            print(error)
            return []
        }

    }
 */
}
