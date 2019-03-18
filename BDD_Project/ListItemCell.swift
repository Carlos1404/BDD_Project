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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBOutlet weak var checkItem: UILabel!
    @IBOutlet weak var titleItem: UILabel!
    @IBOutlet weak var dateItem: UILabel!
}
