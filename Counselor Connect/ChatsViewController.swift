//
//  ChatsViewController.swift
//  Counselor Connect
//
//  Created by Ethan Look on 3/10/15.
//  Copyright (c) 2015 Ethan Look. All rights reserved.
//

import UIKit

class ChatsViewController: UITableViewController {
    var chats: [Chat] = []
    var studentUsernames: [String] = []
    var unreads: [Bool] = []
    var counselors: [String] = []
    let counselorUsername: String
    let school: String
    
    init(counselorUsername: String, school: String) {
        self.counselorUsername = counselorUsername
        self.school = school
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "counselor_connect_logo.png"))
        
        loadChats()
        
        let signOutButton = UIBarButtonItem(title: "Sign Out", style: UIBarButtonItemStyle.Plain, target: self, action: "signOut")
        navigationItem.leftBarButtonItem = signOutButton

        let dashboardButton = UIBarButtonItem(title: "Dashboard", style: UIBarButtonItemStyle.Plain, target: self, action: "dashboard")
        navigationItem.rightBarButtonItem = dashboardButton
        
        tableView.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        tableView.rowHeight = chatCellHeight
        tableView.separatorInset.left = chatCellInsetLeft
        tableView.registerClass(ChatCell.self, forCellReuseIdentifier: NSStringFromClass(ChatCell))
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "incomingNotification:", name: "incomingNotification", object: nil)
        notificationCenter.addObserver(self, selector: "reloadChats", name: "reloadChats", object: nil)
    }
    
    func incomingNotification(notification: NSNotification) {
        println("Received incoming notification")
        
        studentUsernames = []
        chats = []
        unreads = []
        counselors = []
        loadChats()
    }
    
    func reloadChats() {
        studentUsernames = []
        chats = []
        unreads = []
        counselors = []
        loadChats()
    }
    
    func loadChats() {
        
        println("Loading chats...")
        for username in studentUsernames {
            println(username)
        }
        
        var query = PFQuery(className: "UserMetadata")
        
        query.whereKey("school", equalTo: school)
        
        query.addDescendingOrder("lastMessageDate")
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                NSLog("Successfully retrieved \(objects.count) scores.")
                // Do something with the found objects
                for object in objects {
                    NSLog("%@", object.objectId)
                    var studentUsername = object["username"] as String
                    self.studentUsernames.append(studentUsername)
                    var chat = Chat(lastMessageText: "", lastMessageSentDate: NSDate())
                    self.chats.append(chat)
                    
                    var unread = object["unread"] as Bool
                    self.unreads.append(unread)
                    
                    var school_no_space = self.school.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    school_no_space = school_no_space.stringByReplacingOccurrencesOfString(".", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    
                    var counselor = object["counselor"] as String
                    if counselor == (school_no_space + "Counselors") {
                        counselor = ""
                    }
                    self.counselors.append(counselor)
                }
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
            }
            self.tableView.reloadData()
        }
    }
    
    func signOut() {
        println("Sign out button pressed.")
        PFUser.logOut()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("logInViewController") as UIViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func dashboard() {
        println("to the dashboard I go...")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let dashboardViewController = storyboard.instantiateViewControllerWithIdentifier("dashboardViewController") as DashboardViewController
        dashboardViewController.school = school
        
        self.navigationController?.pushViewController(dashboardViewController, animated: true)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ChatCell), forIndexPath: indexPath) as ChatCell
        cell.configureWithChat(chats[indexPath.row], studentUsername: studentUsernames[indexPath.row], counselorUsername: counselors[indexPath.row], unread: unreads[indexPath.row])
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            chats.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            if chats.count == 0 {
                navigationItem.leftBarButtonItem = nil  // TODO: KVO
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        unreads[indexPath.row] = false
        let chat = chats[indexPath.row]
        let studentUsername = studentUsernames[indexPath.row]
        let chatViewController = ChatViewController(chat: chat, studentUsername: studentUsername, counselorUsername: counselorUsername, student: false, school: school, newUser: false)
        navigationController?.pushViewController(chatViewController, animated: true)
        self.tableView.reloadData()
    }
}
