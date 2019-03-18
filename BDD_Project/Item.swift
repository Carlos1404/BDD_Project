//
//  Item.swift
//  BDD_Project
//
//  Created by lpiem on 22/02/2019.
//  Copyright © 2019 lpiem. All rights reserved.
//

import Foundation
import UIKit

class Item: Codable {
    
    var title: String
    var description: String?
    var creationDate: Date?
    var modificationDate: Date?
    var image: URL?
    var checked: Bool
    
    init(title: String, description: String?, creationDate: Date?, modificationDate: Date?, image: URL?, checked: Bool = false) {
        self.title = title
        self.description = description
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.image = image
        self.checked = checked
    }
    
    func checkItem(){
        self.checked = !self.checked
    }
}
