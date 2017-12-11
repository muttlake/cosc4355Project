//
//  BidTableViewCell.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/10/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit

class BidTableViewCell: UITableViewCell {
  
  @IBOutlet weak var bidderPhoto: CustomImageView!
  
  @IBOutlet weak var bidderName: UILabel!
  
  @IBOutlet weak var bidderRating: UILabel!
  
  @IBOutlet weak var bidderBid: UILabel!
  
  var isAccepted = false
 
  @IBOutlet weak var acceptButton: UIButton!

  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
