//
//  ListDetailController.swift
//  BDD_Project
//
//  Created by lpiem on 08/04/2019.
//  Copyright © 2019 lpiem. All rights reserved.
//

import Foundation
import UIKit

class ListDetailController: UIViewController {
    
    var itemToEdit: ItemList?
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        self.title = itemToEdit?.title
        self.category.text = itemToEdit?.category ?? "No category"
        self.date.text = getStringOfDate(date: itemToEdit?.creationDate)
        if let image = itemToEdit?.image {
            self.image.image = UIImage(data: image)
        }
        self.descriptionText.text = itemToEdit?.descriptions
    }
    
    func getStringOfDate(date: Date?) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        
        if let date = date { return formatter.string(from: date) }
        else { return "" }
    }

}
