//
//  AppDelegate.swift
//  Counselor Connect
//
//  Created by Ethan Look on 1/31/15.
//  Copyright (c) 2015 Ethan Look. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow!
    var logOutTimer: NSTimer!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {

        if UIDevice.currentDevice().systemVersion.hasPrefix("8.") {
            let settings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(UIRemoteNotificationType.Badge | UIRemoteNotificationType.Sound | UIRemoteNotificationType.Alert)
        }
        
        Parse.setApplicationId("UZd4PQwH0sGGe87trhKbdx7QpFsCXzse0Ntlg8uN", clientKey: "HGR6A0vIVkzh5cBHz73XYuEPkQb4dC8NttUJL62m")
        
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced
            // in iOS 7). In that case, we skip tracking here to avoid double
            // counting the app-open.
            let oldPushHandlerOnly = !self.respondsToSelector(Selector("application:didReceiveRemoteNotification:fetchCompletionHandler:"))
            let noPushPayload: AnyObject? = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey]?
            if oldPushHandlerOnly || noPushPayload != nil {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
    }
    
    func applicationWillResignActive(application: UIApplication) {
        
        let splashScreen = UIView(frame: window.frame)
        splashScreen.tag = 101
        
        let white = UIImageView(frame: window.frame)
        white.image = UIImage(named: "white.png")
        splashScreen.addSubview(white)
        
        let logoImage = UIImage(named: "counselor_connect_large_logo.png")
        let logo = UIImageView(image: logoImage)
        logo.frame = CGRect(x: window.frame.width/2 - logo.frame.width/2, y: window.frame.height/2 - logo.frame.height/2, width: logo.frame.width, height: logo.frame.height)
        splashScreen.addSubview(logo)
        
        window.addSubview(splashScreen)
        
        NSNotificationCenter.defaultCenter().postNotificationName("hideToolbar", object: nil)
        
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        
        let currentInstallation = PFInstallation.currentInstallation()
        if currentInstallation.badge != 0 {
            currentInstallation.badge = 0
            currentInstallation.saveEventually()
        }
        
        let splashScreen = UIApplication.sharedApplication().keyWindow?.subviews.last?.viewWithTag(101)
        splashScreen?.removeFromSuperview()
        
        NSNotificationCenter.defaultCenter().postNotificationName("showToolbar", object: nil)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName("incomingNotification", object: nil, userInfo: userInfo)
//            if let studentUsername: String = userInfo["studentUsername"] as? String {
//                NSNotificationCenter.defaultCenter().postNotificationName("incomingNotification", object: nil, userInfo: userInfo)
//            } else {
//                NSNotificationCenter.defaultCenter().postNotificationName("incomingNotification", object: nil)
//            }
        }
    }
}

