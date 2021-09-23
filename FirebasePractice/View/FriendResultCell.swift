//
//  FriendResultCell.swift
//  FirebasePractice
//
//  Created by Yi-Chin Hsu on 2021/9/23.
//

import UIKit

class FriendResultCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addFriend: UIButton!
    
    func setCell(name: String, email: String) {
        nameLabel.text = name
        emailLabel.text = email
    }
    
}
