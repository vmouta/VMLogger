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
open class BaseLogConfiguration: LogConfiguration
{
    open static let ROOT_IDENTIFIER: String = "root"
    open static let DOT: String = "."
    
    open let identifier: String

    open let additivity: Bool
    
    /** The assigned `LogLevel` supported by the configuration. */
    open var assignedLevel: LogLevel?
    
    /** The minimum `LogLevel` supported by the configuration. */
    open var effectiveLevel: LogLevel

    /** The list of `LogRecorder`s to be used for recording messages to the 
    underlying logging facility. */
    open let appenders: [LogAppender]

    /** A flag indicating when synchronous mode should be used for the
    configuration. */
    open let synchronousMode: Bool
    
    open var parent: LogConfiguration?
    
    open var children: [LogConfiguration] {
        return Array(childrenDic.values)
    }
    
    internal var childrenDic: [String : LogConfiguration] = [:]
    
    public convenience init(_ identifier: String, parent: LogConfiguration, appenders: [LogAppender] = [], synchronousMode: Bool = false, additivity: Bool = true)
    {
        self.init(identifier, assignedLevel: nil, parent: parent, appenders: appenders, synchronousMode: synchronousMode, additivity: additivity)
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
    
    :param:     formatters A list of `LogFormatter`s to be used for formatting
                log messages.

    :param:     synchronousMode Determines whether synchronous mode logging
                will be used. **Use of synchronous mode is not recommended in
                production code**; it is provided for use during debugging, to
                help ensure that messages send prior to hitting a breakpoint
                will appear in the console when the breakpoint is hit.
     
    :param:     additivity
    */
    public init(_ identifier: String, assignedLevel: LogLevel?, parent: LogConfiguration?, appenders: [LogAppender], synchronousMode: Bool = false, additivity: Bool = true)
    {
        self.identifier = identifier
        self.additivity = additivity
        self.assignedLevel = assignedLevel
        self.appenders = appenders
        self.synchronousMode = synchronousMode
        self.parent = parent
        self.effectiveLevel = assignedLevel ?? parent?.effectiveLevel ??  .info
    }
    
    internal func isRootLogger() ->Bool {
        // only the root logger has a null parent
        return parent == nil;
    }
    
    // If child already exist the the grandchild of the child to add will be copied
    open func addChildren(_ child: LogConfiguration, copyGrandChildren:Bool = true)
    {
        child.setParent(self)
        if let oldChild = self.childrenDic[child.identifier], copyGrandChildren == true {
            for grandChildren in oldChild.children {
                child.addChildren(grandChildren, copyGrandChildren: false)
            }
        }
        self.childrenDic[child.identifier] = child
    }
    
    open func getChildren(_ name: String) -> LogConfiguration?
    {
        return self.childrenDic[name]
    }
    
    open func setParent(_ parent: LogConfiguration) {
        self.parent = parent
    }
    
    open func fullName() -> String
    {
        var name: String
        if let parent = self.parent, self.parent?.identifier != BaseLogConfiguration.ROOT_IDENTIFIER {
            name = parent.fullName() + BaseLogConfiguration.DOT + self.identifier
        } else {
            name = self.identifier
        }
        return name
    }
    
    open func details() -> String
    {
        var details: String = "\n"
        if let assigned = self.assignedLevel {
            details += assigned.description + " - " + self.effectiveLevel.description + " - " + self.fullName()
        } else {
            details += "nil - " + self.effectiveLevel.description + " - " + self.fullName()
        }
    
        for (_, child) in self.childrenDic {
            details += child.details()
        }
        return details
    }

    // MARK: - DebugPrintabl
    open var debugDescription: String {
        get {
            let description: String = "\(Mirror(reflecting:self).subjectType) [\(assignedLevel)-\(effectiveLevel)][\(additivity)] \(identifier) - \n \(childrenDic)\r"
            return description
        }
    }
}
