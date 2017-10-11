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
    let values = ["bidAmount": bidAmount, "expectedTime": Date.currentDate, "user_id": user_id, "bidder_id": FIRAuth.getCurrentUserId(), "posting_id": posting_id]
    self.registerInfoIntoDatabaseWithUID(uid: bidId, values: values as [String: AnyObject])
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
