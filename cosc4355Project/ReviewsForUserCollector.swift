//
//  CalculateUserRating.swift
//  cosc4355Project
//
//  Created by Timothy M Shepard on 11/9/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import Foundation
import Firebase


//takes in user_id into constructor, has function to return average user rating

class ReviewsForUserCollector {
    
    var user_id: String
    var reviewsForUser: [Review]
    var averageRating: Double
    var hasReviews: Bool
   
    
    init(user_id: String) {
        self.user_id = user_id
        self.reviewsForUser = []
        self.averageRating = 0.0
        self.hasReviews = false
    }
    

    func calculateUserRating(completion: @escaping (Bool) -> ()) {
        //print("Trying to calculate star rating for: ", user_id)
        
        self.getAllReviewsForUser(user_id: self.user_id, completion: { success in
            if success {
                var total_star_rating: Double = 0.0
                
                for review in self.reviewsForUser {
                    total_star_rating += Double(review.stars)
                }
                
                if self.reviewsForUser.count > 0 {
                    self.hasReviews = true
                    self.averageRating = total_star_rating/Double(self.reviewsForUser.count)
                }

                completion(true)
            }
            else {
                print("Did not get a rating, error loading reviews.")
            }
        })
    }
    
    
    
    func getAllReviewsForUser(user_id: String, completion: @escaping (Bool) -> ()) {
        FIRDatabase.database().reference().child("reviews").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                let review = Review(from: dictionary)
                //print("Review about_id: ", review.about_id)
                if review.about_id == user_id {
                    //print("Should be appending.")
                    self.reviewsForUser.append(review)
                }
                //print("Number of reviews in here is : ", self.reviewsForUser.count)
            })
            completion(true)
            //print("Number of reviews middle here is : ", self.reviewsForUser.count)
        }) { (error) in
            //print("Failed to fetch reviews with error: \(error)")
        }
    }
}
