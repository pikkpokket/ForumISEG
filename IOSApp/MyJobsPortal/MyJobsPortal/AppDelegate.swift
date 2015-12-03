//
//  AppDelegate.swift
//  MyJobsPortal
//
//  Created by Louis Cheminant on 11/11/2015.
//  Copyright © 2015 Louis Cheminant. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedInUser:Int = prefs.integerForKey("ISLOGGEDINUSER") as Int
        if (isLoggedInUser == 1) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainViewController = storyboard.instantiateViewControllerWithIdentifier("MainUser") as? SWRevealViewController
            self.window?.rootViewController = mainViewController
            self.window?.makeKeyAndVisible()
        }
        let isLoggedInCompagny:Int = prefs.integerForKey("ISLOGGEDINCOMPAGNY") as Int
        if (isLoggedInCompagny == 1) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainViewController = storyboard.instantiateViewControllerWithIdentifier("MainCompagny") as? SWRevealViewController
            self.window?.rootViewController = mainViewController
            self.window?.makeKeyAndVisible()
        }

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
    }
}
