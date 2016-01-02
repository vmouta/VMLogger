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

struct PatternLogFormatterConstants {
    static let Pattern = "pattern"
}

/**
The `PatternLogFormatter` is a basic implementation of the `LogFormatter`
protocol.

This implementation is used by default if no other log formatters are specified.
*/
public class PatternLogFormatter: BaseLogFormatter
{

    public static let defaultLogFormat: String = "%.30d [%thread] %-7p %-20.-20c - %m"
    
    public static let lenghtPattern:String = "([-]?\\d{1,2}[.][-]?\\d{1,2}|[.][-]?\\d{1,2}|[-]?\\d{1,2})"
    
    public static let MDC: String = "%" + lenghtPattern + "?" + "(X)"
    public static let identifier: String = "%" + lenghtPattern + "?" + "(logger|lo|c)"
    public static let level: String = "%" + lenghtPattern + "?" + "(level|le|p)"
    public static let date: String = "%" + lenghtPattern + "?" + "(date|d)"
    public static let message: String = "%" + lenghtPattern + "?" + "(message|msg|m)"
    
    public static let tread: String = "%" + lenghtPattern + "?" + "(thread|t)"
    
    public static let caller: String = "%" + lenghtPattern + "?" + "(Caller)"
    public static let function: String = "%" + lenghtPattern + "?" + "(M|Method)"
    public static let file: String = "%" + lenghtPattern + "?" + "(F|file)"
    public static let line: String = "%" + lenghtPattern + "?" + "(L|line)"
    
    public static let lineSeparator: String = "%n"

    public static let grouping: String = "%" + lenghtPattern + "[(].{1,}[)]"

    
    private static let patterns: [String] = [MDC,identifier,level,date,message,tread,caller,function,file,line,lineSeparator]
    //private static let patterns: [String] = [date]
    
    private var pattern: String
    
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
    }
    
    /**
     Returns a formatted representation of the given `LogEntry`.
     
     :param:         entry The `LogEntry` being formatted.
     
     :returns:       The formatted representation of `entry`. This particular
     implementation will never return `nil`.
     */
    override public func formatLogEntry(entry: LogEntry) -> String {
        var resultString = pattern
        if let regex = try? NSRegularExpression(pattern: PatternLogFormatter.grouping, options: [])
        {
            let matches = regex.matchesInString(resultString, options:[], range: NSMakeRange(0, resultString.characters.count))
            for match in matches {
                let content = (resultString as NSString).substringWithRange(match.range)
                let range = content.rangeOfString("(")!
                let replacementRange = range.startIndex.successor()..<content.endIndex.predecessor()
                var subPattern = content[replacementRange]
                subPattern = patternReplacement(entry, pattern: subPattern)
                subPattern = formatSpecifiers(content, replacement: subPattern)
                resultString = (resultString as NSString).stringByReplacingCharactersInRange(match.range, withString: subPattern)
            }
        }
        return patternReplacement(entry, pattern: resultString)
    }
    
    public func formatSpecifiers(expression: String, replacement:String) -> String {
        var newReplacement = replacement
        if let regex = try? NSRegularExpression(pattern: PatternLogFormatter.lenghtPattern, options: [])
        {
            let matches = regex.matchesInString(expression, options:[], range: NSMakeRange(0, expression.characters.count))
            if(matches.count > 0) {
                var min:Int?
                var max:Int?
                let specifier = (expression as NSString).substringWithRange(matches[0].range)
                let values = specifier.componentsSeparatedByString(".")
                if(values.count == 1) {
                    if(specifier.containsString(".")) {
                        max = Int(values[0])
                    } else {
                        min = Int(values[0])
                    }
                } else if(values.count == 2) {
                    min = Int(values[0])
                    max = Int(values[1])
                }
                if let minLenght = min where newReplacement.characters.count < abs(minLenght) {
                    let diff = abs(minLenght) - newReplacement.characters.count
                    for _ in 1...diff {
                        (minLenght < 0 ? newReplacement+=" " : newReplacement.insert(" ", atIndex: newReplacement.startIndex))
                    }
                }
                if let maxLenght = max where newReplacement.characters.count > max {
                    if(maxLenght < 0) {
                        newReplacement = newReplacement.trunc(abs(maxLenght))
                    } else {
                        newReplacement = newReplacement.trunc(maxLenght, end: false)
                    }
                }
            }
        }
        return newReplacement
    }
    
    public func patternReplacement(entry: LogEntry, pattern:String) -> String {
        var offset:Int = 0
        var orderMatches:[Int:NSTextCheckingResult] = [:]
        var details: String = pattern
        for pat in PatternLogFormatter.patterns
        {
            if let regex = try? NSRegularExpression(pattern: pat, options: [])
            {
                let matches = regex.matchesInString(details, options:[], range: NSMakeRange(0, pattern.characters.count))
                for match in matches {
                    orderMatches[match.range.location] = match
                }
            }
        }
        
        let sortedKeys = Array(orderMatches.keys).sort({ $0 < $1 })
        for key in sortedKeys {
            let patternExpresion = orderMatches[key]!.regularExpression!.pattern
            let range = orderMatches[key]!.resultByAdjustingRangesWithOffset(offset).range
            var replacement:String = ""
            switch(patternExpresion) {
                case PatternLogFormatter.MDC:
                    replacement = BaseLogFormatter.stringRepresentationForMDC()
                case PatternLogFormatter.identifier:
                   replacement = stringRepresentationOfIdentity(entry.logger.identifier)
                case PatternLogFormatter.level:
                    replacement = stringRepresentationOfSeverity(entry.logLevel)
                case PatternLogFormatter.date:
                    replacement = stringRepresentationOfTimestamp(entry.timestamp)
                case PatternLogFormatter.message:
                    replacement = BaseLogFormatter.stringRepresentationForPayload(entry)
                case PatternLogFormatter.tread:
                    replacement = String(entry.callingThreadID)
                case PatternLogFormatter.caller:
                    replacement = ""
                case PatternLogFormatter.function:
                    replacement = entry.callingFunction
                case PatternLogFormatter.file:
                    replacement = BaseLogFormatter.stringRepresentationForFile(entry.callingFilePath)
                case PatternLogFormatter.line:
                    replacement = String(entry.callingFileLine)
                case PatternLogFormatter.lineSeparator:
                    replacement = "\n"
                    break
                default:
                break
            }
            
            let expresion = (details as NSString).substringWithRange(range)
            replacement = formatSpecifiers(expresion, replacement: replacement)
            
            details = (details as NSString).stringByReplacingCharactersInRange(range, withString: replacement)
            offset += (replacement.characters.count - range.length)
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

extension String {
    func trunc(length: Int, trailing: String? = nil, end:Bool = true) -> String {
        if self.characters.count > length {
            if end {
                return self.substringToIndex(self.startIndex.advancedBy(length)) + (trailing ?? "")
            } else {
                return self.substringFromIndex(self.startIndex.advancedBy(self.characters.count - length))
            }
        } else {
            return self
        }
    }
}
