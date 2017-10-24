//
//  BidsTableViewController.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/10/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit
import Firebase

class BidsTableViewController: UITableViewController {
  
  var listings: [Bid] = []
  
  var biddersInfo: [String: User] = [:]
  
  var currentPosting: Posting?
  
  /* Used to keep reference for enabling/hiding */
  var acceptButtons = [UIButton]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.allowsSelection = false
    fetchBids()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return listings.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "bidCell", for: indexPath) as! BidTableViewCell
    let currentBid = listings[indexPath.row]
    cell.bidderPhoto.loadImage(url: (biddersInfo[currentBid.bidder_id]?.profilePicture)!)
    cell.bidderName.text = biddersInfo[currentBid.bidder_id]?.name
    cell.bidderRating.text = "5 Star"
    cell.bidderBid.text = Double.getFormattedCurrency(num: currentBid.bidAmount)
    cell.acceptButton.tag = indexPath.row
    
    acceptButtons[indexPath.row] = cell.acceptButton
    
    return cell
  }
  
  
  func updateBidAcceptedInDB(bidAmount: String, sender: UIButton) {
    let values = ["acceptedBid": bidAmount] as [String : Any]
    self.registerInfoIntoDatabaseWithUID(uid: (currentPosting?.posting_id)!, values: values as [String: AnyObject], sender: sender)
  }
  
  private func registerInfoIntoDatabaseWithUID(uid: String, values: [String: AnyObject], sender: UIButton) {
    let ref = FIRDatabase.database().reference(fromURL: "https://cosc4355project.firebaseio.com/")
    let reviewsReference = ref.child("projects").child(uid)
    reviewsReference.updateChildValues(values) { (err, ref) in
      if(err != nil) {
        print("Error Occured: \(err!)")
        return
      }
      self.performSegue(withIdentifier: "acceptBidSegue", sender: sender)
    }
  }
  
  @IBAction func acceptBid(_ sender: UIButton) {
    print("Bid accepted \(sender.tag)")
    /** NOTIFY CONTRACTOR */
    updateBidAcceptedInDB(bidAmount: listings[sender.tag].id, sender: sender)
  }
  
  func fetchBidderInfo() {
    for bid in listings {
      FIRDatabase.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
        guard let dictionaries = snapshot.value as? [String: Any] else { return }
        dictionaries.forEach({ (key, value) in
          guard let dictionary = value as? [String: Any] else { return }
          if key == bid.bidder_id {
            let user = User()
            user.profilePicture = dictionary["profilePicture"] as? String
            user.name = (dictionary["name"] as? String)!
            self.biddersInfo[key] = user
          }
        })
        /* Manually all the table view to reload itself and to refresh. Otherwise no changes will be seen */
        self.tableView?.reloadData()
        
        /* Check if there was already a bid accepted after bids are loaded */
        if self.currentPosting?.acceptedBid != "0" {
          var acceptIndex = 0
          for (index, list) in self.listings.enumerated() {
            if list.bidder_id == self.currentPosting?.acceptedBid {
              acceptIndex = index
              break
            }
          }
          let randButton = UIButton()
          randButton.tag = acceptIndex
          self.performSegue(withIdentifier: "acceptBidSegue", sender: randButton)
        }
      })
    }
  }
  
  func handleRefresh() {
    listings.removeAll()
    fetchBids()
  }
  
  /* Fetches data from bids folder according to project id and current user id */
  func fetchBids() {
    FIRDatabase.database().reference().child("bids").observeSingleEvent(of: .value, with: { (snapshot) in
      guard let dictionaries = snapshot.value as? [String: Any] else { return }
      dictionaries.forEach({ (key, value) in
        guard let dictionary = value as? [String: Any] else { return }
        let bid = Bid(from: dictionary, id: key as String)
        if bid.posting_id == self.currentPosting!.posting_id {
          print(bid.posting_id)
          self.listings.append(bid)
          self.acceptButtons.append(UIButton())
        }
      })
      /* Fetch bidders info only after actual bids have been loaded */
      self.fetchBidderInfo()
    }) { (error) in
      print("Failed to fetch bids with error: \(error)")
    }
  }
  
  /* Pass in bid, user, and project info to next page */
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "acceptBidSegue" {
      let dvc = segue.destination as! AcceptedBidViewController
      if let sender = sender as? UIButton {
        dvc.bid = listings[sender.tag]
        dvc.posting = currentPosting!
        dvc.userId = listings[sender.tag].bidder_id
        dvc.user = biddersInfo[listings[sender.tag].bidder_id]
        dvc.cameFromBid = true
        print(dvc.user?.profilePicture)
      }
    }
  }
}
