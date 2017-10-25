//
//  BidsTableViewController.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/10/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit
import Firebase

class NotificationViewController: UITableViewController {
  var listings: [Notifications] = []
  var orderedListings: [Notifications] {
    return listings.sorted(by: { (item1: Notifications, item2: Notifications) -> Bool in
      return Date.getDate(from: item1.expectedTime) > Date.getDate(from: item2.expectedTime)
    })
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.allowsSelection = false
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    self.listings = []
    self.fetchNotifications()
  }
  
  /* Fetches data from bids folder according to project id and current user id */
  func fetchNotifications() {
    let rootRef = FIRDatabase.database().reference().child("Notification")
    rootRef.observeSingleEvent(of: .value, with: { (FIRDataSnapshot) in
      guard let dictionaries = FIRDataSnapshot.value as? [String: AnyObject] else { return }
      dictionaries.forEach({ (key, value) in
        guard let dictionary = value as? [String: Any] else { return }
        let notification = Notifications(from: dictionary, id: key )
        if notification.notified_id == FIRAuth.getCurrentUserId() {
          self.listings.append(notification)
        }
      })
      self.tableView?.reloadData()
//      self.tableView?.refreshControl?.endRefreshing()
    }) { (error) in
      print("Failed retrieving user notifications with error: \(error)")
    }
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return listings.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    print(listings.count)
    let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationTableViewCell
    let currentNotification = orderedListings[indexPath.row]
    
    var displayString = ""
    switch currentNotification.notificationType {
    case .bidOffered:
      displayString = "You have a recieved an offer on project: \(currentNotification.project_name)"
    case .bidAccepted:
      displayString = "Your offer on project: \(currentNotification.project_name) was accepted"
    case .bidCancelled:
      displayString = "Your offer has been cancelled on project: \(currentNotification.project_name)"
    case .reviewMade:
      displayString = "A review has been of you"
    case .paymentMade:
      displayString = "You have recieved payment for project: \(currentNotification.project_name)"
    default:
      displayString = "Err: Default Notification"
    }
    
    cell.name.text = displayString
    cell.row = indexPath.row
    return cell
  }
  
//  func removeNotification(row: Int) {
//    // FIRDatabase.database().reference().child("Notification").child(self.notificationKeys[row]).setValue(nil)
//    fetchNotifications()
//    self.tableView?.reloadData()
//  }
  
}
