//
//  PersonTableViewCell.swift
//  Birthday Reminder 2
//
//  Created by Sanjana Pruthi on 1/21/18.
//  Copyright © 2018 Sanjana Pruthi. All rights reserved.
//

import UIKit

class PersonTableViewCell: UITableViewCell {

    //MARK: Properties
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var birthdayLabel: UILabel!
    
    @IBOutlet weak var personImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
