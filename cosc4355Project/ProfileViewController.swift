//
//  ProfileViewController.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/6/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var profilePicture: CustomImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var reviewsTableView: UITableView!

    var reviews: [Review] = []
    
    var reviewersPhotos: [String: String] = [:]
    
    @IBAction func addReviewButton(_ sender: Any) {
        performSegue(withIdentifier: "profileReviewForm", sender: self)
    }
    
    
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
        
        //self.registerFakeReviewsIntoDatabase()
        fetchReviews()
        
        reviewsTableView.delegate = self
        reviewsTableView.dataSource = self

        reviewsTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        reviewsTableView.rowHeight = 100
        
        /* Adding refresh feature on newsfeed to reload projects */
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        reviewsTableView.refreshControl = refreshControl

        let name = Notification.Name(rawValue: "updateFeed")
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { (_) in
            self.handleRefresh()
            self.fetchReviews()
        }
    }
    
    func fetchReviewersPhotos() {
        for review in reviews {
            FIRDatabase.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionaries = snapshot.value as? [String: Any] else { return }
                dictionaries.forEach({ (key, value) in
                    guard let dictionary = value as? [String: Any] else { return }
                    if key == review.user_id {
                        let user = User()
                        user.profilePicture = dictionary["profilePicture"] as? String
                        user.name = (dictionary["name"] as? String)!
                        self.reviewersPhotos[key] = user.profilePicture
                    }
                })
                /* Manually all the table view to reload itself and to refresh. Otherwise no changes will be seen */
                self.reviewsTableView.reloadData()
            })
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
        var rowCount = 0
        if reviewersPhotos.count > 0 {
            rowCount = reviews.count
        }
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewTableViewCell
        reviews.sort(by: { (item1: Review, item2: Review) -> Bool in
                return Date.getDate(from: item1.reviewTime) > Date.getDate(from: item2.reviewTime)
            })

        let currentReview = reviews[indexPath.row]
        let starImageName = String(reviews[indexPath.row].stars) + "stars"
        cell.starsImage.image = UIImage(named: starImageName)
        cell.reviewWordsLabel.text = reviews[indexPath.item].reviewWords
        cell.reviewerPhoto.loadImage(url: reviewersPhotos[currentReview.user_id] ?? "")
        
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: cell.frame.size.height - width, width:  cell.frame.size.width, height: cell.frame.size.height)
        
        border.borderWidth = width
        cell.layer.addSublayer(border)
        cell.layer.masksToBounds = true
        
        
        return cell
    }
        
    /* Fetches all data from projects folder */
    func fetchReviews() {
        FIRDatabase.database().reference().child("reviews").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                let review = Review(from: dictionary)
                if review.user_id == FIRAuth.getCurrentUserId() {
                    self.reviews.append(review)
                }
            })
            self.fetchReviewersPhotos()
            /* Manually all the table view to reload itself and to refresh. Otherwise no changes will be seen */
            self.reviewsTableView?.reloadData()
            self.reviewsTableView?.refreshControl?.endRefreshing()
        }) { (error) in
            print("Failed to fetch reviews with error: \(error)")
        }
        self.reviewsTableView.reloadData()
        self.reviewsTableView.refreshControl?.endRefreshing()
    } // end fetchReviews
        
    func handleRefresh() {
        reviews.removeAll()
        fetchReviews()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "reviewDetailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "reviewDetailSegue" {
            let dvc = segue.destination as! ReviewViewController
            dvc.stars = reviews[reviewsTableView.selectedIndex].stars
            dvc.reviewWords = reviews[reviewsTableView.selectedIndex].reviewWords
            let currentReview = reviews[reviewsTableView.selectedIndex]
            dvc.reviewerPhotoString = reviewersPhotos[currentReview.user_id]!
        }
    }
    
}

extension UITableView {
    var selectedIndex: Int {
        return indexPathForSelectedRow?.item ?? 0
    }
}


