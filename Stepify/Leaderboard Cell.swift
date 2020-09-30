//
//  Leaderboard Cell.swift
//  Stepify
//
//  Created by JJ Zapata on 9/27/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit

class Leaderboard_Cell: UITableViewCell {
    
    @IBOutlet var profileImage : UIImageView!
    @IBOutlet var titleName : UILabel!
    @IBOutlet var stepCount : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
