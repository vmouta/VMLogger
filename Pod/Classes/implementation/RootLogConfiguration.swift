/**
 * @name            RootLogConfiguration.swift
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
open class RootLogConfiguration: BaseLogConfiguration
{
    public required convenience init(assignedLevel: LogLevel = .info, appenders: [LogAppender] = [ConsoleLogAppender()], synchronousMode: Bool = false) {
        self.init(identifier: RootLogConfiguration.ROOT_IDENTIFIER, assignedLevel: assignedLevel, parent: nil, appenders: appenders, synchronousMode: synchronousMode, additivity: false)
    }
    
    fileprivate init(identifier: String, assignedLevel: LogLevel = .info, parent: LogConfiguration?, appenders: [LogAppender], synchronousMode: Bool = false, additivity: Bool = true) {
        super.init(identifier, assignedLevel:assignedLevel, parent:parent, appenders:appenders, synchronousMode:synchronousMode, additivity:additivity)
    } 
}
