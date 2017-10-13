//
//  Review.swift
//  cosc4355Project
//
//  Created by Timothy M Shepard on 10/10/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import Foundation

struct Review {
    var star: Double
    var person_about: String
    var user_id: String
    var reviewWords: String
    var reviewTime: Date
    
    // Default Address
    init() {
        star = 0
        person_about = "DEFAULT"
        user_id = "DEFAULT"
        reviewWords = "DEFAULT"
        reviewTime = Date.distantPast
    }
  
    
    func toString() -> String {
        return user_id + " gave rating " + String(star) + " on " + String(describing: reviewTime) + " for user " + person_about + " and said:\n" + reviewWords
    }
}
