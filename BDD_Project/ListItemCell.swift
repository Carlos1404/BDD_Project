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
                labelItem.text = ""
                return
            }
            checkItem.isHidden = !newItem.checked
            labelItem.text = newItem.title
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBOutlet weak var checkItem: UILabel!
    @IBOutlet weak var labelItem: UILabel!
}
