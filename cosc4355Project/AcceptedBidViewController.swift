//
//  AcceptedBidViewController.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/23/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit
import Firebase

class AcceptedBidViewController: UIViewController {
  
  var userId: String = ""
  var user: User? = nil
  var bid: Bid? = nil
  var posting: Posting? = nil
  var cameFromBid = false
  
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
    let alertController = UIAlertController(title: "Confirm", message: "Cancel the user's bid?", preferredStyle: .alert)
    let confirmAction = UIAlertAction(title: "Yes", style: .destructive) { (_: UIAlertAction) in
      self.updateBidAcceptedInDB(bidAmount: "0", sender: nil)
      self.navigationController?.popViewController(animated: true)
    }
    let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
    alertController.addActions(actions: confirmAction, cancel)
    present(alertController, animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBar.topItem?.title = "Projects"
    self.navigationItem.title = posting?.title
    
    userImage.layer.masksToBounds = true
    userImage.layer.cornerRadius = 95
    nameLabel.text = user?.name
    userImage.loadImage(url: (user?.profilePicture)!)
    ratingLabel.text = "5 Star"
    contactInfoLabel.text = "PlaceHolder"
    // Do any additional setup after loading the view.
  }
  
  func updateBidAcceptedInDB(bidAmount: String, sender: UIButton?) {
    let values = ["acceptedBid": bidAmount] as [String : Any]
    self.registerInfoIntoDatabaseWithUID(uid: (posting?.posting_id)!, values: values as [String: AnyObject], sender: sender)
  }
  
  private func registerInfoIntoDatabaseWithUID(uid: String, values: [String: AnyObject], sender: UIButton?) {
    let ref = FIRDatabase.database().reference(fromURL: "https://cosc4355project.firebaseio.com/")
    let bidsReference = ref.child("projects").child(uid)
    bidsReference.updateChildValues(values) { (err, ref) in
      if(err != nil) {
        print("Error Occured: \(err!)")
        return
      }
    }
  }
  
  override func willMove(toParentViewController parent:UIViewController?) {
    super.willMove(toParentViewController: parent)
    if (parent == nil && cameFromBid) {
      if let navigationController = self.navigationController {
        var viewControllers = navigationController.viewControllers
        let viewControllersCount = viewControllers.count
        if (viewControllersCount > 2) {
          viewControllers.remove(at: viewControllersCount - 2)
          navigationController.setViewControllers(viewControllers, animated:false)
        }
      }
      cameFromBid = false
    }
  }
}