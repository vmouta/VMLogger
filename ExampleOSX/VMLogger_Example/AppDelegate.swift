//
//  AppDelegate.swift
//  VMLogger_Example
//
//  Created by Vasco Mouta on 09.05.17.
//  Copyright © 2017 Sonova AG. All rights reserved.
//

import Cocoa
import VMLogger

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let logger = AppLogger.logger(NSStringFromClass(AppDelegate.classForCoder()))
    
    override class func initialize() {
        
        // Enable default log level
        //AppLogger.enable()
        
        // Set log level manualy
        //AppLogger.enable("debug")
        
        // Set log from default .plist file
        //AppLogger.enableFromFile()
        
        // Set log from default .plist file
        AppLogger.initialize()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        //Local Logger
        logger.verbose()
        ViewController.logger.verbose("verbose")
        AppLogger.verbose("verbose")
        
        // Debug
        logger.debug()
        ViewController.logger.debug("debug")
        AppLogger.debug("debug")
        
        // Info
        logger.info()
        ViewController.logger.info("info")
        AppLogger.info("info")
        
        // Warning
        logger.warning()
        ViewController.logger.warning("warning")
        AppLogger.warning("warning")
        
        //Error
        logger.error()
        ViewController.logger.error("error")
        AppLogger.error("error")
        
        // Severe
        logger.severe()
        ViewController.logger.severe("severe")
        AppLogger.severe("severe")
        
        //Event
        //ViewController.logger.event("severe")
        AppLogger.event("severe")
      
        if let bundleID = Bundle.main.bundleIdentifier {
            logger.info(bundleID)
        }

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

