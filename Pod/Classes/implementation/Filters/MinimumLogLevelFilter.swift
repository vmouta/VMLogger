/**
 * @name            MinimumLogLevelFilter.swift
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
A `LogFilter` implementation that filters out any `LogEntry` with a 
`LogSeverity` less than a specified value.
*/
open class MinimumLogLevelFilter: LogLevelFilter
{
    /**
    Called to determine whether the given `LogEntry` should be recorded.

    :param:     entry The `LogEntry` to be evaluated by the filter.

    :returns:   `true` if `entry.severity` is as or more severe than the
                receiver's `severity` property; `false` otherwise.
    */
    open override func shouldRecordLogEntry(_ entry: LogEntry) -> Bool
    {
        return entry.logLevel >= severity
    }
}
