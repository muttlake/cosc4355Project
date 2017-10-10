//
//  Bid.swift
//  cosc4355Project
//
//  Created by Timothy M Shepard on 10/10/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import Foundation

struct Bid {
  var bidAmount: Double
  var posting_id: String
  var expected_time: Date
  var bidder_id: String
  var user_id: String
  
  /* Why do we have location on the bid? */
  var location: Address
  
  init() {
    bidAmount = 0
    posting_id = "DEFAULT"
    expected_time = Date.distantPast
    bidder_id = "DEFAULT"
    location = Address()
    user_id = "DEFAULT"
  }
  
  func toString() -> String {
    return bidder_id + " bid " + String(bidAmount) + " for posting_id " + posting_id + " for date: " + String(describing: expected_time) + " at location " + location.toString()
  }
}
