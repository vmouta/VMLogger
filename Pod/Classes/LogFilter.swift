/**
 * @name            LogFilter.swift
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

struct LogFilterConstants {
    static let Class: String = "class"
}

/**
Before a `LogEntry` is recorded, any `LogFilter`s specified in the active
`LogConfiguration` are given a chance to prevent the entry from being recorded
by returning `false` from the `shouldRecordLogEntry()` function.
*/
public protocol LogFilter : CustomDebugStringConvertible
{
    /**
    Called to determine whether the given `LogEntry` should be recorded.

    :param:     entry The `LogEntry` to be evaluated by the filter.
    
    :returns:   `true` if `entry` should be recorded, `false` if not.
    */
    func shouldRecordLogEntry(_ entry: LogEntry) -> Bool
    
    /**
     constructor to be used by introspection
     
     - parameter configuration: configuration for the filter
     
     - returns: if configuration is correct a new LogFilter
     */
    init?(configuration: Dictionary<String, Any>)
}
