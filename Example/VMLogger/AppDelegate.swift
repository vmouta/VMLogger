//
//  AppDelegate.swift
//  Logger
//
//  Created by Vasco Mouta on 12/14/2015.
//  Copyright (c) 2015 Vasco Mouta. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let logger = AppLogger.logger(NSStringFromClass(AppDelegate.classForCoder()))
    
    var window: UIWindow?

    override class func initialize() {
       
        // Enable default log level
        //AppLogger.enable()
        
        // Set log level manualy
        //AppLogger.enable("debug")
        
        // Set log from default .plist file
        AppLogger.enableFromFile()
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //Local Logger
        logger.verbose()
        ViewController.logger.verbose("verbose")
        AppLogger.verbose("verbose")
        logger.debug()
        ViewController.logger.debug("debug")
        AppLogger.debug("debug")
        logger.info()
        ViewController.logger.info("info")
        AppLogger.info("info")
        logger.warning()
        ViewController.logger.warning("warning")
        AppLogger.warning("warning")
        logger.error()
        ViewController.logger.error("error")
        AppLogger.error("error")
        logger.severe()
        ViewController.logger.severe("severe")
        AppLogger.severe("severe")
        
        //case
        if let uuid = UIDevice.currentDevice().identifierForVendor?.UUIDString {
            logger.info(uuid)
        }
        if let bundleID = NSBundle.mainBundle().bundleIdentifier {
            logger.info(bundleID)
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        logger.debug()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        logger.debug()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        logger.debug()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        logger.debug()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        logger.debug()
    }


}

