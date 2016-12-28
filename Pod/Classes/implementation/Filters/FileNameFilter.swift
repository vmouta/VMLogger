/**
 * @name            FileNameFilter.swift
 * @partof          zucred AG
 * @description
 * @author	 		Vasco Mouta
 * @created			18/12/16
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

// MARK: - FileNameFilter
/// Filter log messages by fileName
open class FileNameFilter: LogFilter {

    /// Option to toggle the match results
    open var inverse: Bool = false

    /// Option to match full path or just the fileName
    private var excludePath: Bool = true

    /// Internal list of fileNames to match against
    private var fileNamesToMatch: Set<String> = []

    /// Initializer to create an inclusion list of fileNames to match against
    ///
    /// Note: Only log messages from the specified files will be logged, all others will be excluded
    ///
    /// - Parameters:
    ///     - fileNames:                Set or Array of fileNames to match against.
    ///     - excludePathWhenMatching:  Whether or not to ignore the path for matches. **Default: true **
    ///
    public init<S: Sequence>(includeFrom fileNames: S, excludePathWhenMatching: Bool = true) where S.Iterator.Element == String {
        inverse = true
        excludePath = excludePathWhenMatching
        add(fileNames: fileNames)
    }

    /// Initializer to create an exclusion list of fileNames to match against
    ///
    /// Note: Log messages from the specified files will be excluded from logging
    ///
    /// - Parameters:
    ///     - fileNames:                Set or Array of fileNames to match against.
    ///     - excludePathWhenMatching:  Whether or not to ignore the path for matches. **Default: true **
    ///
    public init<S: Sequence>(excludeFrom fileNames: S, excludePathWhenMatching: Bool = true) where S.Iterator.Element == String {
        inverse = false
        excludePath = excludePathWhenMatching
        add(fileNames: fileNames)
    }
    
    /**
     constructor to be used by introspection
     
     - parameter configuration: configuration for the filter
     
     - returns: if configuration is correct a new LogFilter
     */
    public required convenience init?(configuration: Dictionary<String, Any>) {
        self.init(includeFrom: [])
    }

    /// Add another fileName to the list of names to match against.
    ///
    /// - Parameters:
    ///     - fileName: Name of the file to match against.
    ///
    /// - Returns:
    ///     - true:     FileName added.
    ///     - false:    FileName already added.
    ///
    @discardableResult open func add(fileName: String) -> Bool {
        var fn : String?
        if(excludePath) {
            let components = fileName.characters.split(separator:"/")
            fn = String(describing: components.last)
        } else {
            fn = fileName
        }
        return fileNamesToMatch.insert(fn!).inserted
    }

    /// Add a list of fileNames to the list of names to match against.
    ///
    /// - Parameters:
    ///     - fileNames:    Set or Array of fileNames to match against.
    ///
    /// - Returns:          Nothing
    ///
    @discardableResult open func add<S: Sequence>(fileNames: S) where S.Iterator.Element == String {
        for fileName in fileNames {
            add(fileName: fileName)
        }
    }

    /// Clear the list of fileNames to match against.
    ///
    /// - Note: Doesn't change whether or not the filter is inclusive of exclusive
    ///
    /// - Parameters:   None
    ///
    /// - Returns:      Nothing
    ///
    open func clear() {
        fileNamesToMatch = []
    }

    /// Check if the log message should be excluded from logging.
    /// 
    /// - Note: If the fileName matches
    ///
    /// - Parameters:
    ///     - logDetails:   The log details.
    ///     - message:      Formatted/processed message ready for output.
    ///
    /// - Returns:
    ///     - true:     Drop this log message.
    ///     - false:    Keep this log message and continue processing.
    ///
    open func shouldRecordLogEntry(_ entry: LogEntry) -> Bool {
        var file = entry.callingFilePath
        if(excludePath) {
            let components = file.characters.split(separator:"/")
            file = String(describing: components.last)
        }
        
        var matched: Bool = fileNamesToMatch.contains(file)
        if inverse {
            matched = !matched
        }

        return matched
    }

    // MARK: - CustomDebugStringConvertible
    open var debugDescription: String {
        get {
            let type = Mirror(reflecting: self).subjectType
            var description: String = "\(type): " + (inverse ? "Including only matches for: " : "Excluding matches for: ")
            if fileNamesToMatch.count > 5 {
                description += "\n\t- " + fileNamesToMatch.sorted().joined(separator: "\n\t- ")
            }
            else {
                description += fileNamesToMatch.sorted().joined(separator: ", ")
            }

            return description
        }
    }
}
