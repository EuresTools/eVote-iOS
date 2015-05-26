//
//  PollOptionTableViewCell.swift
//  eVote
//
//  Created by Björn Orri Saemundsson on 5/21/15.
//  Copyright (c) 2015 Eurescom. All rights reserved.
//

import UIKit
import M13Checkbox

class PollOptionTableViewCell: UITableViewCell {

    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var checkBox: M13Checkbox!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
