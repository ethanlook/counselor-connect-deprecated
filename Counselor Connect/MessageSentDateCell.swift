//
//  MessageSentDateCell.swift
//  Counselor Connect
//
//  Created by Ethan Look on 1/31/15.
//  Copyright (c) 2015 Ethan Look. All rights reserved.
//

import UIKit

class MessageSentDateCell: UITableViewCell {
    let sentDateLabel: UILabel
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        sentDateLabel = UILabel(frame: CGRectZero)
        sentDateLabel.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        sentDateLabel.font = UIFont.systemFontOfSize(11)
        sentDateLabel.textAlignment = .Center
        sentDateLabel.textColor = UIColor(red: 142/255.0, green: 142/255.0, blue: 147/255.0, alpha: 1)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        contentView.addSubview(sentDateLabel)
        
        contentView.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        
        // Flexible width autoresizing causes text to jump because center text alignment doesn't animate
        sentDateLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addConstraint(NSLayoutConstraint(item: sentDateLabel, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: sentDateLabel, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 13))
        contentView.addConstraint(NSLayoutConstraint(item: sentDateLabel, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: -4.5))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}