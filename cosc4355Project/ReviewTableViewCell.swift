//
//  ReviewTableViewCell.swift
//  cosc4355Project
//
//  Created by Timothy M Shepard on 10/10/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {
    
    //@IBOutlet weak var userPhoto: CustomImageView!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var reviewWordsLabel: UILabel!
    
    var posting_id: String?
    var user_id: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        posting_id = "DEFAULT"
        user_id = "DEFAULT"
        //userPhoto.layer.cornerRadius = 25
        //userPhoto.layer.masksToBounds = true
        starsLabel.text = "Review Stars"
        reviewWordsLabel.text = "Review Words"
        print("is set")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
