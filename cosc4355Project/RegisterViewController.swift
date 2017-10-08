//
//  RegisterViewController.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 9/21/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
  
  @IBOutlet weak var profilePicture: UIImageView!
  
  @IBOutlet weak var emailText: UITextField!
  
  @IBOutlet weak var passwordText: UITextField!
  
  @IBOutlet weak var confirmPasswordText: UITextField!
  
  /* Handle registration */
  @IBAction func register(_ sender: UIButton) {
    if emailText.text! == "" || passwordText.text! == "" || confirmPasswordText.text! == "" {
      print("Error: Empty field indicated")
      return
    }
    if passwordText.text! != confirmPasswordText.text! {
      print("Error: Passwords does not match")
      return
    }
    
    /* Standard user registration */
    FIRAuth.auth()?.createUser(withEmail: emailText.text!, password: passwordText.text!) { (user, error) in
      if let error = error {
        print("Error creating new user: \(error)")
        return
      }
      print("Created user: \(String(describing: user?.uid))")
      self.emailText.text = ""
      self.passwordText.text = ""
      self.confirmPasswordText.text = ""
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  @IBAction func goBackButton(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    profilePicture.layer.cornerRadius = 64
    profilePicture.layer.masksToBounds = true
    // Do any additional setup after loading the view.
  }
}
