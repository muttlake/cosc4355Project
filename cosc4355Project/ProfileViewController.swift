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
  
  
  @IBOutlet weak var profilePicture: UIImageView!
  
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
  
    // Do any additional setup after loading the view.
  }
}
