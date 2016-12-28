//
//  Base64LogFormatter.swift
//  XCGLogger: https://github.com/DaveWoodCom/XCGLogger
//
//  Created by Dave Wood on 2016-08-30.
//  Copyright © 2016 Dave Wood, Cerebral Gardens.
//  Some rights reserved: https://github.com/DaveWoodCom/XCGLogger/blob/master/LICENSE.txt
//

// MARK: - Base64LogFormatter
/// An example log formatter to show how encryption could be used to secure log messages, in this case, we just Base64 encode them
open class Base64LogFormatter: BaseLogFormatter {
    
    public required convenience init?(configuration: Dictionary<String, Any>) {
        self.init()
    }
    
    /**
     Returns a formatted representation of the given `LogEntry`.
     
     :param:         entry The `LogEntry` being formatted.
     
     :returns:       The formatted representation of `entry`. This particular
     implementation will never return `nil`.
     */
    override open func formatLogEntry(_ entry: LogEntry, message: String) -> String? {
        guard let utf8Message = message.data(using: .utf8) else { return message }

        return utf8Message.base64EncodedString()
    }
}
