/**
 * @name            LogLevel.swift
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

private let AllString: String = "All"
private let VerboseString: String = "Verbose"
private let DebugString: String = "Debug"
private let InfoString: String = "Info"
private let WarningString: String = "Warning"
private let ErrorString: String = "Error"
private let SevereString: String = "Severe"
private let EventString: String = "Event"
private let OffString: String = "OFF"

// MARK: - Enums
public enum LogLevel: Int, Comparable, CustomStringConvertible {

    /** The lowest severity, used for detailed or frequently occurring
     debugging and diagnostic information. Not intended for use in production
     code. */
    case all    = 0
    
    /** The lowest severity, used for detailed or frequently occurring
     debugging and diagnostic information. Not intended for use in production
     code. */
    case verbose    = 1
    
    /** Used for debugging and diagnostic information. Not intended for use
     in production code. */
    case debug      = 2
    
    /** Used to indicate something of interest that is not problematic. */
    case info       = 3
    
    /** Used to indicate that something appears amiss and potentially
     problematic. The situation bears looking into before a larger problem
     arises. */
    case warning    = 4
    
    /** The highest severity, used to indicate that something has gone wrong;
     a fatal error may be imminent. */
    case error      = 5
    
    case severe     = 6
    
    case event      = 7

    /** turn OFF all logging (children can override) */
    case off        = 8
    
    public init(level: String = InfoString) {
        if(AllString.caseInsensitiveCompare(level) == ComparisonResult.orderedSame) {
            self = .all
        } else if(VerboseString.caseInsensitiveCompare(level) == ComparisonResult.orderedSame) {
            self = .verbose
        } else if(DebugString.caseInsensitiveCompare(level) == ComparisonResult.orderedSame) {
            self = .debug
        } else if(InfoString.caseInsensitiveCompare(level) == ComparisonResult.orderedSame) {
            self = .info
        } else if(WarningString.caseInsensitiveCompare(level) == ComparisonResult.orderedSame) {
            self = .warning
        } else if(ErrorString.caseInsensitiveCompare(level) == ComparisonResult.orderedSame) {
            self = .error
        } else if(SevereString.caseInsensitiveCompare(level) == ComparisonResult.orderedSame) {
            self = .severe
        } else if(EventString.caseInsensitiveCompare(level) == ComparisonResult.orderedSame) {
            self = .event
        } else {
            self = .off
        }
    }
    
    public var description: String {
        switch self {
        case .all:
            return AllString
        case .verbose:
            return VerboseString
        case .debug:
            return DebugString
        case .info:
            return InfoString
        case .warning:
            return WarningString
        case .error:
            return ErrorString
        case .severe:
            return SevereString
        case .event:
            return EventString
        case .off:
            return OffString
        }
    }
    
    public static let allLevels: [LogLevel] = [.verbose, .debug, .info, .warning, .error, .severe, .event]
}

public func <(lhs: LogLevel, rhs: LogLevel) -> Bool {
    return lhs.rawValue < rhs.rawValue
}
