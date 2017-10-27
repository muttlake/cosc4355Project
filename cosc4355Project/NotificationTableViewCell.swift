//
//  notificationTableViewCell.swift
//  cosc4355Project
//
//  Created by gintama on 10/16/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit

protocol clearDelegate {
    func removeNotification(row:Int)
}
class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    var row:Int!
    var delegate: clearDelegate!
    
    @IBAction func clear(_ sender: UIButton) {
        self.delegate?.removeNotification(row: row)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
