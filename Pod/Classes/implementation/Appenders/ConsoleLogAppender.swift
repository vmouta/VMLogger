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

// - A standard log destination that outputs log details to the console
open class ConsoleLogAppender: BaseLogAppender {
    
    open static let CONSOLE_IDENTIFIER: String = "console"
    
    public convenience init() {
        self.init(name: ConsoleLogAppender.CONSOLE_IDENTIFIER)
    }
    
    // MARK: - Misc Methods
    override open func recordFormattedMessage(_ message: String, forLogEntry entry: LogEntry, currentQueue: DispatchQueue, synchronousMode: Bool)
    {
        print(message)
    }
}
