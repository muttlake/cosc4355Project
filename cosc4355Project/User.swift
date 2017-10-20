//
//  User.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/6/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//


import Foundation
import UIKit

class User {
  var name: String = "DEFAULT"
  var email: String = "DEFAULT-EMAIL"
  // var address: Address
  var profilePicture: String?
  var userType: UserType = .client
}

class Contractor: User {
    var description: String = "DEFAULT"
    var phoneNumber: String = "NA"
}
