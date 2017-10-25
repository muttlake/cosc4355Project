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
    performSegue(withIdentifier: "reviewSegue", sender: self)
  }
  
  @IBAction func pay(_ sender: UIButton) {
    print("PAY")
    let alertController = UIAlertController(title: "Pay", message: "Enter amount to pay", preferredStyle: .alert)
    let payAction = UIAlertAction(title: "Pay", style: .default) { (_: UIAlertAction) in
      NotificationsUtil.notify(notifier_id: FIRAuth.getCurrentUserId(), notified_id: (self.user?.id)!, posting_id: (self.posting?.posting_id)!, notificationId: NSUUID().uuidString, notificationType: "paymentMade", notifier_name: (self.user?.name)!, notifier_image: (self.user?.profilePicture)!, posting_name: (self.posting?.title)!)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alertController.addTextField(configurationHandler: nil)
    alertController.addActions(actions: payAction, cancelAction)
    present(alertController, animated: true, completion: nil)
  }
  
  func notifyPaid() {
    let notifier_id = FIRAuth.getCurrentUserId()
    let notified_id = user?.id
    let posting_id = posting?.posting_id
    let notificationId = NSUUID().uuidString
    
    let values = ["notifier_id": notifier_id, "notified_id": notified_id, "notificationType": "paymentMade", "posting_id": posting_id, "expectedTime": Date.currentDate]
    self.registerInfoIntoDatabaseWithUID(uid: notificationId, values: values as [String: AnyObject])
    // self.navigationController?.popViewController(animated: true)
  }
  
  private func registerInfoIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
    let ref = FIRDatabase.database().reference(fromURL: "https://cosc4355project.firebaseio.com/")
    let projectsReference = ref.child("Notification").child(uid)
    projectsReference.updateChildValues(values) { (err, ref) in
      if(err != nil) {
        print("Error Occured: \(err!)")
        return
      }
    }
  }
  
  @IBAction func cancel(_ sender: UIButton) {
    print("CANCEL")
    let alertController = UIAlertController(title: "Confirm", message: "Cancel the user's bid?", preferredStyle: .alert)
    let confirmAction = UIAlertAction(title: "Yes", style: .destructive) { (_: UIAlertAction) in
      self.updateBidAcceptedInDB(bidAmount: "0", sender: nil)
       NotificationsUtil.notify(notifier_id: FIRAuth.getCurrentUserId(), notified_id: (self.user?.id)!, posting_id: (self.posting?.posting_id)!, notificationId: NSUUID().uuidString, notificationType: "bidCancelled", notifier_name: (self.user?.name)!, notifier_image: (self.user?.profilePicture)!, posting_name: (self.posting?.title)!)
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
    
    fetchUserInfo()
  }
  
  func fetchUserInfo() {
    FIRDatabase.database().reference().child("users/\(bid?.bidder_id ?? "")").observeSingleEvent(of: .value, with: { (snap) in
      guard let dictionary = snap.value as? [String: Any] else { return }
      self.user = User(from: dictionary, id: (self.bid?.bidder_id)!)
      self.nameLabel.text = (self.user?.name)! + " • " + Double.getFormattedCurrency(num: (self.bid?.bidAmount)!)
      self.userImage.loadImage(url: (self.user?.profilePicture) ?? "")
      self.ratingLabel.text = "5 Star"
      self.contactInfoLabel.text = self.user?.email
    })
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
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "reviewSegue" {
      let dvc = segue.destination as! ReviewFormViewController
      dvc.user = user
      dvc.bid = bid
      dvc.project = posting
    }
  }
}
