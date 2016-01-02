/**
 * @name            ConsoleLogAppender.swift
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

struct ConoleLogAppenderConstants {
    static let Colors: String = "colors"
}

// MARK: - XCGConsoleLogDestination
// - A standard log destination that outputs log details to the console
public class ConsoleLogAppender: BaseLogAppender {
    
    public static let CONSOLE_IDENTIFIER: String = "console"
    
    // MARK: - Properties
    public var xcodeColorsEnabled: Bool = false
    public var xcodeColors: [LogLevel: XcodeColor] = [
        .Verbose: .lightGrey,
        .Debug: .darkGrey,
        .Info: .blue,
        .Warning: .orange,
        .Error: .red,
        .Severe: .whiteOnRed
    ]
    
    public convenience init() {
        self.init(name: ConsoleLogAppender.CONSOLE_IDENTIFIER)
    }
    
    public init(name: String, formatters: [LogFormatter] = [DefaultLogFormatter()], filters: [LogFilter] = [], xcodeColorsEnabled: Bool = false) {
        super.init(name: name, formatters: formatters)
        self.xcodeColorsEnabled = xcodeColorsEnabled
    }

    public required convenience init?(configuration: Dictionary<String, AnyObject>) {
        if let config = self.dynamicType.configuration(configuration) {
            let colors = (configuration[ConoleLogAppenderConstants.Colors] as?  Bool) ?? false
            self.init(name:config.name, formatters:config.formatters, filters:config.filters, xcodeColorsEnabled:colors)
        } else {
            return nil
        }
    }
    
    // MARK: - Misc Methods
    override public func recordFormattedMessage(message: String, forLogEntry entry: LogEntry, currentQueue: dispatch_queue_t, synchronousMode: Bool)
    {
        let adjustedText: String
        if let xcodeColor = (xcodeColors ?? xcodeColors)[entry.logLevel] where xcodeColorsEnabled {
            adjustedText = "\(xcodeColor.format())\(message)\(XcodeColor.reset)"
        } else {
            adjustedText = message
        }
        print(adjustedText)
    }
}