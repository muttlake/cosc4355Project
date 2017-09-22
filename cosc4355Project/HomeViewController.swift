//
//  ViewController.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 9/21/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

  @IBOutlet weak var usernameText: UITextField!
  
  @IBOutlet weak var passwordText: UITextField!
  
  @IBAction func login(_ sender: UIButton) {
    /* Handle Login */
    FIRAuth.auth()?.signIn(withEmail: usernameText.text!, password: passwordText.text!) { [unowned self] (user, error) in
      if let error = error {
        print("Login Failure: \(error)")
        return
      }
      print("Successful login with user: \((user?.uid)!)")
      self.performSegue(withIdentifier: "loginSegue", sender: self)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

