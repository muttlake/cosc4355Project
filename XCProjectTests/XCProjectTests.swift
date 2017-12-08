//
//  XCProjectTests.swift
//  XCProjectTests
//
//  Created by Ron Borneo on 10/7/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import XCTest
import Firebase
@testable import cosc4355Project

class XCProjectTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testGetFormattedCurrency() {
    XCTAssertEqual(Double.getFormattedCurrency(num: 100), 100.00)
  }
  
  
}
