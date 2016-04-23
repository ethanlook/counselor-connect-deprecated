//
//  ChatCell.swift
//  Counselor Connect
//
//  Created by Ethan Look on 3/10/15.
//  Copyright (c) 2015 Ethan Look. All rights reserved.
//

import UIKit

let chatCellHeight: CGFloat = 54
let chatCellInsetLeft: CGFloat = 16

class ChatCell: UITableViewCell {
    let userNameLabel: UILabel
    let counselorLabel: UILabel
    var unread: Bool
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        unread = false
        
        userNameLabel = UILabel(frame: CGRectZero)
        userNameLabel.backgroundColor = UIColor.whiteColor()
        userNameLabel.font = UIFont.systemFontOfSize(17)
        
        counselorLabel = UILabel(frame: CGRectZero)
        counselorLabel.backgroundColor = UIColor.whiteColor()
        counselorLabel.font = UIFont.systemFontOfSize(17)
        counselorLabel.textColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(counselorLabel)
        
        userNameLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addConstraint(NSLayoutConstraint(item: userNameLabel, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: chatCellInsetLeft))
        contentView.addConstraint(NSLayoutConstraint(item: userNameLabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0))
        
        counselorLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addConstraint(NSLayoutConstraint(item: counselorLabel, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: -(chatCellInsetLeft)))
        contentView.addConstraint(NSLayoutConstraint(item: counselorLabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWithChat(chat: Chat, studentUsername: String, counselorUsername: String, unread: Bool) {
        userNameLabel.text = studentUsername
        counselorLabel.text = counselorUsername
        self.unread = unread
        
        if unread {
            userNameLabel.font = UIFont.boldSystemFontOfSize(17)
        } else {
            userNameLabel.font = UIFont.systemFontOfSize(17)
        }
        
    }
}
