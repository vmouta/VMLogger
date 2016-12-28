/**
 * @name            LogAppender.swift
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

struct LogAppenderConstants {
    static let Name: String = "name"
    static let Encoder: String = "encoder"
    static let Filters: String = "filters"
    static let Class: String = "class"
    static let Formatters: String = "formatters"
}

// MARK: - LogAppender
// - Protocol for output classes to conform to
public protocol LogAppender: CustomDebugStringConvertible {
    
    /**
     The identifier of the `LogRecorder`, which must be unique.
     */
    var name: String {get}
    
    /**
     The `LogFormatter`s that should be used to create a formatted log string
     for passing to the receiver's `recordFormattedString(_: forLogEntry:)`
     function. The formatters will be called sequentially and given an
     opportunity to return a formatted string for each log entry. The first
     non-`nil` return value will be what gets recorded in the log. Typically,
     an implementation of this protocol would not hard-code the `LogFormatter`s
     it uses, but would instead provide a constructor that accepts an array of
     `LogFormatter`s, which it will subsequently return from this property.
     */
    var formatters: [LogFormatter] { get }
    
    /** The list of `LogFilter`s to be used. */
    var filters: [LogFilter]  { get }
    
    /**
     Returns the GCD queue that will be used when executing tasks related to
     the receiver. Log formatting and recording will be performed using
     this queue. This is typically a serial queue because the underlying log
     implementation is usually single-threaded.
     */
    var queue: DispatchQueue { get }
    
    /**
     Called by the `LogReceptacle` to record the formatted log message.
     
     **Note:** This function is only called if one of the `formatters`
     associated with the receiver returned a non-`nil` string.
     
     :param:     message The message to record.
     
     :param:     entry The `LogEntry` for which `message` was created.
     
     :param:     currentQueue The GCD queue on which the function is being
     executed.
     
     :param:     synchronousMode If `true`, the receiver should record the
     log entry synchronously. Synchronous mode is used during
     debugging to help ensure that logs reflect the latest state
     when debug breakpoints are hit. It is not recommended for
     production code.
     */
    func recordFormattedMessage(_ message: String, forLogEntry entry: LogEntry, currentQueue: DispatchQueue, synchronousMode: Bool)
    
    /**
     constructor to be used by introspection
     
     - parameter configuration: configuration for the appender
     
     - returns: if configuration is correct a new LogAppender
     */
    init?(configuration: Dictionary<String, Any>)
}
