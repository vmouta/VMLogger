/**
 * @name            LogLevelFilter.swift
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

struct ValueTypeFilterConstants {
    static let Types: String = "types"
}

/**
A `LogFilter` implementation that filters out any `LogEntry` with a 
`LogSeverity` less than a specified value.
*/
open class ValueTypeFilter: LogFilter
{
    /** Returns the `LogSeverity` associated with the receiver. */
    open let types: [String]

    /**
    Initializes a new `LogSeverityFilter` instance.
    
    :param:     severity Specifies the `LogSeverity` that the filter will
                use to determine whether a given `LogEntry` should be
                recorded. Only those log entries with a severity equal to
                or more severe than this value will pass through the filter.
    */
    public init(types: [String])
    {
        self.types = types
    }

    /**
    Called to determine whether the given `LogEntry` should be recorded.

    :param:     entry The `LogEntry` to be evaluated by the filter.

    :returns:   `true` if `entry.severity` is as or more severe than the
                receiver's `severity` property; `false` otherwise.
    */
    open func shouldRecordLogEntry(_ entry: LogEntry) -> Bool
    {
        switch (entry.payload) {
        case .value(let object):
            if object != nil {
                _ = String(describing: type(of: object!)).components(separatedBy: "__").last!
                let typeName = String(describing: type(of: object!))
                return self.types.contains(typeName)
            } else {
                return false
            }
        default:
            return false
        }
    }
    
    /**
     constructor to be used by introspection
     
     - parameter configuration: configuration for the appender
     
     - returns: if configuration is correct a new LogFilter
     */
    public required convenience init?(configuration: Dictionary<String, Any>) {
        if let types = configuration[ValueTypeFilterConstants.Types] as? [String] {
            self.init(types:types)
        } else {
            return nil
        }
    }
    
    // MARK: - CustomDebugStringConvertible
    open var debugDescription: String {
        get {
            return "\(Mirror(reflecting: self).subjectType): \(types)"
        }
    }
}
