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
  
  var currentPosting: Posting?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    fetchBids()
    
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return listings.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "bidCell", for: indexPath) as! BidTableViewCell
    let currentBid = listings[indexPath.row]
    cell.bidderName.text = currentBid.user_id
    cell.bidderRating.text = "5 Star"
    cell.bidderBid.text = String(currentBid.bidAmount)
    return cell
  }
  
  func fetchBidderInfo() {
  
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
          self.listings.append(bid)
        }
      })
      /* Manually all the table view to reload itself and to refresh. Otherwise no changes will be seen */
      self.tableView?.reloadData()
      self.tableView?.refreshControl?.endRefreshing()
    }) { (error) in
      print("Failed to fetch bids with error: \(error)")
    }
  }
}
