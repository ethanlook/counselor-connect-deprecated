//
//  DashboardViewController.swift
//  Counselor Connect
//
//  Created by Ethan Look on 3/23/15.
//  Copyright (c) 2015 Ethan Look. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {
    
    var school: String = ""
    
    @IBOutlet var schoolLabel: UILabel!
    @IBOutlet var autoMessageTextView: UITextView!
    @IBOutlet var pushMessageTextView: UITextView!
    
    override func viewWillAppear(animated: Bool) {
        println(school)
        
        schoolLabel.text = school
        
        var query = PFQuery(className: "School")
        
        query.whereKey("schoolName", equalTo: school)
        
        var schoolObject = query.getFirstObject()
        autoMessageTextView.text = schoolObject["automatedMessage"] as String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "hideToolbar:", name: "hideToolbar", object: nil)
    }
    
    func hideToolbar(sender: AnyObject) {
        view.endEditing(true)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    @IBAction func saveButton(sender: UIButton) {
        var query = PFQuery(className: "School")
        
        query.whereKey("schoolName", equalTo: school)
        
        var schoolObject = query.getFirstObject()
        schoolObject["automatedMessage"] = autoMessageTextView.text
        schoolObject.save()
    }
    
    @IBAction func sendPushButton(sender: UIButton) {
        
        if pushMessageTextView.text != "Placeholder text..." {
        
            var school_no_space = school.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            school_no_space = school_no_space.stringByReplacingOccurrencesOfString(".", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            let data = [
                "alert":pushMessageTextView.text,
                "badge":"Increment",
                "sound":"default"
            ]
            let push = PFPush()
            push.setChannel(school_no_space)
            push.setData(data)
            push.sendPushInBackground()
            
            pushMessageTextView.text = "Placeholder text..."
            
        }
        
    }
}
