//
//  ProfileViewController.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/6/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
  
  @IBOutlet weak var profilePicture: CustomImageView!
  
  @IBOutlet weak var nameLabel: UILabel!
  
  @IBOutlet weak var emailLabel: UILabel!
  
  @IBAction func logoutButton(_ sender: UIButton) {
    do {
      try FIRAuth.auth()?.signOut()
      performSegue(withIdentifier: "logoutSegue", sender: self)
    } catch let error {
      print("Sign out failed: \(error)")
      return
    }
    print("Sign out successful")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    /* Turns picture into a circle */
    profilePicture.layer.cornerRadius = 64
    profilePicture.layer.masksToBounds = true
    emailLabel.text = FIRAuth.auth()?.currentUser?.email!
    fetchUserProfile()
  }
  
  func fetchUserProfile() {
    FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).observeSingleEvent(of: .value, with: { (FIRDataSnapshot) in
      let userValues = FIRDataSnapshot.value as! [String: AnyObject]
      self.nameLabel.text = userValues["name"] as? String
      self.profilePicture.loadImage(url: (userValues["profilePicture"] as! String))
      // print(userValues["profilePicture"])
    })
  }
}
