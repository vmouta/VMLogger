//
//  EmojieLogFormatter.swift
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

struct EmojieLogFormatterConstants {
    static let Emojies: String = "emojies"
    
    static let EmojiesIcons: String = "icons"
    static let EmojiesColors: String = "colors"
    static let EmojiesBooks: String = "books"
    static let EmojiesSmiles: String = "smiles"
}

// MARK: - EmojieLogFormatter
/// A log formatter that will optionally add an emojie set as prefix, and/or postfix string to a message
open class EmojieLogFormatter: PrePostFixLogFormatter {
    
    public required convenience init?(configuration: Dictionary<String, Any>) {
        self.init()
        if let emojies = configuration[EmojieLogFormatterConstants.Emojies] as?  String {
            if(emojies == EmojieLogFormatterConstants.EmojiesIcons) {
                self.apply(prefix: "🗯🗯🗯 ", postfix: " 🗯🗯🗯", to: .verbose)
                self.apply(prefix: "🔹🔹🔹 ", postfix: " 🔹🔹🔹", to: .debug)
                self.apply(prefix: "ℹ️ℹ️ℹ️ ", postfix: " ℹ️ℹ️ℹ️", to: .info)
                self.apply(prefix: "⚠️⚠️⚠️ ", postfix: " ⚠️⚠️⚠️", to: .warning)
                self.apply(prefix: "‼️‼️‼️ ", postfix: " ‼️‼️‼️", to: .error)
                self.apply(prefix: "💣💣💣 ", postfix: " 💣💣💣", to: .severe)
                self.apply(prefix: "📣📣📣 ", postfix: " 📣📣📣", to: .event)
            } else if(emojies == EmojieLogFormatterConstants.EmojiesColors) {
                self.apply(prefix: "✳️✳️✳️ ", to: .verbose)
                self.apply(prefix: "🛄🛄🛄 ", to: .debug)
                self.apply(prefix: "ℹ️ℹ️ℹ️ ", to: .info)
                self.apply(prefix: "✴️✴️✴️ ", to: .warning)
                self.apply(prefix: "🅾️🅾️🅾️ ", to: .error)
                self.apply(prefix: "❌❌❌ ", to: .severe)
                self.apply(prefix: "🔯🔯🔯 ", to: .event)
            } else if(emojies == EmojieLogFormatterConstants.EmojiesBooks) {
                self.apply(prefix: "📗📗📗 ", to: .verbose)
                self.apply(prefix: "📘📘📘 ", to: .debug)
                self.apply(prefix: "ℹ️ℹ️ℹ️ ", to: .info)
                self.apply(prefix: "📙📙📙 ", to: .warning)
                self.apply(prefix: "📕📕📕 ", to: .error)
                self.apply(prefix: "📓📓📓 ", to: .severe)
                self.apply(prefix: "📚📚📚 ", to: .event)
            } else if(emojies == EmojieLogFormatterConstants.EmojiesSmiles) {
                self.apply(prefix: "😴😴😴 ", to: .verbose)
                self.apply(prefix: "🤓🤓🤓 ", to: .debug)
                self.apply(prefix: "🤠🤠🤠 ", to: .info)
                self.apply(prefix: "🤔🤔🤔 ", to: .warning)
                self.apply(prefix: "😱😱😱 ", to: .error)
                self.apply(prefix: "😡😡😡 ", to: .severe)
                self.apply(prefix: "🤡🤡🤡 ", to: .event)
            }
        }
    }
}
