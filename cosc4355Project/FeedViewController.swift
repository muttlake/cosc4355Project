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
  
  /* Generate cells, customization can be done through here. If generic change, make it in the cell's class */
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell", for: indexPath) as! ProjectPostTableViewCell
    
    let project = listings[indexPath.item] as! Posting
    cell.projectPhoto.loadImage(url: project.photoUrl)
    cell.projectTitle.text = listings[indexPath.item].title
    
    cell.projectDescription.text = generateProjectDescription(startingBid: project.startingBid, description: listings[indexPath.item].description)
    
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
    fetchProjects()
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
  
  func handleRefresh() {
    listings.removeAll()
    fetchProjects()
  }
  
  func generateProjectDescription(startingBid: Double, description: String) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    return formatter.string(from: startingBid as NSNumber)! + " • " + description
  }
}
