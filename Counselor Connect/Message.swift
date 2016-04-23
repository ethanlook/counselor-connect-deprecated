//
//  Message.swift
//  Counselor Connect
//
//  Created by Ethan Look on 1/31/15.
//  Copyright (c) 2015 Ethan Look. All rights reserved.
//

import Foundation

class Message {
    let incoming: Bool
    let text: String
    let sentDate: NSDate
    
    init(incoming: Bool, text: String, sentDate: NSDate) {
        self.incoming = incoming
        self.text = text
        self.sentDate = sentDate
    }
}
