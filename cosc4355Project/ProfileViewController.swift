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

    var reviews: [Review] = []
    
//    var fakeReviews: [Review] = [
//        Review(about_id: "Contractor22", posting_id: "253fdfds", stars: 5, reviewWords: "Excellent Work.", reviewTime: Date.currentDate),
//        Review(about_id: "Contractor22", posting_id: "253fdfds", stars: 4, reviewWords: "No complaints.", reviewTime: Date.currentDate),
//        Review(about_id: "Contractor22", posting_id: "253fdfds", stars: 5, reviewWords: "Really Really Good Job.", reviewTime: Date.currentDate)]
//
//    func registerFakeReviewsIntoDatabase() {
//        for review in fakeReviews {
//            let reviewId = NSUUID().uuidString
//            let values = ["user_id": FIRAuth.getCurrentUserId(), "about_id": review.about_id, "posting_id": review.posting_id, "stars": review.stars, "reviewWords": review.reviewWords, "reviewTime": review.reviewTime] as [String : Any]
//            self.registerInfoIntoDatabaseWithUID(uid: reviewId, values: values as [String: AnyObject])
//        }
//    }
//
//    private func registerInfoIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
//        let ref = FIRDatabase.database().reference(fromURL: "https://cosc4355project.firebaseio.com/")
//        let projectsReference = ref.child("reviews").child(uid)
//        projectsReference.updateChildValues(values) { (err, ref) in
//            if(err != nil) {
//                print("Error Occured: \(err!)")
//                return
//            }
//        }
//    }
    
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
    
        reviewsTableView.delegate = self
        reviewsTableView.dataSource = self

        reviewsTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)

        fetchReviews()

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
  
    func fetchUserProfile() {
        FIRDatabase.database().reference().child("users").child(FIRAuth.getCurrentUserId()).observeSingleEvent(of: .value, with: { (FIRDataSnapshot) in
            let userValues = FIRDataSnapshot.value as? [String: AnyObject]
            self.nameLabel.text = userValues?["name"] as? String
            self.profilePicture.loadImage(url: (userValues?["profilePicture"] as? String) ?? "")
            // print(userValues["profilePicture"])
        })
    } // end fetchUserProfile
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewTableViewCell
        reviews.sort(by: { (item1: Review, item2: Review) -> Bool in
                return Date.getDate(from: item1.reviewTime) > Date.getDate(from: item2.reviewTime)
            })
        let starImageName = String(reviews[indexPath.row].stars) + "stars"
        cell.starsImage.image = UIImage(named: starImageName)
        cell.reviewWordsLabel.text = reviews[indexPath.item].reviewWords
        print(reviews[indexPath.item])
    
        return cell
    }
        
    /* Fetches all data from projects folder */
    func fetchReviews() {
        FIRDatabase.database().reference().child("reviews").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                let review = Review(from: dictionary)
                self.reviews.append(review)
            })
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
}


