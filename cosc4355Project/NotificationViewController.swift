//
//  BidsTableViewController.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/10/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit
import Firebase

class NotificationViewController: UITableViewController,clearDelegate {
    var notificationKeys: [String] = []
    var listings: [Bid] = []
    var bidIds: [String] = []
   
    var biddersInfo: [String: User] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        fetchBids()
        
    }
       override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return listings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print(listings.count)
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationTableViewCell
        let currentBid = listings[indexPath.row]
        cell.name.text =  biddersInfo[currentBid.bidder_id]?.name
        cell.message.text = "made a bid of "
        cell.amount.text =   String(currentBid.bidAmount)
        cell.row = indexPath.row
        cell.delegate = self
        return cell
    }
    func removeNotification(row: Int) {
         FIRDatabase.database().reference().child("Notification").child(self.notificationKeys[row]).setValue(nil)
        fetchBids()
        self.tableView?.reloadData()
    }
    func fetchBidderInfo() {
        for bid in listings {
            FIRDatabase.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionaries = snapshot.value as? [String: Any] else { return }
                dictionaries.forEach({ (key, value) in
                    guard let dictionary = value as? [String: Any] else { return }
                    if key == bid.bidder_id {
                        let user = User()
                    
                        user.name = (dictionary["name"] as? String)!
                        self.biddersInfo[key] = user
                    }
                })
                /* Manually all the table view to reload itself and to refresh. Otherwise no changes will be seen */
                self.tableView?.reloadData()
            })
        }
    }
    
    func fetchBids(){
       
        self.biddersInfo.removeAll()
        self.listings.removeAll()
        self.notificationKeys.removeAll()
        FIRDatabase.database().reference().child("Notification").observeSingleEvent(of: .value, with: { (FIRDataSnapshot) in
            guard let dictionaries = FIRDataSnapshot.value as? [String: Any] else { return }
            dictionaries.forEach({ (key, value) in
                
                guard let dictionary = value as? [String: Any] else { return }
                let bid = Bid(from: dictionary)
                if bid.user_id == (FIRAuth.auth()?.currentUser?.uid)!{
                    self.notificationKeys.append(key)
                    self.listings.append(bid)
                    print("user id matches")
                }
            })
            /* Manually all the table view to reload itself and to refresh. Otherwise no changes will be seen */
         
            /* Fetch bidders info only after actual bids have been loaded */
            self.fetchBidderInfo()
            
        }) { (error) in
            print("Failed to fetch bids with error: \(error)")
        }
      
    }

}
