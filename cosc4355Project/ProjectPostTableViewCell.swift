//
//  ProjectPostTableViewCell.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/6/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit

class ProjectPostTableViewCell: UITableViewCell {
  
  
  @IBOutlet weak var projectPhoto: UIImageView!

  @IBOutlet weak var userPhoto: UIImageView!
  
  @IBOutlet weak var projectTitle: UILabel!
  
  @IBOutlet weak var projectDescription: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    userPhoto.layer.cornerRadius = 25
    userPhoto.layer.masksToBounds = true
    projectTitle.text = "Test"
    print("is set")
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
