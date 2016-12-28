/**
 * @name            LogFormatter.swift
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

struct LogFormatterConstants {
    static let Class: String = "class"
}

/**
`LogFormatter`s are used to attempt to create string representations of
`LogEntry` instances.
*/
public protocol LogFormatter: CustomDebugStringConvertible
{
    /**
    Called to create a string representation of the passed-in `LogEntry`.
    
    :param:     entry The `LogEntry` to attempt to convert into a string.
    
    :returns:   A `String` representation of `entry`, or `nil` if the
                receiver could not format the `LogEntry`.
    */
    func formatLogEntry(_ entry: LogEntry, message: String) -> String?
    
    /**
     constructor to be used by introspection
     
     - parameter configuration: configuration for the formatter
     
     - returns: if configuration is correct a new LogFormatter
     */
    init?(configuration: Dictionary<String, Any>)
}
