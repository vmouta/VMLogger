/**
 * @name            DefaultRootLogConfiguration.swift
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
`DefaultLogConfiguration` is the implementation of the `LogConfiguration`
protocol used by default if no other is provided.

The `DefaultLogConfiguration` uses the `ASLLogRecorder` to write to the Apple
System Log as well as the `stderr` console.

Additional optional `LogRecorders` may be specified to record messages to
other arbitrary types of data stores, such as files or HTTP endpoints.
*/
class RootLogConfiguration: BaseLogConfiguration
{
    init() {
        super.init(identifier: RootLogConfiguration.ROOT_IDENTIFIER, effectiveLevel:.Info, parent:nil, appenders: [ConsoleLogAppender()], additivity: false)
    }
    
    init(assignedLevel: LogLevel = .Info, appenders: [LogAppender], filters: [LogFilter] = [], synchronousMode: Bool = false)
    {
        super.init(identifier: RootLogConfiguration.ROOT_IDENTIFIER, effectiveLevel: assignedLevel, parent: nil, appenders: appenders, filters: filters, synchronousMode: synchronousMode, additivity: false)
    }
}
