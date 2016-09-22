/**
 * @name             BaseLogFormatter.swift
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

/**
The `DefaultLogFormatter` is a basic implementation of the `LogFormatter` 
protocol.

This implementation is used by default if no other log formatters are specified.
*/
public class BaseLogFormatter: LogFormatter
{
    private static let timestampFormatter: NSDateFormatter = {
        let fmt = NSDateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS zzz"
        return fmt
    }()
    
    public let dateFormatter: NSDateFormatter
    public let severityTagLenght: Int
    public let identityTagLenght: Int
    
    public init(dateFormatter: NSDateFormatter =  timestampFormatter, severityTagLenght: Int = 0, identityTagLenght: Int = 0) {
        self.dateFormatter = dateFormatter
        self.severityTagLenght = severityTagLenght
        self.identityTagLenght = identityTagLenght
    }
    
    public required convenience init?(configuration: Dictionary<String, AnyObject>) {
        
        self.init()
    }
    
    /**
    Returns a formatted representation of the given `LogEntry`.
    
    :param:         entry The `LogEntry` being formatted.

    :returns:       The formatted representation of `entry`. This particular
                    implementation will never return `nil`.
    */
    public func formatLogEntry(entry: LogEntry) -> String? {
        precondition(false, "Must override this")
        return nil
    }

    /**
    Returns a string representation for a calling file and line.

    This implementation is used by the `DefaultLogFormatter` for creating
    string representations of a `LogEntry`'s `callingFilePath` and
    `callingFileLine` properties.

    :param:     filePath The full file path of the calling file.
    
    :param:     line The line number within the calling file.
    
    :returns:   The string representation of `filePath` and `line`.
    */
    public static func stringRepresentationForCallingFile(filePath: String, line: Int) -> String
    {
        let file = (filePath as NSString).pathComponents.last ?? "(unknown)"
        return "\(file):\(line)"
    }
    
    /**
     Returns a string representation for a calling file and line.
     
     This implementation is used by the `DefaultLogFormatter` for creating
     string representations of a `LogEntry`'s `callingFilePath` and
     `callingFileLine` properties.
     
     :param:     filePath The full file path of the calling file.
     
     :param:     line The line number within the calling file.
     
     :returns:   The string representation of `filePath` and `line`.
     */
    public static func stringRepresentationForFile(filePath: String) -> String
    {
        return (filePath as NSString).pathComponents.last ?? "(unknown)"
    }

    /**
    Returns a string representation of an arbitrary optional value.

    This implementation is used by the `DefaultLogFormatter` for creating
    string representations of `LogEntry` payloads.

    :param:     entry The `LogEntry` whose payload is desired in string form.
    
    :returns:   The string representation of `entry`'s payload.
    */
    public static func stringRepresentationForPayload(entry: LogEntry) -> String
    {
        switch entry.payload {
        case .Trace:                return entry.callingFunction
        case .Message(let msg):     return msg
        case .Value(let value):     return stringRepresentationForValue(value)
        }
    }

    /**
    Returns a string representation of an arbitrary optional value.

    This implementation is used by the `DefaultLogFormatter` for creating
    string representations of `LogEntry` instances containing `.Value` payloads.

    :param:     value The value for which a string representation is desired.
    
    :returns:   If value is `nil`, the string "`(nil)`" is returned; otherwise,
                the return value of `stringRepresentationForValue(Any)` is
                returned.
    */
    public static func stringRepresentationForValue(value: Any?) -> String
    {
        if let value = value {
            return stringRepresentationForValue(value)
        } else {
            return "(nil)"
        }
    }
    
    public static func stringRepresentationForExec(closure: () -> ()) -> String
    {
        closure()
        return "(Executed)"
    }
    
    public static func stringRepresentationForMDC() -> String {
        if NSThread.isMainThread() {
            return "[main] "
        } else {
            if let threadName = NSThread.currentThread().name where threadName != "" {
                return "[" + threadName + "] "
            } else {
                return "[" + String(format:"%p", NSThread.currentThread()) + "] "
            }
        }
    }

    /**
    Returns a string representation of an arbitrary value.
    
    This implementation is used by the `DefaultLogFormatter` for creating
    string representations of `LogEntry` instances containing `.Value` payloads.

    :param:     value The value for which a string representation is desired.
    
    :returns:   A string representation of `value`.
    */
    public static func stringRepresentationForValue(value: Any) -> String
    {
        let type = Mirror(reflecting: value).subjectType

        let desc: String
        if let debugValue = value as? CustomDebugStringConvertible {
            desc = debugValue.debugDescription
        }
        else if let printValue = value as? CustomStringConvertible {
            desc = printValue.description
        }
        else if let objcValue = value as? NSObject {
            desc = objcValue.description
        }
        else if let objcValue = value as? ()->String? {
            if let result = objcValue() {
                desc = result
            } else {
                desc = "(no description)"
            }
        }
        else if let objcValue = value as? ()->() {
            objcValue()
            desc = "(no description)"
        }
        else {
            desc = "(no description)"
        }
        return "<\(type): \(desc)>"
    }
    
    
    /**
     Returns a string representation of a given `LogSeverity` value.
     
     This implementation is used by the `DefaultLogFormatter` for creating
     string representations for representing the `severity` value of
     `LogEntry` instances.
     
     :param:     severity The `LogSeverity` for which a string representation
     is desired.
     
     :returns:   A string representation of the `severity` value.
     */
    private static func stringRepresentation(string: String, lenght: Int, right: Bool = true) -> String
    {
        if(lenght > 0) {
            var str = string
            if(str.characters.count < lenght)
            {
                while str.characters.count < lenght {
                    if right==true {
                        str = str + " "
                    } else {
                        str = " " + str
                    }
                }
            } else {
                let index: String.Index = string.startIndex.advancedBy(lenght)
                str = string.substringToIndex(index)
            }
        }
        return string
    }
    
    /**
     Returns a string representation of a given `LogSeverity` value.
     
     This implementation is used by the `DefaultLogFormatter` for creating
     string representations for representing the `severity` value of
     `LogEntry` instances.
     
     :param:     severity The `LogSeverity` for which a string representation
     is desired.
     
     :returns:   A string representation of the `severity` value.
     */
    public func stringRepresentationOfSeverity(severity: LogLevel) -> String
    {
        return BaseLogFormatter.stringRepresentation(severity.description, lenght:severityTagLenght, right:false)
    }
    
    /**
     Returns a string representation of a given `LogSeverity` value.
     
     This implementation is used by the `DefaultLogFormatter` for creating
     string representations for representing the `severity` value of
     `LogEntry` instances.
     
     :param:     severity The `LogSeverity` for which a string representation
     is desired.
     
     :returns:   A string representation of the `severity` value.
     */
    public func stringRepresentationOfIdentity(identity: String) -> String
    {
        return BaseLogFormatter.stringRepresentation(identity, lenght:severityTagLenght, right:false)
    }

    /**
    Returns a string representation of an `NSDate` timestamp.

    This implementation is used by the `DefaultLogFormatter` for creating
    string representations of a `LogEntry`'s `timestamp` property.

    :param:     timestamp The timestamp.
    
    :returns:   The string representation of `timestamp`.
    */
    public func stringRepresentationOfTimestamp(timestamp: NSDate) -> String
    {
        return dateFormatter.stringFromDate(timestamp)
    }

    /**
    Returns a string representation of a thread identifier.

    This implementation is used by the `DefaultLogFormatter` for creating
    string representations of a `LogEntry`'s `callingThreadID` property.

    :param:     threadID The thread identifier.
    
    :returns:   The string representation of `threadID`.
    */
    public static func stringRepresentationOfThreadID(threadID: UInt64) -> String
    {
        return NSString(format: "%08X", threadID) as String
    }
}
