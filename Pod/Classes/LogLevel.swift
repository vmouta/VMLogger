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
    
    public var description: String {
        switch self {
        case .All:
            return "ALL"
        case .Verbose:
            return "Verbose"
        case .Debug:
            return "Debug"
        case .Info:
            return "Info"
        case .Warning:
            return "Warning"
        case .Error:
            return "Error"
        case .Severe:
            return "Severe"
        case .Off:
            return "OFF"
        }
    }
}

public func <(lhs: LogLevel, rhs: LogLevel) -> Bool {
    return lhs.rawValue < rhs.rawValue
}