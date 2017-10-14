//
//  Review.swift
//  cosc4355Project
//
//  Created by Timothy M Shepard on 10/10/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import Foundation

struct Review: BasicListingsProtocol {
    
    var title: String
    var description: String
    var user_id: String
    
    var stars: Double
    var about_id: String
    var posting_id: String
    var reviewTime: Date
    var date: String

    
    // Default Address
    init(stars: Double, about_id: String, posting_id: String, poster_id: String, reviewWords: String) {
        self.stars = stars
        self.about_id = about_id
        self.posting_id = posting_id
        self.user_id = poster_id
        self.description = reviewWords
        self.reviewTime = Date.distantPast
        self.date = Date.currentDate
        self.title = "DEFAULT"
    }
  
    
    func toString() -> String {
        return user_id + " gave rating " + String(stars) + " on " + String(describing: reviewTime) + " for user " + about_id + " and said:\n" + description
    }
}
