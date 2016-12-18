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
    static let Emojies: String = "emojies"
    
    static let EmojiesIcons: String = "icons"
    static let EmojiesColors: String = "colors"
    static let EmojiesBooks: String = "books"
    static let EmojiesSmiles: String = "smiles"
}

// - A standard log destination that outputs log details to the console
open class ConsoleLogAppender: BaseLogAppender {
    
    open static let CONSOLE_IDENTIFIER: String = "console"
    
    open static var emojyIcons: PrePostFixLogFormatter {
        let emojiLogFormatter = PrePostFixLogFormatter()
        emojiLogFormatter.apply(prefix: "🗯🗯🗯 ", postfix: " 🗯🗯🗯", to: .verbose)
        emojiLogFormatter.apply(prefix: "🔹🔹🔹 ", postfix: " 🔹🔹🔹", to: .debug)
        emojiLogFormatter.apply(prefix: "ℹ️ℹ️ℹ️ ", postfix: " ℹ️ℹ️ℹ️", to: .info)
        emojiLogFormatter.apply(prefix: "⚠️⚠️⚠️ ", postfix: " ⚠️⚠️⚠️", to: .warning)
        emojiLogFormatter.apply(prefix: "‼️‼️‼️ ", postfix: " ‼️‼️‼️", to: .error)
        emojiLogFormatter.apply(prefix: "💣💣💣 ", postfix: " 💣💣💣", to: .severe)
        emojiLogFormatter.apply(prefix: "📣📣📣 ", postfix: " 📣📣📣", to: .event)
        return emojiLogFormatter
    }
    
    open static var emojyColors: PrePostFixLogFormatter {
        let emojiLogFormatter = PrePostFixLogFormatter()
        emojiLogFormatter.apply(prefix: "✳️✳️✳️ ", to: .verbose)
        emojiLogFormatter.apply(prefix: "🛄🛄🛄 ", to: .debug)
        emojiLogFormatter.apply(prefix: "ℹ️ℹ️ℹ️ ", to: .info)
        emojiLogFormatter.apply(prefix: "✴️✴️✴️ ", to: .warning)
        emojiLogFormatter.apply(prefix: "🅾️🅾️🅾️ ", to: .error)
        emojiLogFormatter.apply(prefix: "❌❌❌ ", to: .severe)
        emojiLogFormatter.apply(prefix: "🔯🔯🔯 ", to: .event)
        return emojiLogFormatter
    }
    
    open static var emojyBooks: PrePostFixLogFormatter {
        let emojiLogFormatter = PrePostFixLogFormatter()
        emojiLogFormatter.apply(prefix: "📗📗📗 ", to: .verbose)
        emojiLogFormatter.apply(prefix: "📘📘📘 ", to: .debug)
        emojiLogFormatter.apply(prefix: "ℹ️ℹ️ℹ️ ", to: .info)
        emojiLogFormatter.apply(prefix: "📙📙📙 ", to: .warning)
        emojiLogFormatter.apply(prefix: "📕📕📕 ", to: .error)
        emojiLogFormatter.apply(prefix: "📓📓📓 ", to: .severe)
        emojiLogFormatter.apply(prefix: "📚📚📚 ", to: .event)
        return emojiLogFormatter
    }
    
    open static var emojySmiles: PrePostFixLogFormatter {
        let emojiLogFormatter = PrePostFixLogFormatter()
        emojiLogFormatter.apply(prefix: "😴😴😴 ", to: .verbose)
        emojiLogFormatter.apply(prefix: "🤓🤓🤓 ", to: .debug)
        emojiLogFormatter.apply(prefix: "🤠🤠🤠 ", to: .info)
        emojiLogFormatter.apply(prefix: "🤔🤔🤔 ", to: .warning)
        emojiLogFormatter.apply(prefix: "😱😱😱 ", to: .error)
        emojiLogFormatter.apply(prefix: "😡😡😡 ", to: .severe)
        emojiLogFormatter.apply(prefix: "🤡🤡🤡 ", to: .event)
        return emojiLogFormatter
    }
    
    public convenience init() {
        self.init(name: ConsoleLogAppender.CONSOLE_IDENTIFIER)
    }

    public required convenience init?(configuration: Dictionary<String, AnyObject>) {
        if let config = type(of: self).configuration(configuration: configuration) {
            self.init(name:config.name, formatters:config.formatters, filters:config.filters)
            if let emojies = configuration[ConoleLogAppenderConstants.Emojies] as?  String {
                if(emojies == ConoleLogAppenderConstants.EmojiesIcons) { self.formatters.append(ConsoleLogAppender.emojyIcons) }
                else if(emojies == ConoleLogAppenderConstants.EmojiesColors) { self.formatters.append(ConsoleLogAppender.emojyColors) }
                else if(emojies == ConoleLogAppenderConstants.EmojiesBooks) { self.formatters.append(ConsoleLogAppender.emojyBooks) }
                else if(emojies == ConoleLogAppenderConstants.EmojiesSmiles) { self.formatters.append(ConsoleLogAppender.emojySmiles) }
            }
            
        } else {
            return nil
        }
    }
    
    // MARK: - Misc Methods
    override open func recordFormattedMessage(_ message: String, forLogEntry entry: LogEntry, currentQueue: DispatchQueue, synchronousMode: Bool)
    {
        print(message)
    }
}
