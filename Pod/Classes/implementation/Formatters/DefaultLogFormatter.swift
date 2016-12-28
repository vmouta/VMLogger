/**
 * @name            DefaultLogFormatter.swift
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

/**
The `DefaultLogFormatter` is a basic implementation of the `LogFormatter` 
protocol.

This implementation is used by default if no other log formatters are specified.
*/
open class DefaultLogFormatter: BaseLogFormatter
{
    open var showThreadID: Bool = false;
    open var showLogIdentifier: Bool = false;
    open var showLogLevel: Bool = true;
    open var showDate: Bool = true;
    open var showMessage: Bool = false;
    
    open var showThreadName: Bool = false;
    open var showFunctionName: Bool = true;
    open var showFileName: Bool = true;
    open var showLineNumber: Bool = true;

    
    /**
     Initializes the DefaultLogFormatter using the given settings.
     
     :param:     includeTimestamp If `true`, the log entry timestamp will be
     included in the formatted message.
     
     :param:     includeThreadID If `true`, an identifier for the calling thread
     will be included in the formatted message.
     */
    public init(showLogIdentifier: Bool = true, showFunctionName: Bool = true, showThreadName: Bool = true, showFileName: Bool = true, showLineNumber: Bool = true, showLogLevel: Bool = true, showDate: Bool = true, showThreadID: Bool = true)
    {
        self.showLogIdentifier = showLogIdentifier
        self.showFunctionName = showFunctionName
        self.showThreadName = showThreadName
        self.showFileName = showFileName
        self.showLineNumber = showLineNumber
        self.showLogLevel = showLogLevel
        self.showDate = showDate
        self.showThreadID = showThreadID
    }
    
    public required convenience init?(configuration: Dictionary<String, Any>) {
        fatalError("init(configuration:) has not been implemented")
    }
    
    /**
     Returns a formatted representation of the given `LogEntry`.
     
     :param:         entry The `LogEntry` being formatted.
     
     :returns:       The formatted representation of `entry`. This particular
     implementation will never return `nil`.
     */
    override open func formatLogEntry(_ entry: LogEntry, message: String) -> String? {
        
        var extendedDetails: String = ""
        if showDate {
            let timestamp = stringRepresentationOfTimestamp(entry.timestamp)
            extendedDetails += "\(timestamp) "
        }
        
        if showLogLevel {
            let severity = stringRepresentationOfSeverity(entry.logLevel)
            extendedDetails += severity
        }
        
        if showLogIdentifier {
            extendedDetails += "[\(entry.logger.fullName())] "
        }
        
        if showThreadName {
            extendedDetails += BaseLogFormatter.stringRepresentationForMDC()
        }
        
        if showFileName {
            let fileName = (entry.callingFilePath as NSString).pathComponents.last ?? "(unknown)"
            let caller =  "[" + fileName + (showLineNumber ? ":" + String(entry.callingFileLine) : "") + "] "
            extendedDetails += caller
        } else if showLineNumber {
            extendedDetails += "[" + String(entry.callingFileLine) + "] "
        }
        
        if showFunctionName {
            extendedDetails += "\(entry.callingFunction) "
        }
        
        if showThreadID {
            extendedDetails += BaseLogFormatter.stringRepresentationOfThreadID(entry.callingThreadID)
        }
        return "\(extendedDetails)> \(message)"
    }
}
