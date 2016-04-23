//
//  SignUpViewController.swift
//  Counselor Connect
//
//  Created by Ethan Look on 3/9/15.
//  Copyright (c) 2015 Ethan Look. All rights reserved.
//

import Foundation

class signUpViewController : UIViewController {

    @IBOutlet var userTextField: UITextField!
    @IBOutlet var passTextField: UITextField!
    
    @IBOutlet var errorLabel: UILabel!
    
    @IBOutlet var pickerView: UIPickerView!
    var school = "Select your school"
    
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
    
    @IBAction func createAccountActionButton(sender: UIButton) {
        
        let username = userTextField.text
        let password = passTextField.text
        
        if username != "" && password != "" && school != "Select your school" {
            
            if !checkUsername(username) {
                self.errorLabel.text = "Invalid username."
            } else if !checkPassword(password) {
                self.errorLabel.text = "Invalid password."
            } else {
                self.errorLabel.text = "Signing up..."
                
                var user = PFUser()
                user.username = userTextField.text
                user.password = passTextField.text
                user["student"] = true
                println(school)
                user["school"] = school
                
                var school_no_space = school.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                school_no_space = school_no_space.stringByReplacingOccurrencesOfString(".", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                
                user.signUpInBackgroundWithBlock {
                    (succeeded: Bool!, error: NSError!) -> Void in
                    if error == nil {
                        // Hooray! Let them use the app now.
                        let currentInstallation = PFInstallation.currentInstallation()
                        currentInstallation.channels = NSArray()
                        currentInstallation.addUniqueObject(user.username, forKey: "channels")
                        currentInstallation.addUniqueObject(school_no_space, forKey: "channels")
                        currentInstallation.saveInBackground()
                        
                        self.errorLabel.text = "Success!"
                        
                        let chat = Chat(lastMessageText: "", lastMessageSentDate: NSDate())
                        let chatScene = UINavigationController(rootViewController: ChatViewController(chat: chat, studentUsername: self.userTextField.text, counselorUsername: "", student: true, school: self.school, newUser: true))
                        self.presentViewController(chatScene, animated: true, completion: nil)
                    } else {
                        if let errorString = error.userInfo?["error"] as? NSString {
                            println(errorString)
                            self.errorLabel.text = errorString
                        } else {
                            self.errorLabel.text = "There was an error signing up."
                        }
                    }
                }
                
                let userMetadata = PFObject(className: "UserMetadata")
                userMetadata["username"] = username
                userMetadata["school"] = school
                userMetadata["lastMessageDate"] = NSDate()
                userMetadata["unread"] = true
                userMetadata["counselor"] = school_no_space + "Counselors"
                userMetadata.save()
                
                let alert = username + " has created an account at your school."
                let data = [
                    "alert":alert,
                    "studentUsername":username,
                    "badge":"Increment",
                    "sound":""
                ]
                let push = PFPush()
                push.setChannel(school_no_space + "Counselors")
                push.setData(data)
                push.sendPushInBackground()
            }
            
        } else {
            self.errorLabel.text = "All fields required."
        }
    }
    
    func checkUsername(username: String) -> Bool {
        var good_username = true
        
        var set = NSMutableCharacterSet()
        set.addCharactersInString("abcdefghijklmnopqrstuvwxyz")
        set.addCharactersInString("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        set.addCharactersInString("0123456789.")
        let inverted = set.invertedSet
        
        if let range = username.rangeOfCharacterFromSet(inverted, options: NSStringCompareOptions.LiteralSearch, range: nil) {
            good_username = false
        }
        
        let letterSet = NSCharacterSet.letterCharacterSet()
        let char: Character = Array(username)[0]
        if !letterSet.characterIsMember(String(char).utf16[0]) {
            good_username = false
        }
        
        return good_username
    }
    
    func checkPassword(password: String) -> Bool {
        var good_password = true
        
        var set = NSMutableCharacterSet()
        set.addCharactersInString("abcdefghijklmnopqrstuvwxyz")
        set.addCharactersInString("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        set.addCharactersInString("0123456789")
        let inverted = set.invertedSet
        
        if let range = password.rangeOfCharacterFromSet(inverted, options: NSStringCompareOptions.LiteralSearch, range: nil) {
            good_password = false
        }
        
        return good_password
    }
    
    @IBAction func backActionButton(sender: UIButton) {    performSegueWithIdentifier("backToLoginSegue", sender: self)
    }
    
    var schools = ["Select your school"]
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var query = PFQuery(className: "School")
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                NSLog("Successfully retrieved \(objects.count) scores.")
                // Do something with the found objects
                for object in objects {
                    var school = object["schoolName"] as String
                    self.schools.append(school)
                    println(school)
                }
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
            }
            self.pickerView.reloadAllComponents()
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return schools.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return schools[row]
    }
    
    func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int) {
        school = schools[row]
    }
}