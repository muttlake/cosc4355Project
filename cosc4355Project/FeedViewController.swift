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
  
  var bidToPass: Bid?
  
  // Map user-id to user object - Mainly used for images
  var users: [String: User] = [:]
  
  var listings: [BasicListingsProtocol] = []
  var orderedListings: [BasicListingsProtocol] {
    return listings.sorted(by: { (item1: BasicListingsProtocol, item2: BasicListingsProtocol) -> Bool in
      let firstItem = item1 as! Posting
      let secondItem = item2 as! Posting
      return Date.getDate(from: firstItem.date) > Date.getDate(from: secondItem.date)
    })
  }
  var isContractor = false;
  
  /* To minimize loading times on start up, increase when user scrolls down far enough */
  // var maxItems = 10
  
  /* Generate cells, customization can be done through here. If generic change, make it in the cell's class */
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell", for: indexPath) as! ProjectPostTableViewCell
    
    /* Bounds checker */
    if (indexPath.item >= orderedListings.count) { return cell }
    
    let project = orderedListings[indexPath.item] as! Posting
    cell.projectPhoto.loadImage(url: project.photoUrl)
    cell.projectTitle.text = orderedListings[indexPath.item].title
    cell.posting_id = orderedListings[indexPath.item].posting_id
    cell.poster_id = orderedListings[indexPath.item].user_id
    cell.projectDescription.text = generateProjectDescription(startingBid: project.startingBid, description: orderedListings[indexPath.item].description)
    cell.userPhoto.loadImage(url: (users[orderedListings[indexPath.item].user_id]?.profilePicture) ?? "")
    
    cell.userPhoto.loadImage(url: "https://firebasestorage.googleapis.com/v0/b/cosc4355project.appspot.com/o/profilePics%2F4tF0epAPgoeFkT4EbbT3Iy1hVTm1.jpg?alt=media&token=8ff2e05f-0aff-4945-8f4f-ccf321a66c0c")

    return cell
  }
    

  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return listings.count
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
      }
      self.handleRefresh()
    })
  }
  
  /* No longer have to manually refresh */
  override func viewDidAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    handleRefresh()
  }
  
  func fetchUsers() {
    let rootRef = FIRDatabase.database().reference().child("users")
    rootRef.observeSingleEvent(of: .value, with: { (FIRDataSnapshot) in
      guard let dictionaries = FIRDataSnapshot.value as? [String: AnyObject] else { return }
      dictionaries.forEach({ (key, value) in
        guard let dictionary = value as? [String: Any] else { return }
        let user = User(from: dictionary, id: key)
        self.users[key] = user
      })
      if self.isContractor {
        self.fetchProjects()
      } else {
        self.fetchUserProjects()
      }
    }) { (error) in
      print("Failed retrieving user projects with error: \(error)")
    }
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
  
  var projectLimit = 10
  
  /* Fetches all data from projects folder */
  func fetchProjects() {
    FIRDatabase.database().reference().child("projects").queryOrdered(byChild: "date").queryLimited(toLast: UInt(projectLimit)).observeSingleEvent(of: .value, with: { (snapshot) in
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
    users.removeAll()
    fetchUsers()
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if isContractor {
      performSegue(withIdentifier: "makeBidSegue", sender: self)
    } else {
      if (tableView.selectedIndex == orderedListings.count) { return }
      let project = orderedListings[tableView.selectedIndex] as? Posting ?? Posting()
      if project.acceptedBid == "0" {
        /* The project still doesn't have an accepted bid */
        performSegue(withIdentifier: "viewBidsSegue", sender: self)
      } else {
        FIRDatabase.database().reference().child("bids/\(project.acceptedBid)").observeSingleEvent(of: .value, with: { (snap) in
          guard let dictionary = snap.value as? [String: Any] else { return }
          print(dictionary)
          self.bidToPass = Bid(from: dictionary, id: project.acceptedBid)
          self.performSegue(withIdentifier: "acceptedBidSegue", sender: self)
        }) { (error) in
          print("Failed to fetch users with error: \(error)")
        }
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
    } else if segue.identifier == "acceptedBidSegue" {
      let dvc = segue.destination as! AcceptedBidViewController
      dvc.bid = bidToPass!
      dvc.posting = orderedListings[tableView.getSelectedIndex()] as? Posting
    }
  }
  
  func generateProjectDescription(startingBid: Double, description: String) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    return formatter.string(from: startingBid as NSNumber)! + " • " + description
  }
}
