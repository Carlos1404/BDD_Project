//
//  ListItemCell.swift
//  BDD_Project
//
//  Created by lpiem on 22/02/2019.
//  Copyright © 2019 lpiem. All rights reserved.
//

import UIKit

class ListItemCell: UITableViewCell {
    
    static var identifier = "listItemCell"
    var item: ItemList? {
        didSet {
            //wrapping
            guard let newItem = item else {
                checkItem.isHidden = false
                titleItem.text = ""
                dateItem.text = ""
                return
            }
            checkItem.isHidden = !newItem.checked
            titleItem.text = newItem.title
            dateItem.text = getStringOfDate(date: newItem.creationDate)
        }
    }
    
    override func awakeFromNib() { super.awakeFromNib() }
    
    func getStringOfDate(date: Date?) -> String {
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        
        if let date = date { return formatter.string(from: date) }
        else { return "" }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) { super.setSelected(selected, animated: animated) }
    
    @IBOutlet weak var checkItem: UILabel!
    @IBOutlet weak var titleItem: UILabel!
    @IBOutlet weak var dateItem: UILabel!
}
