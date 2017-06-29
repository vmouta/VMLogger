/**
* @name             AppLogger.swift
* @partof           zucred AG
* @description
* @author	 		Vasco Mouta
* @created			21/11/15
*
* Copyright (c) 2015 zucred AG All rights reserved.
* This material, including documentation and any related
* computer programs, is protected by copyright controlled by
* zucred AG. All rights are reserved. Copying,
* including reproducing, storing, adapting or translating, any
* or all of this material requires the prior written consent of
* zucred AG. This material also contains confidential
* information which may not be disclosed to others without the
* prior written consent of zucred AG.
*/

import Foundation
import VMLogger

/// Class to encapsulate the Log class to avoid carring around VMLogger dependence
open class AppLogger : Log {
    
    static let AppLoggerUI: String = "TrackUI"
    fileprivate static let ForgroundDuration: String = "ForgroundDuration"
    fileprivate static let BackgroundDuration: String = "BackgroundDuration"
    fileprivate static let Teriminated: String = "Terminated"
    
    fileprivate static let AppLoggerInfoFile: String = "AppLogger-Info"
    
    fileprivate static var startDate: Date = Date()
    fileprivate static var eventDate: Date = startDate
    
    open static func initialize(_ fileName: String = AppLogger.AppLoggerInfoFile) {
        if let _ = AppLogger.configureFromMainBundleFile() {
            _ = eventDate /* avoid lazy initialization */
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
            notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
            notificationCenter.addObserver(self, selector: #selector(appTerminate), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
            notificationCenter.addObserver(self, selector: #selector(appResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
            notificationCenter.addObserver(self, selector: #selector(appBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        }
    }
    
    open static func logger(_ identifier: String) -> AppLogger {
        return super.getLogger(identifier) as! AppLogger
    }
    
    open static func dump() {
        super.dumpLog()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: NSNotificationCenter notifications
    
    @objc class open func appMovedToBackground() {
        AppLogger.verbose("appMovedToBackground")
        
        let end = Date();
        let timeInterval: Double = end.timeIntervalSince(eventDate);
        AppLogger.event(AppLoggerEvent.createEvent(AppLoggerEvent.UI, action:ForgroundDuration, label:"\(timeInterval)", value:nil))
        eventDate = Date()
    }
    
    @objc class open func appMovedToForeground() {
        AppLogger.verbose("appMovedToForeground")
        
        let end = Date();
        let timeInterval: Double = end.timeIntervalSince(eventDate);
        AppLogger.event(AppLoggerEvent.createEvent(AppLoggerEvent.UI, action:BackgroundDuration, label:"\(timeInterval)", value:nil))
        eventDate = Date()
    }
    
    @objc class open func appTerminate() {
        AppLogger.verbose("appTerminate")
        
        let end = Date();
        let timeInterval: Double = end.timeIntervalSince(startDate);
        AppLogger.event(AppLoggerEvent.createEvent(AppLoggerEvent.UI, action:Teriminated, label:"\(timeInterval)", value:nil))
    }
    
    @objc class open func appResignActive() {
        AppLogger.verbose("appResignActive")
    }
    
    @objc class open func appBecomeActive() {
        AppLogger.verbose("appBecomeActive")
    }
}
