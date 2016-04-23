//
//  LogInViewController.swift
//  Counselor Connect
//
//  Created by Ethan Look on 3/9/15.
//  Copyright (c) 2015 Ethan Look. All rights reserved.
//

import Foundation


class logInViewController : UIViewController {
    
    @IBOutlet var loginUserTextField: UITextField!
    @IBOutlet var loginPassTextField: UITextField!
    
    @IBOutlet var errorLabel: UILabel!
    
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
    
    @IBAction func logInActionButton(sender: UIButton) {
        if loginUserTextField.text != "" && loginPassTextField.text != "" {
            
                self.errorLabel.text = "Logging in..."
            PFUser.logInWithUsernameInBackground(loginUserTextField.text, password:loginPassTextField.text) {
                (user: PFUser!, error: NSError!) -> Void in
                if user != nil {
                    // Yes, User Exists
                    let student = user["student"] as Bool
                    let school = user["school"] as String
                    
                    var school_no_space = school.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    school_no_space = school_no_space.stringByReplacingOccurrencesOfString(".", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    
                    if student {
                        let currentInstallation = PFInstallation.currentInstallation()
                        currentInstallation.channels = NSArray()
                        let username = self.loginUserTextField.text
                        currentInstallation.addUniqueObject(username, forKey: "channels")
                        currentInstallation.addUniqueObject(school_no_space, forKey: "channels")
                        println(currentInstallation.channels)
                        currentInstallation.saveInBackground()
                        
                        let chat = Chat(lastMessageText: "", lastMessageSentDate: NSDate())
                        let chatScene = UINavigationController(rootViewController: ChatViewController(chat: chat, studentUsername: self.loginUserTextField.text, counselorUsername: "", student: student, school: school, newUser: false))
                        self.presentViewController(chatScene, animated: true, completion: nil)
                    } else {
                        let currentInstallation = PFInstallation.currentInstallation()
                        currentInstallation.channels = NSArray()
                        currentInstallation.addUniqueObject(school_no_space + "Counselors", forKey: "channels")
                        currentInstallation.addUniqueObject(school_no_space, forKey: "channels")
                        currentInstallation.addUniqueObject(self.loginUserTextField.text, forKey: "channels")
                        println(currentInstallation.channels)
                        currentInstallation.saveInBackground()
                        
                        let chatsScene = UINavigationController(rootViewController: ChatsViewController(counselorUsername: self.loginUserTextField.text, school: school))
                        self.presentViewController(chatsScene, animated: true, completion: nil)
                    }
                } else {
                    if let errorString = error.userInfo?["error"] as? NSString {
                        println(errorString)
                        self.errorLabel.text = errorString
                    } else {
                        self.errorLabel.text = "There was an error logging in."
                    }
                }
            }
        } else {
            self.errorLabel.text = "All fields required."
        }
    }
    
    @IBAction func createAccountActionButton(sender: UIButton) {
        performSegueWithIdentifier("createAccountSegue", sender: self)
    }
    
}