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
  
  // Maps User ID to their image url
  var biddersInfo: [String: User] = [:]
  
  var currentPosting: Posting?
  
  var bidsStatus: [Bool]?
  
  var clientSelected = false
  
  var acceptButtons = [UIButton]()
  var payButtons = [UIButton]()
  var reviewButtons = [UIButton]()
  
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
    
    acceptButtons.append(cell.acceptButton)
    payButtons.append(cell.payButton)
    reviewButtons.append(cell.reviewButton)
    
    return cell
  }
  
  @IBAction func acceptBid(_ sender: UIButton) {
    print("Bid accepted")
    /** NOTIFY CONTRACTOR */
    print(sender.tag)
    if !bidsStatus![sender.tag] {
      for button in acceptButtons {
        if button.tag != sender.tag {
          button.isEnabled = false
          button.setTitleColor(UIColor.gray, for: .disabled)
        }
      }
      reviewButtons[sender.tag].isHidden = false
      payButtons[sender.tag].isHidden = false
      bidsStatus![sender.tag] = true
      sender.setTitle("Accepted", for: .normal)
      sender.setTitleColor(UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1), for: .normal)
    
      clientSelected = true
    } else {
      for button in acceptButtons {
        button.isEnabled = true
      }
      payButtons[sender.tag].isHidden = true
      reviewButtons[sender.tag].isHidden = true
      bidsStatus![sender.tag] = false
      sender.setTitle("Accept", for: .normal)
      sender.setTitleColor(UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1), for: .normal)
    }
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
        let bid = Bid(from: dictionary)
        if bid.posting_id == self.currentPosting!.posting_id {
          print(bid.posting_id)
          self.listings.append(bid)
        }
      })
      /* Init bid statuses with proper count */
      self.bidsStatus = Array(repeating: false, count: self.listings.count)
      /* Fetch bidders info only after actual bids have been loaded */
      self.fetchBidderInfo()
    }) { (error) in
      print("Failed to fetch bids with error: \(error)")
    }
  }
}
