//
//  ReviewTableViewCell.swift
//  cosc4355Project
//
//  Created by Timothy M Shepard on 10/10/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userPhoto: CustomImageView!
    @IBOutlet weak var reviewStars: UILabel!
    @IBOutlet weak var reviewDescription: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        userPhoto.layer.cornerRadius = 25
        userPhoto.layer.masksToBounds = true
        reviewStars.text = "Review Stars"
        print("is set")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
