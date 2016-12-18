/**
 * @name            LogConfiguration.swift
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

struct LogConfigurationConstants {
    static let Appenders: String = "appenders"
    static let Level: String = "level"
    static let Synchronous: String = "synchronous"
    static let Additivity: String = "additivity"
}

/**
Defines an interface for specifying the configuration of the logging system.
*/
public protocol LogConfiguration: CustomDebugStringConvertible
{
    var identifier: String { get }
    
    var additivity: Bool { get }
    
    /** The minimum `LogSeverity` supported by the configuration. */
    var assignedLevel: LogLevel? { get }
    
    /** The minimum `LogSeverity` supported by the configuration. */
    var effectiveLevel: LogLevel { get }
    
    /** The list of `LogAppender`s to be used. */
    var appenders: [LogAppender]  { get }
    
    /** A flag indicating when synchronous mode should be used for the
     configuration. */
    var synchronousMode: Bool  { get }
    
    var parent: LogConfiguration? { get }
    
    var children: [LogConfiguration] { get }
    
    func addChildren(_ child: LogConfiguration, copyGrandChildren:Bool)
    
    func getChildren(_ name: String) -> LogConfiguration?
    
    func fullName() -> String
    
    func details() -> String
    
    func setParent(_ parent: LogConfiguration)
}
