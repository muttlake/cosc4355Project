//
//  Extensions.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/10/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import Foundation
import UIKit
import Firebase

extension Date {
  /* Generates a date string in the desired format */
  static var currentDate: String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(abbreviation: "CDT")
    formatter.dateFormat = "MM.dd.yyyy hh:mm:ss"
    return formatter.string(from: date)
  }
  
  /* Creates date object based of string. ONLY use this when querying database, otherwise crash occurs */
  static func getDate(from string: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM.dd.yyyy hh:mm:ss"
    return dateFormatter.date(from: string)!
  }
}

/* Adds a list of actions to the alert controller item */
extension UIAlertController {
  func addActions(actions: UIAlertAction...) {
    for action in actions {
      addAction(action)
    }
  }
}

/* Gets current ID from FIRAuth */
extension FIRAuth {
  static func getCurrentUserId() -> String {
    return (auth()?.currentUser?.uid)!
  }
}

/* Returns selected title for a segmented control */
extension UISegmentedControl {
  func getSelectedTitle() -> String {
    return titleForSegment(at: selectedSegmentIndex)!
  }
}
