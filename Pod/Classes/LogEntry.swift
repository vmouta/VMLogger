/**
 * @name            LogEntry.swift
 * @partof          zucred AG
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

// MARK: - AppLoggerDetails
// - Data structure to hold all info about a log message, passed to log destination classes
public struct LogEntry {
    
    public let logger: LogConfiguration
    
    /** Represents the payload contained within a log entry. */
    public enum Payload
    {
        /** The log entry is a trace call and contains no explicit payload. */
        case trace
        
        /** The payload contains a text message. */
        case message(String)
        
        /** The payload contains an arbitrary value, or `nil`. */
        case value(Any?)
    }
    
     /** The payload of the log entry. */
    public let payload: Payload
    
    /** The level of the log entry. */
    public let logLevel: LogLevel
    
    /** The signature of the function that issued the log request. */
    public let callingFunction: String
    
    /** The line within the source file at which the log request was issued. */
    public let callingFileLine: Int
    
    /** The path of the source file containing the calling function that issued
     the log request. */
    public let callingFilePath: String
    
    /** A numeric identifier for the calling thread. Note that thread IDs are
     recycled over time. */
    public let callingThreadID: UInt64
    
    /** The time at which the `LogEntry` was created. */
    public let timestamp: Date
    
    /** Dictionary to store miscellaneous data about the log, can be used by formatters and filters etc. Please prefix any keys to help avoid collissions. */
    public var userInfo: [String: Any]
    
    /**
     `LogEntry` initializer.
     
     :param:     payload The payload of the `LogEntry` being constructed.
     
     :param:     logLevel The `LogLevel` of the message being logged.
     
     :param:     callingFunction The signature of the function that issued the
     log request.
     
     :param:     callingFilePath The path of the source file containing the
     calling function that issued the log request.
     
     :param:     callingFileLine The line within the source file at which the log
     request was issued.
     
     :param:     callingThreadID A numeric identifier for the calling thread.
     Note that thread IDs are recycled over time.
     
     :param:     timestamp The time at which the log entry was created. Defaults
     to the current time if not specified.
     */
    public init(logger: LogConfiguration, payload: Payload, logLevel: LogLevel, userInfo: [String: Any] = [:], callingFunction: String, callingFilePath: String, callingFileLine: Int, callingThreadID: UInt64, timestamp: Date = Date()) {
        self.logger = logger
        self.payload = payload
        self.logLevel = logLevel
        self.callingFunction = callingFunction
        self.callingFilePath = callingFilePath
        self.callingFileLine = callingFileLine
        self.callingThreadID = callingThreadID
        self.timestamp = timestamp
        self.userInfo = userInfo
    }
}
