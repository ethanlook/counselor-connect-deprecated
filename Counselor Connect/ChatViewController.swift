//
//  ChatViewController.swift
//  Counselor Connect
//
//  Created by Ethan Look on 1/31/15.
//  Copyright (c) 2015 Ethan Look. All rights reserved.
//

import UIKit
import MessageUI

let messageFontSize: CGFloat = 17
let toolBarMinHeight: CGFloat = 66 //44
let textViewMaxHeight: (portrait: CGFloat, landscape: CGFloat) = (portrait: 272, landscape: 90)

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate {
    let chat: Chat
    var tableView: UITableView!
    var toolBar: UIToolbar!
    var textView: UITextView!
    var sendButton: UIButton!
    var rotating = false
    let studentUsername: String
    let student: Bool
    let school: String
    let newUser: Bool
    var skip: Int = 0
    var counselor: String = ""
    let counselorUsername: String
    var refreshControl: UIRefreshControl!
    var claimButton: UIBarButtonItem!
    
    override var inputAccessoryView: UIView! {
        get {
            if toolBar == nil {
                toolBar = UIToolbar(frame: CGRectMake(0, 0, 0, toolBarMinHeight-0.5))
                
                textView = InputTextView(frame: CGRectZero)
                textView.backgroundColor = UIColor(white: 250/255, alpha: 1)
                textView.delegate = self
                textView.font = UIFont.systemFontOfSize(messageFontSize)
                textView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 205/255, alpha:1).CGColor
                textView.layer.borderWidth = 0.5
                textView.layer.cornerRadius = 5
                textView.scrollsToTop = false
                textView.textContainerInset = UIEdgeInsetsMake(4, 3, 3, 3)
                toolBar.addSubview(textView)
                
                sendButton = UIButton.buttonWithType(.System) as UIButton
                sendButton.enabled = false
                sendButton.titleLabel?.font = UIFont.boldSystemFontOfSize(17)
                sendButton.setTitle("Send", forState: .Normal)
                sendButton.setTitleColor(UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1), forState: .Disabled)
                sendButton.setTitleColor(UIColor(red: 1/255, green: 122/255, blue: 255/255, alpha: 1), forState: .Normal)
                sendButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
                sendButton.addTarget(self, action: "sendAction", forControlEvents: UIControlEvents.TouchUpInside)
                toolBar.addSubview(sendButton)
                
                // Auto Layout allows `sendButton` to change width, e.g., for localization.
                textView.setTranslatesAutoresizingMaskIntoConstraints(false)
                sendButton.setTranslatesAutoresizingMaskIntoConstraints(false)
                toolBar.addConstraint(NSLayoutConstraint(item: textView, attribute: .Left, relatedBy: .Equal, toItem: toolBar, attribute: .Left, multiplier: 1, constant: 8))
                toolBar.addConstraint(NSLayoutConstraint(item: textView, attribute: .Top, relatedBy: .Equal, toItem: toolBar, attribute: .Top, multiplier: 1, constant: 7.5))
                toolBar.addConstraint(NSLayoutConstraint(item: textView, attribute: .Right, relatedBy: .Equal, toItem: sendButton, attribute: .Left, multiplier: 1, constant: -2))
                toolBar.addConstraint(NSLayoutConstraint(item: textView, attribute: .Bottom, relatedBy: .Equal, toItem: toolBar, attribute: .Bottom, multiplier: 1, constant: -8))
                toolBar.addConstraint(NSLayoutConstraint(item: sendButton, attribute: .Right, relatedBy: .Equal, toItem: toolBar, attribute: .Right, multiplier: 1, constant: 0))
                toolBar.addConstraint(NSLayoutConstraint(item: sendButton, attribute: .Bottom, relatedBy: .Equal, toItem: toolBar, attribute: .Bottom, multiplier: 1, constant: -4.5))
            }
            return toolBar
        }
    }
    
    init(chat: Chat, studentUsername: String, counselorUsername: String, student: Bool, school: String, newUser: Bool) {
        self.chat = chat
        self.studentUsername = studentUsername
        self.counselorUsername = counselorUsername
        self.student = student
        self.school = school
        self.newUser = newUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        
        if student {
            self.navigationItem.titleView = UIImageView(image: UIImage(named: "counselor_connect_logo.png"))
            let signOutButton = UIBarButtonItem(title: "Sign Out", style: UIBarButtonItemStyle.Plain, target: self, action: "signOut")
            navigationItem.leftBarButtonItem = signOutButton
            
            var query = PFQuery(className: "UserMetadata")
            query.whereKey("username", equalTo:studentUsername)
            var studentAccount = query.getFirstObject()
            counselor = studentAccount["counselor"] as String
            
        } else {
            self.navigationItem.title = self.studentUsername
            navigationItem.hidesBackButton = false
            
            var query = PFQuery(className: "UserMetadata")
            query.whereKey("username", equalTo:studentUsername)
            var studentAccount = query.getFirstObject()
            
            if counselorUsername == studentAccount["counselor"] as String {
                claimButton = UIBarButtonItem(title: "Unclaim Student", style: UIBarButtonItemStyle.Plain, target: self, action: "claimStudent")
            } else {
                claimButton = UIBarButtonItem(title: "Claim Student", style: UIBarButtonItemStyle.Plain, target: self, action: "claimStudent")
            }
            
            navigationItem.rightBarButtonItem = claimButton
            
            studentAccount["unread"] = false
            studentAccount.save()
        }

        chat.loadedMessages = []
        
        if newUser {
            automatedMessage()
        }
        
        loadMessages()
        println(chat.loadedMessages)
        
        let backColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        view.backgroundColor = backColor
        
        tableView = UITableView(frame: view.bounds, style: .Plain)
        tableView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        tableView.backgroundColor = backColor
        let edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: toolBarMinHeight, right: 0)
        tableView.contentInset = edgeInsets
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .Interactive
        tableView.estimatedRowHeight = 44
        tableView.separatorStyle = .None
        tableView.registerClass(MessageSentDateCell.self, forCellReuseIdentifier: NSStringFromClass(MessageSentDateCell))
        view.addSubview(tableView)
        
        refreshControl.addTarget(self, action: "loadMoreMessages", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "hideToolbar:", name: "hideToolbar", object: nil)
        notificationCenter.addObserver(self, selector: "showToolbar:", name: "showToolbar", object: nil)
        notificationCenter.addObserver(self, selector: "incomingNotification:", name: "incomingNotification", object: nil)
    }
    
    func hideToolbar(notification: NSNotification) {
        toolBar.hidden = true
        textView.resignFirstResponder()
    }
    
    func showToolbar(notification: NSNotification) {
        toolBar.hidden = false
    }
    
    func incomingNotification(notification: NSNotification) {
        println("Received incoming notification")
        if student {
            getLastMessage()
        } else {
            let userInfo = notification.userInfo as Dictionary<String, AnyObject>
            
            let incomingStudentUsername = userInfo["studentUsername"] as String?
            if incomingStudentUsername == studentUsername {
                getLastMessage()
                
                var query = PFQuery(className: "UserMetadata")
                query.whereKey("username", equalTo:studentUsername)
                var studentAccount = query.getFirstObject()
                studentAccount["unread"] = false
                studentAccount.save()
                
                NSNotificationCenter.defaultCenter().postNotificationName("reloadChats", object: nil)
            }
        }
    }
    
    func getLastMessage() {
        var query = PFQuery(className:"Message")
        
        query.whereKey("student", equalTo: studentUsername)
        
        query.addDescendingOrder("createdAt")
        query.limit = 1
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                NSLog("Successfully retrieved \(objects.count) scores.")
                // Do something with the found objects
                for object in objects {
                    self.skip += 1
                    
                    NSLog("%@", object.objectId)
                    var incoming = false
                    if self.student {
                        incoming = object["incomingToStudent"] as Bool
                    } else {
                        incoming = !(object["incomingToStudent"] as Bool)
                    }
                    let text = object["messageContent"] as String
                    let sentDate = object.createdAt
                    self.chat.loadedMessages.append([Message(incoming: incoming, text: text, sentDate: sentDate)])
                    
                    let lastSection = self.tableView.numberOfSections()
                    self.tableView.beginUpdates()
                    self.tableView.insertSections(NSIndexSet(index: lastSection), withRowAnimation: .Automatic)
                    self.tableView.insertRowsAtIndexPaths([
                        NSIndexPath(forRow: 0, inSection: lastSection),
                        NSIndexPath(forRow: 1, inSection: lastSection)
                        ], withRowAnimation: .Automatic)
                    self.tableView.endUpdates()
                    self.tableViewScrollToBottomAnimated(true)
                }
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
            }
        }
    }
    
    func loadMessages() {
        var query = PFQuery(className:"Message")
        
        query.whereKey("student", equalTo: studentUsername)
        
        query.addDescendingOrder("createdAt")
        query.limit = 15
        query.skip = skip
        println(self.skip)
        var objects = query.findObjects()
        
        for object in objects {
            self.skip += 1
            
            var incoming = false
            if self.student {
                incoming = object["incomingToStudent"] as Bool
            } else {
                incoming = !(object["incomingToStudent"] as Bool)
            }
            let text = object["messageContent"] as String
            let sentDate = object.createdAt
            self.chat.loadedMessages.insert([Message(incoming: incoming, text: text, sentDate: sentDate)], atIndex: 0)
        }
       
        self.refreshControl.endRefreshing()
        
        println("loadedMessages count: " + String(self.chat.loadedMessages.count))
    }
    
    func loadMoreMessages() {
        var query = PFQuery(className:"Message")
        
        query.whereKey("student", equalTo: studentUsername)
        
        query.addDescendingOrder("createdAt")
        query.limit = 15
        query.skip = skip
        println(self.skip)
        var objects = query.findObjects()
        
        for object in objects {
            self.skip += 1
            
            var incoming = false
            if self.student {
                incoming = object["incomingToStudent"] as Bool
            } else {
                incoming = !(object["incomingToStudent"] as Bool)
            }
            let text = object["messageContent"] as String
            let sentDate = object.createdAt
            self.chat.loadedMessages.insert([Message(incoming: incoming, text: text, sentDate: sentDate)], atIndex: 0)
        }
        
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
        
        println("loadedMessages count: " + String(self.chat.loadedMessages.count))
    }
    
    func automatedMessage() {
        
        var messageContent = "Thank you for using Counselor Connect to anonymously speak with the counselors at your school. No matter what you are dealing with, we want to help you. If this is a life-threatening emergency, please call 911. The National Suicide Prevention Lifeline is available 24/7 at 1 (800) 273-8255. We will get back to you as soon as possible."
        
        var query = PFQuery(className: "School")
        
        query.whereKey("schoolName", equalTo: school)
        
        
        var objects = query.findObjects()
        for object in objects {
            NSLog("%@", object.objectId)
            messageContent = object["automatedMessage"] as String
        }
        
        var message: PFObject = PFObject(className: "Message")
        
        message["student"] = studentUsername
        message["incomingToStudent"] = true
        message["messageContent"] = messageContent
        message.save()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated)
        tableView.flashScrollIndicators()
    }
    
    override func viewWillDisappear(animated: Bool)  {
        super.viewWillDisappear(animated)
        chat.draft = textView.text
    }
    
    // This gets called a lot. Perhaps there's a better way to know when `view.window` has been set?
    override func viewDidLayoutSubviews()  {
        super.viewDidLayoutSubviews()
        
        if !chat.draft.isEmpty {
            textView.text = chat.draft
            chat.draft = ""
            textViewDidChange(textView)
            textView.becomeFirstResponder()
        }
    }
    
    func signOut() {
        println("Sign out button pressed.")
        PFUser.logOut()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("logInViewController") as UIViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func claimStudent() {
        println("Claim/unclaim student!")
        
        var query = PFQuery(className: "UserMetadata")
        query.whereKey("username", equalTo:studentUsername)
        var studentAccount = query.getFirstObject()
        
        if claimButton.title == "Claim Student" {
            studentAccount["counselor"] = counselorUsername
            studentAccount.save()
            
            claimButton.title = "Unclaim Student"
        } else {
            var school_no_space = school.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            school_no_space = school_no_space.stringByReplacingOccurrencesOfString(".", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            studentAccount["counselor"] = school_no_space + "Counselors"
            studentAccount.save()
            
            claimButton.title = "Claim Student"
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("reloadChats", object: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return chat.loadedMessages.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chat.loadedMessages[section].count + 1 // for sent-date cell
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(MessageSentDateCell), forIndexPath: indexPath) as MessageSentDateCell
            let message = chat.loadedMessages[indexPath.section][0]
            dateFormatter.dateStyle = .ShortStyle
            dateFormatter.timeStyle = .ShortStyle
            cell.sentDateLabel.text = dateFormatter.stringFromDate(message.sentDate)
            return cell
        } else {
            let cellIdentifier = NSStringFromClass(MessageBubbleCell)
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as MessageBubbleCell!
            if cell == nil {
                cell = MessageBubbleCell(style: .Default, reuseIdentifier: cellIdentifier)
                cell.contentView.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
            }
            if !student {
                let longPressRec = UILongPressGestureRecognizer()
                longPressRec.addTarget(self, action: "emailAlert:")
                cell.addGestureRecognizer(longPressRec)
            }
            let message = chat.loadedMessages[indexPath.section][indexPath.row-1]
            cell.configureWithMessage(message)
            return cell
        }
    }
    
    func tableView(tableView: UITableView!, willSelectRowAtIndexPath indexPath: NSIndexPath!) -> NSIndexPath! {
        return nil
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var cell_height = CGFloat(0)
        
        if indexPath.row == 0 {
            let cell = MessageSentDateCell(style: .Default, reuseIdentifier: nil)
            let message = chat.loadedMessages[indexPath.section][0]
            dateFormatter.dateStyle = .ShortStyle
            dateFormatter.timeStyle = .ShortStyle
            cell.sentDateLabel.text = dateFormatter.stringFromDate(message.sentDate)
            cell_height = cell.frame.height
        } else {
            var cell = MessageBubbleCell(style: .Default, reuseIdentifier: nil)
            
            let message = chat.loadedMessages[indexPath.section][indexPath.row - 1]
            println(message.text)
            cell.configureWithMessage(message)
            cell_height = cell.cellHeight
        }
        
        return cell_height
    }
    
    func textViewDidChange(textView: UITextView!) {
        updateTextViewHeight()
        sendButton.enabled = textView.hasText()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo as NSDictionary!
        let frameNew = (userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
        let insetNewBottom = tableView.convertRect(frameNew, fromView: nil).height
        let insetOld = tableView.contentInset
        let insetChange = insetNewBottom - insetOld.bottom
        let overflow = tableView.contentSize.height - (tableView.frame.height-insetOld.top-insetOld.bottom)
        
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as NSNumber).doubleValue
        let animations: (() -> Void) = {
            if !(self.tableView.tracking || self.tableView.decelerating) {
                // Move content with keyboard
                if overflow > 0 {                   // scrollable before
                    self.tableView.contentOffset.y += insetChange
                    if self.tableView.contentOffset.y < -insetOld.top {
                        self.tableView.contentOffset.y = -insetOld.top
                    }
                } else if insetChange > -overflow { // scrollable after
                    self.tableView.contentOffset.y += insetChange + overflow
                }
            }
        }
        if duration > 0 {
            let options = UIViewAnimationOptions(UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as NSNumber).integerValue << 16)) // http://stackoverflow.com/a/18873820/242933
            UIView.animateWithDuration(duration, delay: 0, options: options, animations: animations, completion: nil)
        } else {
            animations()
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        let userInfo = notification.userInfo as NSDictionary!
        let frameNew = (userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
        let insetNewBottom = tableView.convertRect(frameNew, fromView: nil).height
        
        // Inset `tableView` with keyboard
        let contentOffsetY = tableView.contentOffset.y
        tableView.contentInset.bottom = insetNewBottom
        tableView.scrollIndicatorInsets.bottom = insetNewBottom
        // Prevents jump after keyboard dismissal
        if self.tableView.tracking || self.tableView.decelerating {
            tableView.contentOffset.y = contentOffsetY
        }
    }
    
    func updateTextViewHeight() {
        let oldHeight = textView.frame.height
        let maxHeight = UIInterfaceOrientationIsPortrait(interfaceOrientation) ? textViewMaxHeight.portrait : textViewMaxHeight.landscape
        var newHeight = min(textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.max)).height, maxHeight)
        #if arch(x86_64) || arch(arm64)
            newHeight = ceil(newHeight)
            #else
            newHeight = CGFloat(ceilf(newHeight.native))
        #endif
        if newHeight != oldHeight {
//            textView.frame.size.height = newHeight+8*2-0.5
        }
    }
    
    func sendAction() {
        // Autocomplete text before sending #hack
        textView.resignFirstResponder()
        textView.becomeFirstResponder()
        
        chat.loadedMessages.append([Message(incoming: false, text: textView.text, sentDate: NSDate())])
        var message: PFObject = PFObject(className: "Message")
        message["student"] = studentUsername
        if student {
            message["incomingToStudent"] = false
        } else {
            message["incomingToStudent"] = true
        }
        message["messageContent"] = textView.text
        message.save()
        
        var query = PFQuery(className: "UserMetadata")
        query.whereKey("username", equalTo:studentUsername)
        var studentAccount = query.getFirstObject()
        studentAccount["lastMessageDate"] = message.createdAt
        if student {
            studentAccount["unread"] = true
        } else {
            studentAccount["unread"] = false
        }
        studentAccount.save()
        
        if student {
            let data = [
                "alert":"You have a new message from " + studentUsername + ".",
                "studentUsername":studentUsername,
                "badge":"Increment",
                "sound":"default"
            ]
            let push = PFPush()
            push.setChannel(counselor)
            push.setData(data)
            push.sendPushInBackground()
            
            var school_no_space = school.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            school_no_space = school_no_space.stringByReplacingOccurrencesOfString(".", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            let push2 = PFPush()
            push.setChannel(school_no_space + "Counselors")
            push.sendPushInBackground()
        } else {
            let data = [
                "alert":"You have a new message.",
                "badge":"Increment",
                "sound":"default"
                ]
            let push = PFPush()
            push.setChannel(studentUsername)
            push.setData(data)
            push.sendPushInBackground()
        }
        
        textView.text = nil
        updateTextViewHeight()
        sendButton.enabled = false
        
        let lastSection = tableView.numberOfSections()
        tableView.beginUpdates()
        tableView.insertSections(NSIndexSet(index: lastSection), withRowAnimation: .Automatic)
        tableView.insertRowsAtIndexPaths([
            NSIndexPath(forRow: 0, inSection: lastSection),
            NSIndexPath(forRow: 1, inSection: lastSection)
            ], withRowAnimation: .Automatic)
        tableView.endUpdates()
        tableViewScrollToBottomAnimated(true)
    }
    
    func emailAlert(sender: AnyObject) {
        println("Showing email alert...")
        
        let emailAlert = UIAlertController(title: "Email message?", message: "You will be able to email the contents of the selected message.", preferredStyle: UIAlertControllerStyle.Alert)
        
        emailAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))

        let emailAction = UIAlertAction(title: "Send Email", style: .Default) { (action) in
            println("Doing email stuff...")
            
            let message = sender.view as MessageBubbleCell
            let mailComposeViewController = self.configuredMailComposeViewController(message)
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        }
        emailAlert.addAction(emailAction)
        
        self.presentViewController(emailAlert, animated: true, completion: nil)
    }
    
    func configuredMailComposeViewController(message: MessageBubbleCell) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setSubject("Counselor Connect - " + studentUsername)
        mailComposerVC.setMessageBody("The following message was received from '\(studentUsername)' via Counselor Connect:\n\n'\(message.messageLabel.text!)'", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableViewScrollToBottomAnimated(animated: Bool) {
        let numberOfSections = tableView.numberOfSections()
        let numberOfRows = tableView.numberOfRowsInSection(numberOfSections-1)
        
        if numberOfRows > 0 {
            let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
        }
    }
    
    
    func messageCopyTextAction(menuController: UIMenuController) {
        let selectedIndexPath = tableView.indexPathForSelectedRow()
        let selectedMessage = chat.loadedMessages[selectedIndexPath!.section][selectedIndexPath!.row-1]
        UIPasteboard.generalPasteboard().string = selectedMessage.text
    }
    
    func menuControllerWillHide(notification: NSNotification) {
        tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow()!, animated: false)
        (notification.object as UIMenuController).menuItems = nil
    }
}

// Only show "Copy" when editing `textView` #CopyMessage
class InputTextView: UITextView {
    override func canPerformAction(action: Selector, withSender sender: AnyObject!) -> Bool {
        if (delegate as ChatViewController).tableView.indexPathForSelectedRow() != nil {
            return action == "messageCopyTextAction:"
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
    }
    
    // More specific than implementing `nextResponder` to return `delegate`, which might cause side effects?
    func messageCopyTextAction(menuController: UIMenuController) {
        (delegate as ChatViewController).messageCopyTextAction(menuController)
    }
}
