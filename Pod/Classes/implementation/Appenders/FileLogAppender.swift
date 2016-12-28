/**
 * @name            FileLogAppend.swift
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

struct FileLogAppendContants {
    static let FileName: String = "fileName"
}

/**
A `LogRecorder` implementation that stores log messages in a file.

**Note:** This implementation provides no mechanism for log file rotation
or log pruning. It is the responsibility of the developer to keep the log
file at a reasonable size. Use `DailyRotatingLogFileRecorder` instead if you'd 
rather not have to think about such details.
*/
open class FileLogAppend: BaseLogAppender
{
    /** The path of the file to which log messages will be written. */
    open let filePath: String

    fileprivate let file: UnsafeMutablePointer<FILE>?
    fileprivate let newlineCharset: CharacterSet

    /**
    Attempts to initialize a new `FileLogRecorder` instance to use the
    given file path and log formatters. This will fail if `filePath` could
    not be opened for writing.
    
    :param:     filePath The path of the file to be written. The containing
                directory must exist and be writable by the process. If the
                file does not yet exist, it will be created; if it does exist,
                new log messages will be appended to the end.
    
    :param:     formatters The `LogFormatter`s to use for the recorder.
    */
    public convenience init?(filePath: String, formatters: [LogFormatter] = [DefaultLogFormatter()])
    {
        self.init(name: "FileLogRecorder[\(filePath)]", filePath: filePath, formatters: formatters)
    }
    
    /**
     Attempts to initialize a new `FileLogRecorder` instance to use the
     given file path and log formatters. This will fail if `filePath` could
     not be opened for writing.
     
     :param:     filePath The path of the file to be written. The containing
     directory must exist and be writable by the process. If the
     file does not yet exist, it will be created; if it does exist,
     new log messages will be appended to the end.
     
     :param:     formatters The `LogFormatter`s to use for the recorder.
     */
    public init?(name:String, filePath: String, formatters: [LogFormatter] = [DefaultLogFormatter()], filters:[LogFilter] = [])
    {
        let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
        let dir = dirs[0] //documents directory
        let nsSt = (dir as NSString)
        let fileNamePath = nsSt.appendingPathComponent(filePath)
        let f = fopen(fileNamePath, "a")
        if f != nil  {
            self.filePath = fileNamePath;
            self.file = f;
            self.newlineCharset = CharacterSet.newlines
            super.init(name:name, formatters: formatters, filters:filters)
        } else {
            return nil
        }
    }

    public required convenience init?(configuration: Dictionary<String, Any>) {
        guard let filePath = configuration[FileLogAppendContants.FileName] as?  String  else {
            return nil
        }
        
        guard let config = type(of: self).configuration(configuration: configuration) else {
            return nil
        }
        self.init(name:config.name, filePath:filePath, formatters:config.formatters, filters:config.filters)
    }

    deinit {
        // we've implemented FileLogRecorder as a class so we
        // can have a de-initializer to close the file
        if file != nil {
            fclose(file)
        }
    }

    /**
    Called by the `LogReceptacle` to record the specified log message.
    
    **Note:** This function is only called if one of the `formatters`
    associated with the receiver returned a non-`nil` string.

    :param:     message The message to record.

    :param:     entry The `LogEntry` for which `message` was created.

    :param:     currentQueue The GCD queue on which the function is being
                executed.

    :param:     synchronousMode If `true`, the receiver should record the
                log entry synchronously. Synchronous mode is used during
                debugging to help ensure that logs reflect the latest state
                when debug breakpoints are hit. It is not recommended for
                production code.
    */
    open override func recordFormattedMessage(_ message: String, forLogEntry entry: LogEntry, currentQueue: DispatchQueue, synchronousMode: Bool)
    {
        var addNewline = true
        let uniStr = message.unicodeScalars
        if uniStr.count > 0 {
            let c = unichar(uniStr[uniStr.index(before: uniStr.endIndex)].value)
            addNewline = !newlineCharset.contains(UnicodeScalar(c)!)
        }

        var writeStr = message
        if addNewline {
            writeStr += "\n"
        }

        fputs(writeStr, file)
        fflush(file)
    }
}

