//
//  Posting.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/6/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import Foundation
import UIKit

struct Posting: BasicListingsProtocol {
  var status: Status = Status.pending
  var date: String
  var photoUrl: String
  var startingBid: Double
  var acceptedBid: Double = 0.0
  var location: Address? = nil
  
  /* Conformance to basic listings protocol, more comments in the actual protocol declaration. */
  var title: String
  var description: String
  
  /* To the project the entity is referring to */
  var posting_id: String
  
  /* Use who owns the entity */
  var user_id: String
  
  init(from dict: [String: Any]) {
    status = Status.stringToEnum(string: dict["status"] as! String)
    date = dict["date"] as! String
    photoUrl = dict["photoUrl"] as! String
    startingBid = Double(dict["startingBid"] as! String)!
    acceptedBid = Double(dict["acceptedBid"] as! String)!
    // location = dict["location"] as! String
    title = dict["title"] as! String
    description = dict["description"] as! String
    posting_id = dict["posting_id"] as! String
    user_id = dict["user_id"] as! String
  }
}
