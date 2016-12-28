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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


struct PatternLogFormatterConstants {
    static let Pattern = "pattern"
}

/**
The `PatternLogFormatter` is a basic implementation of the `LogFormatter`
protocol.

This implementation is used by default if no other log formatters are specified.
*/
open class PatternLogFormatter: BaseLogFormatter
{

    open static let defaultLogFormat: String = "%.30d [%thread] %-7p %-20.-20c - %m"
    
    open static let lenghtPattern:String = "([-]?\\d{1,2}[.][-]?\\d{1,2}|[.][-]?\\d{1,2}|[-]?\\d{1,2})"
    
    open static let MDC: String = "%" + lenghtPattern + "?" + "(X)"
    open static let identifier: String = "%" + lenghtPattern + "?" + "(logger|lo|c)"
    open static let level: String = "%" + lenghtPattern + "?" + "(level|le|p)"
    open static let date: String = "%" + lenghtPattern + "?" + "(date|d)"
    open static let message: String = "%" + lenghtPattern + "?" + "(message|msg|m)"
    
    open static let tread: String = "%" + lenghtPattern + "?" + "(thread|t)"
    
    open static let caller: String = "%" + lenghtPattern + "?" + "(Caller)"
    open static let function: String = "%" + lenghtPattern + "?" + "(M|Method)"
    open static let file: String = "%" + lenghtPattern + "?" + "(F|file)"
    open static let line: String = "%" + lenghtPattern + "?" + "(L|line)"
    
    open static let lineSeparator: String = "%n"

    open static let grouping: String = "%" + lenghtPattern + "[(].{1,}[)]"

    
    fileprivate static let patterns: [String] = [MDC,identifier,level,date,message,tread,caller,function,file,line,lineSeparator]
    //private static let patterns: [String] = [date]
    
    fileprivate var pattern: String
    
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
    
    public required convenience init?(configuration: Dictionary<String, Any>) {
        
        guard let pattern = configuration[PatternLogFormatterConstants.Pattern] as?  String  else {
            return nil
        }
        self.init(logFormat: pattern)
    }
    
    /**
     Returns a formatted representation of the given `LogEntry`.
     
     :param:         entry The `LogEntry` being formatted.
     
     :returns:       The formatted representation of `entry`. This particular
     implementation will never return `nil`.
     */
    override open func formatLogEntry(_ entry: LogEntry, message: String) -> String {
        var resultString = pattern
        if let regex = try? NSRegularExpression(pattern: PatternLogFormatter.grouping, options: [])
        {
            let matches = regex.matches(in: resultString, options:[], range: NSMakeRange(0, resultString.characters.count))
            for match in matches {
                let content = (resultString as NSString).substring(with: match.range)
                let range = content.range(of: "(")!
                let replacementRange = content.index(after: range.lowerBound)..<content.index(before: content.endIndex)
                
                var subPattern = content[replacementRange]
                subPattern = patternReplacement(entry, message: message, pattern: subPattern)
                subPattern = formatSpecifiers(content, replacement: subPattern)
                resultString = (resultString as NSString).replacingCharacters(in: match.range, with: subPattern)
            }
        }
        return patternReplacement(entry, message: message, pattern: resultString)
    }
    
    open func formatSpecifiers(_ expression: String, replacement:String) -> String {
        var newReplacement = replacement
        if let regex = try? NSRegularExpression(pattern: PatternLogFormatter.lenghtPattern, options: [])
        {
            let matches = regex.matches(in: expression, options:[], range: NSMakeRange(0, expression.characters.count))
            if(matches.count > 0) {
                var min:Int?
                var max:Int?
                let specifier = (expression as NSString).substring(with: matches[0].range)
                let values = specifier.components(separatedBy: ".")
                if(values.count == 1) {
                    if(specifier.contains(".")) {
                        max = Int(values[0])
                    } else {
                        min = Int(values[0])
                    }
                } else if(values.count == 2) {
                    min = Int(values[0])
                    max = Int(values[1])
                }
                if let minLenght = min, newReplacement.characters.count < abs(minLenght) {
                    let diff = abs(minLenght) - newReplacement.characters.count
                    for _ in 1...diff {
                        (minLenght < 0 ? newReplacement+=" " : newReplacement.insert(" ", at: newReplacement.startIndex))
                    }
                }
                if let maxLenght = max, newReplacement.characters.count > max {
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
    
    open func patternReplacement(_ entry: LogEntry, message: String, pattern:String) -> String {
        var offset:Int = 0
        var orderMatches:[Int:NSTextCheckingResult] = [:]
        var details: String = pattern
        for pat in PatternLogFormatter.patterns
        {
            if let regex = try? NSRegularExpression(pattern: pat, options: [])
            {
                let matches = regex.matches(in: details, options:[], range: NSMakeRange(0, pattern.characters.count))
                for match in matches {
                    orderMatches[match.range.location] = match
                }
            }
        }
        
        let sortedKeys = Array(orderMatches.keys).sorted(by: { $0 < $1 })
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
                    replacement = message
                case PatternLogFormatter.tread:
                    var threadID: UInt64 = 0
                    pthread_threadid_np(nil, &threadID)
                    replacement = String(threadID)
                case PatternLogFormatter.caller:
                    replacement = String(entry.callingThreadID)
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
            
            let expresion = (details as NSString).substring(with: range)
            replacement = formatSpecifiers(expresion, replacement: replacement)
            
            details = (details as NSString).replacingCharacters(in: range, with: replacement)
            offset += (replacement.characters.count - range.length)
        }
        return details
    }
    
    
    open static func getCaller(_ entry: LogEntry) -> String {
        var caller: String = ""
        caller += "\(entry.callingFunction)"
        caller += "(\(entry.callingFileLine):"
        caller += "\(entry.callingFileLine))"
        return caller
    }
}

extension String {
    func trunc(_ length: Int, trailing: String? = nil, end:Bool = true) -> String {
        if self.characters.count > length {
            if end {
                return self.substring(to: self.characters.index(self.startIndex, offsetBy: length)) + (trailing ?? "")
            } else {
                return self.substring(from: self.characters.index(self.startIndex, offsetBy: self.characters.count - length))
            }
        } else {
            return self
        }
    }
}
