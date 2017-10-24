//
//  AcceptedBidViewController.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/23/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit

class AcceptedBidViewController: UIViewController {
  
  var userId: String = ""
  var user: User? = nil
  var bid: Bid? = nil
  var posting: Posting? = nil
  
  @IBOutlet weak var nameLabel: UILabel!
  
  @IBOutlet weak var userImage: CustomImageView!
  
  @IBOutlet weak var ratingLabel: UILabel!
  
  @IBOutlet weak var contactInfoLabel: UILabel!
  
  @IBAction func review(_ sender: UIButton) {
    print("REVIEW")
  }
  
  @IBAction func pay(_ sender: UIButton) {
    print("PAY")
  }
  
  @IBAction func cancel(_ sender: UIButton) {
    print("CANCEL")
    self.navigationController?.popViewController(animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.setHidesBackButton(true, animated: false)
    self.navigationItem.title = posting?.title
    
    userImage.layer.masksToBounds = true
    userImage.layer.cornerRadius = 95
    nameLabel.text = user?.name
    userImage.loadImage(url: (user?.profilePicture)!)
    ratingLabel.text = "5 Star"
    contactInfoLabel.text = "PlaceHolder"
    // Do any additional setup after loading the view.
  }
}
