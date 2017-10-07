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
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
