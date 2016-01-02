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
private let OffString: String = "OFF"

// MARK: - Enums
public enum LogLevel: Int, Comparable, CustomStringConvertible {

    /** The lowest severity, used for detailed or frequently occurring
     debugging and diagnostic information. Not intended for use in production
     code. */
    case All    = 0
    
    /** The lowest severity, used for detailed or frequently occurring
     debugging and diagnostic information. Not intended for use in production
     code. */
    case Verbose    = 1
    
    /** Used for debugging and diagnostic information. Not intended for use
     in production code. */
    case Debug      = 2
    
    /** Used to indicate something of interest that is not problematic. */
    case Info       = 3
    
    /** Used to indicate that something appears amiss and potentially
     problematic. The situation bears looking into before a larger problem
     arises. */
    case Warning    = 4
    
    /** The highest severity, used to indicate that something has gone wrong;
     a fatal error may be imminent. */
    case Error      = 5
    
    case Severe     = 6

    /** turn OFF all logging (children can override) */
    case Off        = 7
    
    public init(level: String = InfoString) {
        if(AllString.caseInsensitiveCompare(level) == NSComparisonResult.OrderedSame) {
            self = .All
        } else if(VerboseString.caseInsensitiveCompare(level) == NSComparisonResult.OrderedSame) {
            self = .Verbose
        } else if(DebugString.caseInsensitiveCompare(level) == NSComparisonResult.OrderedSame) {
            self = .Debug
        } else if(InfoString.caseInsensitiveCompare(level) == NSComparisonResult.OrderedSame) {
            self = .Info
        } else if(WarningString.caseInsensitiveCompare(level) == NSComparisonResult.OrderedSame) {
            self = .Warning
        } else if(ErrorString.caseInsensitiveCompare(level) == NSComparisonResult.OrderedSame) {
            self = .Error
        } else if(SevereString.caseInsensitiveCompare(level) == NSComparisonResult.OrderedSame) {
            self = .Severe
        } else {
            self = .Off
        }
    }
    
    public var description: String {
        switch self {
        case .All:
            return AllString
        case .Verbose:
            return VerboseString
        case .Debug:
            return DebugString
        case .Info:
            return InfoString
        case .Warning:
            return WarningString
        case .Error:
            return ErrorString
        case .Severe:
            return SevereString
        case .Off:
            return OffString
        }
    }
}

public func <(lhs: LogLevel, rhs: LogLevel) -> Bool {
    return lhs.rawValue < rhs.rawValue
}