//
//  ProfileViewController.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/6/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var profilePicture: CustomImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var reviewsTableView: UITableView!

    var fakeReviews: [Review] = [Review(stars: 3.5, about_id: "Contractor22", posting_id: "253fdfds", poster_id: "Test22", reviewWords: "It was well done."), Review(stars: 4.0, about_id: "Contractor22", posting_id: "253fdfds", poster_id: "Test22", reviewWords: "It was well done."), Review(stars: 4.5, about_id: "Contractor22", posting_id: "253fdfds",
        poster_id: "Test22", reviewWords: "It was well done.")]

    @IBAction func logoutButton(_ sender: UIButton) {
        do {
            try FIRAuth.auth()?.signOut()
            performSegue(withIdentifier: "logoutSegue", sender: self)
        } catch let error {
            print("Sign out failed: \(error)")
            return
        }
        print("Sign out successful")
    }
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        /* Turns picture into a circle */
        profilePicture.layer.cornerRadius = 64
        profilePicture.layer.masksToBounds = true
        emailLabel.text = FIRAuth.auth()?.currentUser?.email!
        fetchUserProfile()
    
        reviewsTableView.delegate = self
        reviewsTableView.dataSource = self
    
        reviewsTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
    
        /* Adding refresh feature on newsfeed to reload projects */
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        reviewsTableView.refreshControl = refreshControl
    
        let name = Notification.Name(rawValue: "updateFeed")
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { (_) in
            self.handleRefresh()
            self.fetchProjects()
        }
    }
  
    func fetchUserProfile() {
        FIRDatabase.database().reference().child("users").child(FIRAuth.getCurrentUserId()).observeSingleEvent(of: .value, with: { (FIRDataSnapshot) in
            let userValues = FIRDataSnapshot.value as? [String: AnyObject]
            self.nameLabel.text = userValues?["name"] as? String
            self.profilePicture.loadImage(url: (userValues?["profilePicture"] as? String) ?? "")
            // print(userValues["profilePicture"])
        })
    } // end fetchUserProfile
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fakeReviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewTableViewCell
        fakeReviews.sort(by: { (item1: Review, item2: Review) -> Bool in
                return Date.getDate(from: item1.date) > Date.getDate(from: item2.date)
            })
        cell.starsLabel.text = String(fakeReviews[indexPath.item].stars)
        cell.reviewWordsLabel.text = fakeReviews[indexPath.item].description
        print(fakeReviews[indexPath.item])
    
        return cell
    }
        
    /* Fetches all data from projects folder */
    func fetchProjects() {
//        FIRDatabase.database().reference().child("projects").observeSingleEvent(of: .value, with: { (snapshot) in
//            guard let dictionaries = snapshot.value as? [String: Any] else { return }
//            dictionaries.forEach({ (key, value) in
//                guard let dictionary = value as? [String: Any] else { return }
//                let project = Posting(from: dictionary)
//                self.listings.append(project)
//            })
//            /* Manually all the table view to reload itself and to refresh. Otherwise no changes will be seen */
//            self.reviewsTableView?.reloadData()
//            self.reviewsTableView?.refreshControl?.endRefreshing()
//        }) { (error) in
//            print("Failed to fetch users with error: \(error)")
//        }
        self.reviewsTableView.reloadData()
        self.reviewsTableView.refreshControl?.endRefreshing()
    } // end fetchProjects
        
    func handleRefresh() {
        fakeReviews.removeAll()
        fetchProjects()
    }
}


