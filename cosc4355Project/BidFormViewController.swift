//
//  BidFormViewController.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/10/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit

class BidFormViewController: UIViewController {

  @IBOutlet weak var posterImage: UIImageView!
  
  @IBOutlet weak var projectTitle: UILabel!
  
  @IBOutlet weak var projectImage: UIImageView!
  
  @IBOutlet weak var projectDescription: UILabel!
  
  @IBOutlet weak var bidAmountField: UITextField!
  
  var projectTitleString: String?
  
  var projectDescriptionString: String?
  
  var projectImagePhoto: UIImage?
  
  var posterImagePhoto: UIImage?
  
  var postingId: String?
  
  var userWhoPostedId: String?
  
  @IBAction func makeBid(_ sender: UIButton) {
    /* Upload Bid */
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    posterImage.layer.masksToBounds = true
    posterImage.layer.cornerRadius = 27
    projectTitle.text = projectTitleString ?? "DEFAULT TITLE"
    projectDescription.text = projectDescriptionString ?? "DEFAULT DESC"
    projectImage.image = projectImagePhoto!
    posterImage.image = posterImagePhoto!
    // print(postingId ?? "empty1")
    // print(userWhoPostedId ?? "empty2")
  }
}
