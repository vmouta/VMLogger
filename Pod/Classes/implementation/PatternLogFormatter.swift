/**
 * @name            PatternLogFormatter.swift
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
The `PatternLogFormatter` is a basic implementation of the `LogFormatter`
protocol.

This implementation is used by default if no other log formatters are specified.
*/
public class PatternLogFormatter: BaseLogFormatter
{

    public static let defaultLogFormat: String = "%d [%thread] %p %c - %m%n"
    /*
    public static let MDC: [String] = ["X"]
    public static let identifier: [String] = ["c", "lo", "logger"]
    public static let level: [String] = ["p", "le", "level"]
    public static let labelDate: [String] = ["d", "date"]
    public static let labelMessage: [String] = ["m", "msg", "message"]
    
    public static let tread: [String] = ["t", "thread"]

    public static let caller: [String] = ["caller"]
    public static let function: [String] = ["M", "method"]
    public static let file: [String] = ["F", "file"]
    public static let line: [String] = ["L", "line"]

    public let lineSeparator: [String] = ["n"]
    */
    
    public static let MDC: String = "(%X)"
    public static let identifier: String = "(%c|%lo|%logger)"
    public static let level: String = "(%p|%le|%level)"
    public static let date: String = "(%d|%date)"
    public static let message: String = "(%m|%msg|%message)"
    
    public static let tread: String = "(%t|%thread)"
    
    public static let caller: String = "(%caller)"
    public static let function: String = "(%M|%method)"
    public static let file: String = "(%F|%file)"
    public static let line: String = "(%L|%line)"
    
    public static let lineSeparator: String = "(%n)" 

    private static let patterns: [String] = [MDC,identifier,level,date,message,tread,caller,function,file,line]
    
    
    private var pattern: String
    private var patternLenght: Int
    
    /**
     Initializes the DefaultLogFormatter using the given settings.
     
     :param:     includeTimestamp If `true`, the log entry timestamp will be
     included in the formatted message.
     
     :param:     includeThreadID If `true`, an identifier for the calling thread
     will be included in the formatted message.
     */
    public init(logFormat: String = defaultLogFormat)
    {
        self.pattern = logFormat
        self.patternLenght = pattern.characters.count
    }
    
    /**
     Returns a formatted representation of the given `LogEntry`.
     
     :param:         entry The `LogEntry` being formatted.
     
     :returns:       The formatted representation of `entry`. This particular
     implementation will never return `nil`.
     */
    override public func formatLogEntry(entry: LogEntry) -> String? {
        var orderMatches:[Int:NSTextCheckingResult] = [:]
        var details: String = pattern
        for pat in PatternLogFormatter.patterns
        {
            if let regex = try? NSRegularExpression(pattern: pat, options: NSRegularExpressionOptions.CaseInsensitive)
            {
                let matches = regex.matchesInString(details, options:[], range: NSMakeRange(0, patternLenght))
                for match in matches {
                    orderMatches[match.range.location] = match
                }
            }
        }
        
        let sortedKeys = Array(orderMatches.keys).sort({ $0 < $1 })
        for key in sortedKeys {
            let expresion = orderMatches[key]!.regularExpression!.pattern
            let range = orderMatches[key]!.range
            switch(expresion) {
                case PatternLogFormatter.MDC:
                    details = (details as NSString).stringByReplacingCharactersInRange(range, withString: BaseLogFormatter.stringRepresentationForMDC())
                case PatternLogFormatter.identifier:
                    details = (details as NSString).stringByReplacingCharactersInRange(range, withString: stringRepresentationOfIdentity(entry.logger.identifier))
                case PatternLogFormatter.level:
                    details = (details as NSString).stringByReplacingCharactersInRange(range, withString: stringRepresentationOfSeverity(entry.logLevel))
                case PatternLogFormatter.date:
                    details = (details as NSString).stringByReplacingCharactersInRange(range, withString: stringRepresentationOfTimestamp(entry.timestamp))
                case PatternLogFormatter.message:
                    details = (details as NSString).stringByReplacingCharactersInRange(range, withString: BaseLogFormatter.stringRepresentationForPayload(entry))
                case PatternLogFormatter.tread:
                    details = (details as NSString).stringByReplacingCharactersInRange(range, withString: String(entry.callingThreadID))
                case PatternLogFormatter.caller:
                    details = (details as NSString).stringByReplacingCharactersInRange(range, withString: "")
                case PatternLogFormatter.function:
                    details = (details as NSString).stringByReplacingCharactersInRange(range, withString: entry.callingFunction)
                case PatternLogFormatter.file:
                    details = (details as NSString).stringByReplacingCharactersInRange(range, withString: BaseLogFormatter.stringRepresentationForFile(entry.callingFilePath))
                case PatternLogFormatter.line:
                    details = (details as NSString).stringByReplacingCharactersInRange(range, withString: String(entry.callingFileLine))
                case PatternLogFormatter.lineSeparator:
                    details = (details as NSString).stringByReplacingCharactersInRange(range, withString: "\n")
                    break
                default:
                break
            }
        }
        return details
    }
    
    public static func getCaller(entry: LogEntry) -> String {
        var caller: String = ""
        caller += "\(entry.callingFunction)"
        caller += "(\(entry.callingFileLine):"
        caller += "\(entry.callingFileLine))"
        return caller
    }
}
