/**
 * @name             BaseLogConfiguration.swift
 * @partof           zucred AG
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
public class BaseLogConfiguration: LogConfiguration
{
    public static let ROOT_IDENTIFIER: String = "root"
    public static let DOT: String = "."
    
    public let identifier: String

    public let additivity: Bool
    
    /** The assigned `LogLevel` supported by the configuration. */
    public var assignedLevel: LogLevel?
    
    /** The minimum `LogLevel` supported by the configuration. */
    public var effectiveLevel: LogLevel

    /** The list of `LogRecorder`s to be used for recording messages to the 
    underlying logging facility. */
    public let appenders: [LogAppender]

    /** A flag indicating when synchronous mode should be used for the
    configuration. */
    public let synchronousMode: Bool
    
    public var parent: LogConfiguration?
    
    public lazy var children: [LogConfiguration] = []
    
    public convenience init(identifier: String, parent: LogConfiguration, appenders: [LogAppender] = [], filters: [LogFilter] = [], synchronousMode: Bool = false, additivity: Bool = true)
    {
        self.init(identifier: identifier, effectiveLevel: parent.effectiveLevel, parent: parent, appenders: appenders, filters: filters, synchronousMode: synchronousMode, additivity: additivity)
    }
    
    public convenience init(identifier: String, assignedLevel: LogLevel = .Info, parent: LogConfiguration, appenders: [LogAppender], filters: [LogFilter] = [], synchronousMode: Bool = false, additivity: Bool = true)
    {
        self.init(identifier: identifier, effectiveLevel: parent.effectiveLevel, parent: parent, appenders: appenders, filters: filters, synchronousMode: synchronousMode, additivity: additivity)
        self.assignedLevel = assignedLevel
    }
    
    /**
    A `DefaultLogConfiguration` initializer that uses the specified 
    `LogRecorder`s (and *does not* include the use of the `ASLLogRecorder` 
    unless explicitly specified).
    
    :param:     identifier
    
    :param:     recorders A list of `LogRecorder`s to be used for recording
                log messages.

    :param:     minimumSeverity The minimum `LogSeverity` supported by the
                configuration.
    
    :param:     filters A list of `LogFilter`s to be used for filtering log
                messages.
    
    :param:     formatters A list of `LogFormatter`s to be used for formatting
                log messages.

    :param:     synchronousMode Determines whether synchronous mode logging
                will be used. **Use of synchronous mode is not recommended in
                production code**; it is provided for use during debugging, to
                help ensure that messages send prior to hitting a breakpoint
                will appear in the console when the breakpoint is hit.
     
    :param:     additivity
    */
    internal init(identifier: String, effectiveLevel: LogLevel = .Info, parent: LogConfiguration?, appenders: [LogAppender], filters: [LogFilter] = [], synchronousMode: Bool = false, additivity: Bool = true)
    {
        self.identifier = identifier
        self.effectiveLevel = effectiveLevel
        self.appenders = appenders
        self.synchronousMode = synchronousMode
        self.additivity = additivity
        self.parent = parent
    }
    
    internal func isRootLogger() ->Bool {
        // only the root logger has a null parent
        return parent == nil;
    }
    
    public func addChildren(child: LogConfiguration)
    {
        self.children.append(child)
    }
    
    public func getChildren(name: String) -> LogConfiguration?
    {
        return self.children.filter{ $0.identifier == name }.first
    }
    
    public func fullName() -> String
    {
        var name: String
        if let parent = self.parent where self.parent?.identifier != BaseLogConfiguration.ROOT_IDENTIFIER {
            name = parent.fullName() + BaseLogConfiguration.DOT + self.identifier
        } else {
            name = self.identifier
        }
        return name
    }
    
    public func details() -> String
    {
        var details: String = "\n"
        if let assigned = self.assignedLevel {
            details += assigned.description + " - " + self.effectiveLevel.description + " - " + self.fullName()
        } else {
            details += "nil - " + self.effectiveLevel.description + " - " + self.fullName()
        }
    
        for child in self.children {
            details += child.details()
        }
        return details
    }

    // MARK: - DebugPrintabl
    public var debugDescription: String {
        get {
            let description: String = "\(Mirror(reflecting:self).subjectType): [\(assignedLevel)-\(effectiveLevel)][\(additivity)] \(identifier) - \r"
            return description
        }
    }
}
