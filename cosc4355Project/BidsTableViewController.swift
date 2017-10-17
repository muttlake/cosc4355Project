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
    return cell
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
        self.tableView?.refreshControl?.endRefreshing()
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
        print(dictionary["bidAmount"] as! String)
        let bid = Bid(from: dictionary)
        print(bid.bidAmount)
        if bid.posting_id == self.currentPosting!.posting_id {
          self.listings.append(bid)
        }
      })
      /* Fetch bidders info only after actual bids have been loaded */
      self.fetchBidderInfo()
    }) { (error) in
      print("Failed to fetch bids with error: \(error)")
    }
  }
  
  func fetchUsers() {
    
  }
}
