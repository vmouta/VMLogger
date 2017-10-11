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
    open static let ROOT_IDENTIFIER: String = "root"
    open static let DOT: String = "."

    public init() {
        super.init(RootLogConfiguration.ROOT_IDENTIFIER, assignedLevel: .info, parent: nil, appenders: [ConsoleLogAppender()], synchronousMode: false, additivity: false)
    }
    
    public init(assignedLevel: LogLevel = .info, appenders: [LogAppender] = [ConsoleLogAppender()], synchronousMode: Bool = false) {
        super.init(RootLogConfiguration.ROOT_IDENTIFIER, assignedLevel: assignedLevel, parent: nil, appenders: appenders, synchronousMode: synchronousMode, additivity: false)
    }
    
    public required init(_ identifier: String, assignedLevel: LogLevel? = .info, parent: LogConfiguration?, appenders: [LogAppender], synchronousMode: Bool = false, additivity: Bool = true) {
        super.init(identifier, assignedLevel:assignedLevel, parent:parent, appenders:appenders, synchronousMode:synchronousMode, additivity:additivity)
    }
    
    internal func isRootLogger() ->Bool {
        // only the root logger has a null parent
        return parent == nil;
    }
    
    /// MARK: From BaseLogConfiguration
    
    internal func getChildren(_ identifier: String, type: BaseLogConfiguration.Type ) -> LogConfiguration {
        var name = identifier
        var parent: LogConfiguration = self
        while (true) {
            if let child = parent.getChildren(name) {
                return child
            } else {
                var tree: String? = nil
                if let range = name.range(of: RootLogConfiguration.DOT) {
                    tree = String(name[range.upperBound...])
                    name = String(name[..<range.lowerBound])
                    if let child = parent.getChildren(name) {
                        parent = child
                        name = tree!
                        continue
                    }
                }
                let child = type.init(name, assignedLevel: nil, parent: parent, appenders: [], synchronousMode: synchronousMode)
                parent.addChildren(child, copyGrandChildren:false)
                guard tree != nil else { return child }
                parent = child
                name = tree!
            }
            
        }
    }
    
    open override func fullName() -> String
    {
        var name: String
        if let parent = self.parent, self.parent?.identifier != RootLogConfiguration.ROOT_IDENTIFIER {
            name = parent.fullName() + RootLogConfiguration.DOT + self.identifier
        } else {
            name = self.identifier
        }
        return name
    }
}
