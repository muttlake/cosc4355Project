//
//  BidFormViewController.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/10/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit
import Firebase

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
    guard let bidAmount = bidAmountField.text, let user_id = userWhoPostedId, let posting_id = postingId else { return }
    
    let bidId = NSUUID().uuidString
    let values = ["bidAmount": bidAmount, "expectedTime": Date.currentDate, "user_id": user_id, "bidder_id": FIRAuth.getCurrentUserId(), "posting_id": posting_id, "id": bidId]
    self.registerInfoIntoDatabaseWithUID(uid: bidId, values: values as [String: AnyObject])
    
    NotificationsUtil.notify(notifier_id: FIRAuth.getCurrentUserId(), notified_id: user_id, posting_id: posting_id, notificationId: NSUUID().uuidString, notificationType: "bidOffered", notifier_name: "", notifier_image: "", posting_name: projectTitleString!)
    
    self.navigationController?.popViewController(animated: true)
  }
  
  private func registerInfoIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
    let ref = FIRDatabase.database().reference(fromURL: "https://cosc4355project.firebaseio.com/")
    let projectsReference = ref.child("bids").child(uid)
    projectsReference.updateChildValues(values) { (err, ref) in
      if(err != nil) {
        print("Error Occured: \(err!)")
        return
      }
    }
    
    let notificationId = NSUUID().uuidString;
    let notificationRef = ref.child("Notification").child(notificationId)
    notificationRef.updateChildValues(values) { (err, ref) in
      if(err != nil) {
        print("Error Occured: \(err!)")
        return
      }
    }
  }
    
    func makeTapGestureForProfileSegue(userPhoto: UIImageView) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action :#selector(userImageTapped(tapGestureRecognizer:)))
        userPhoto.isUserInteractionEnabled = true
        userPhoto.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func userImageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        performSegue(withIdentifier: "bidFormProfile", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bidFormProfile" {
            let dvc = segue.destination as! ProfileViewController
            dvc.didSegueHere = true
            dvc.currentUserId = userWhoPostedId!
        }
    }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    posterImage.layer.masksToBounds = true
    posterImage.layer.cornerRadius = 27
    projectTitle.text = projectTitleString ?? "DEFAULT TITLE"
    projectDescription.text = projectDescriptionString ?? "DEFAULT DESC"
    projectImage.image = projectImagePhoto!
    posterImage.image = posterImagePhoto!
    
    makeTapGestureForProfileSegue(userPhoto: posterImage)
    // print(postingId ?? "empty1")
    // print(userWhoPostedId ?? "empty2")
  }
    

}
