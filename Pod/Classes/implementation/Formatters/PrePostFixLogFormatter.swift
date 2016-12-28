//
//  PrePostFixLogFormatter.swift
//  XCGLogger: https://github.com/DaveWoodCom/XCGLogger
//
//  Created by Dave Wood on 2016-09-20.
//  Copyright © 2016 Dave Wood, Cerebral Gardens.
//  Some rights reserved: https://github.com/DaveWoodCom/XCGLogger/blob/master/LICENSE.txt
//

#if os(OSX)
    import AppKit
#elseif os(iOS) || os(tvOS) || os(watchOS)
    import UIKit
#endif

// MARK: - PrePostFixLogFormatter
/// A log formatter that will optionally add a prefix, and/or postfix string to a message
open class PrePostFixLogFormatter: BaseLogFormatter {

    /// Internal cache of the prefix strings for each log level
    internal var prefixStrings: [LogLevel: String] = [:]

    /// Internal cache of the postfix strings codes for each log level
    internal var postfixStrings: [LogLevel: String] = [:]

    public required convenience init?(configuration: Dictionary<String, Any>) {
        self.init()
    }

    /// Set the prefix/postfix strings for a specific log level.
    ///
    /// - Parameters:
    ///     - prefix:   A string to prepend to log messages.
    ///     - postfix:  A string to postpend to log messages.
    ///     - level:    The log level.
    ///
    /// - Returns:  Nothing
    ///
    open func apply(prefix: String? = nil, postfix: String? = nil, to level: LogLevel? = nil) {
        guard let level = level else {
            guard prefix != nil || postfix != nil else { clearFormatting(); return }

            // No level specified, so, apply to all levels
            for level in LogLevel.allLevels {
                self.apply(prefix: prefix, postfix: postfix, to: level)
            }
            return
        }

        if let prefix = prefix {
            prefixStrings[level] = prefix
        }
        else {
            prefixStrings.removeValue(forKey: level)
        }

        if let postfix = postfix {
            postfixStrings[level] = postfix
        }
        else {
            postfixStrings.removeValue(forKey: level)
        }
    }

    /// Clear all previously set colours. (Sets each log level back to default)
    ///
    /// - Parameters:   None
    ///
    /// - Returns:  Nothing
    ///
    open func clearFormatting() {
        prefixStrings = [:]
        postfixStrings = [:]
    }

    /**
     Returns a formatted representation of the given `LogEntry`.
     
     :param:         entry The `LogEntry` being formatted.
     
     :returns:       The formatted representation of `entry`. This particular
     implementation will never return `nil`.
     */
    override open func formatLogEntry(_ entry: LogEntry, message: String) -> String? {
        return "\(prefixStrings[entry.logLevel] ?? "")\(message)\(postfixStrings[entry.logLevel] ?? "")"
    }

    // MARK: - CustomDebugStringConvertible
    open override var debugDescription: String {
        get {
            let type = Mirror(reflecting: self).subjectType
            var description: String = "\(type): \(self.dateFormatter), \(self.severityTagLenght), \(self.identityTagLenght)"
            for level in LogLevel.allLevels {
                description += "\n\t- \(level) > \(prefixStrings[level] ?? "None") | \(postfixStrings[level] ?? "None")"
            }
            return description
        }
    }
}
