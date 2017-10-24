//
//  FeedViewController.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 9/21/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class FeedViewController: UITableViewController, ListingsProtocol {
  
  var listings: [BasicListingsProtocol] = []
  var orderedListings: [BasicListingsProtocol] {
    return listings.sorted(by: { (item1: BasicListingsProtocol, item2: BasicListingsProtocol) -> Bool in
      let firstItem = item1 as! Posting
      let secondItem = item2 as! Posting
      return Date.getDate(from: firstItem.date) > Date.getDate(from: secondItem.date)
    })
  }
  var isContractor = false;
  
  /* Generate cells, customization can be done through here. If generic change, make it in the cell's class */
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell", for: indexPath) as! ProjectPostTableViewCell
    
    let project = orderedListings[indexPath.item] as! Posting
    cell.projectPhoto.loadImage(url: project.photoUrl)
    cell.projectTitle.text = orderedListings[indexPath.item].title
    cell.posting_id = orderedListings[indexPath.item].posting_id
    cell.poster_id = orderedListings[indexPath.item].user_id
    cell.projectDescription.text = generateProjectDescription(startingBid: project.startingBid, description: orderedListings[indexPath.item].description)
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return listings.count
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    handleRefresh()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
    
    /* Adding refresh feature on newsfeed to reload projects */
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    tableView.refreshControl = refreshControl
    
    let name = Notification.Name(rawValue: "updateFeed")
    NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { (_) in
      self.handleRefresh()
    }
    
    /* Gets User Type */
    FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).observeSingleEvent(of: .value, with: { (FIRDataSnapshot) in
      guard let userInfo = FIRDataSnapshot.value as? [String : Any] else { return }
      if (userInfo["userType"] as! String == "Contractor") {
        self.isContractor = true
        self.fetchProjects()
      } else {
        self.fetchUserProjects()
      }
    })
    
  }
  
  /* If the user is a client, only fetch the projects they posted */
  func fetchUserProjects() {
    let rootRef = FIRDatabase.database().reference().child("projects")
    rootRef.observeSingleEvent(of: .value, with: { (FIRDataSnapshot) in
      guard let dictionaries = FIRDataSnapshot.value as? [String: AnyObject] else { return }
      dictionaries.forEach({ (key, value) in
        guard let dictionary = value as? [String: Any] else { return }
        let project = Posting(from: dictionary)
        if project.user_id == FIRAuth.getCurrentUserId() { self.listings.append(project) }
      })
      self.tableView?.reloadData()
      self.tableView?.refreshControl?.endRefreshing()
    }) { (error) in
      print("Failed retrieving user projects with error: \(error)")
    }
  }
  
  /* Fetches all data from projects folder */
  func fetchProjects() {
    FIRDatabase.database().reference().child("projects").observeSingleEvent(of: .value, with: { (snapshot) in
      guard let dictionaries = snapshot.value as? [String: Any] else { return }
      dictionaries.forEach({ (key, value) in
        guard let dictionary = value as? [String: Any] else { return }
        let project = Posting(from: dictionary)
        self.listings.append(project)
      })
      /* Manually all the table view to reload itself and to refresh. Otherwise no changes will be seen */
      self.tableView?.reloadData()
      self.tableView?.refreshControl?.endRefreshing()
    }) { (error) in
      print("Failed to fetch users with error: \(error)")
    }
  }
  
  @objc func handleRefresh() {
    listings.removeAll()
    if isContractor {
      fetchProjects()
    } else {
      fetchUserProjects()
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if isContractor {
      performSegue(withIdentifier: "makeBidSegue", sender: self)
    } else {
      let project = listings[tableView.selectedIndex] as! Posting
      if project.acceptedBid == "0" {
        /* The project still doesn't have an accepted bid */
        performSegue(withIdentifier: "viewBidsSegue", sender: self)
      } else {
        /* Show bid that was accepted */
        performSegue(withIdentifier: "ifBidAcceptedSegue", sender: self)
      }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "makeBidSegue" {
      let dvc = segue.destination as! BidFormViewController
      let currentCell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as! ProjectPostTableViewCell
      dvc.projectTitleString = currentCell.projectTitle.text!
      dvc.projectDescriptionString = currentCell.projectDescription.text!
      dvc.projectImagePhoto = currentCell.projectPhoto.image
      dvc.posterImagePhoto = currentCell.userPhoto.image
      dvc.postingId = currentCell.posting_id
      dvc.userWhoPostedId = currentCell.poster_id
    } else if segue.identifier == "viewBidsSegue" {
      let dvc = segue.destination as! BidsTableViewController
      dvc.currentPosting = orderedListings[tableView.getSelectedIndex()] as? Posting
    }
  }
  
  func generateProjectDescription(startingBid: Double, description: String) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    return formatter.string(from: startingBid as NSNumber)! + " • " + description
  }
}
