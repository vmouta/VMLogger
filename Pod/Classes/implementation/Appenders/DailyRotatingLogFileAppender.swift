/**
 * @name            DailyRotatingLogFileAppender.swift
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

struct DailyRotatingLogFileAppendContants {
    static let FilenameDateFormat: String = "filenamedateformat"
    static let DaysToKeep: String = "daystokeep"
    static let DirectoryPath: String = "directorypath"
    
    static let DefaultFilenameDateFormat: String = "yyyy-MM-dd'.log'"
    static let DefaultDaysToKeep: String = "30"
    static let DefaultDirectoryPath: String = "/logs"
}

/**
A `LogRecorder` implementation that maintains a set of daily rotating log
files, kept for a user-specified number of days.

**Important:** The `DailyRotatingLogFileRecorder` is expected to have full
control over the `directoryPath` with which it was instantiated. Any file not
explicitly known to be an active log file may be removed during the pruning
process. Therefore, be careful not to store anything in the `directoryPath`
that you wouldn't mind being deleted when pruning occurs.
*/
open class DailyRotatingLogFileAppender: BaseLogAppender
{
    /** The number of days for which the receiver will retain log files
    before they're eligible for pruning. */
    open let daysToKeep: Int

    /** The filesystem path to a directory where the log files will be
    stored. */
    open let directoryPath: String
    open let directoryURLPath: URL
    
    open let filenameDateFormat: String

    fileprivate lazy var filenameFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = self.filenameDateFormat
        return fmt
    }()

    fileprivate var mostRecentLogTime: Date?
    fileprivate var currentFileRecorder: FileLogAppend?

    /**
    Attempts to initialize a new `DailyRotatingLogFileRecorder` instance. This
    may fail if the `directoryPath` doesn't already exist as a directory and
    could not be created.
    
    **Important:** The new `DailyRotatingLogFileRecorder` will take 
    responsibility for managing the contents of the `directoryPath`. As part
    of the automatic pruning process, any file not explicitly known to be an
    active log file may be removed. Be careful not to put anything in this
    directory you might not want deleted when pruning occurs.

    :param:     daysToKeep The number of days for which log files should be
                retained.
    
    :param:     directoryPath The filesystem path of the directory where the
                log files will be stores.

    :param:     formatters The `LogFormatter`s to use for the recorder.
    */
    public convenience init(daysToKeep: Int, directoryPath: String, formatters: [LogFormatter] = [DefaultLogFormatter()]) throws
    {
        try self.init(name: "DailyRotatingLogFileRecorder[\(directoryPath)]", dateFormat: DailyRotatingLogFileAppendContants.DefaultFilenameDateFormat, daysToKeep:daysToKeep, directoryPath:directoryPath, formatters: formatters)
    }
    
    public init(name: String, dateFormat:String, daysToKeep: Int, directoryPath: String, formatters: [LogFormatter] = [DefaultLogFormatter()], filters: [LogFilter] = []) throws
    {
        self.filenameDateFormat = dateFormat
        self.daysToKeep = daysToKeep
        self.directoryPath = directoryPath
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let url = URL(fileURLWithPath: paths[0], isDirectory: true)
        self.directoryURLPath = url.appendingPathComponent(directoryPath)
        
        super.init(name: name, formatters: formatters, filters: filters)
        
        // try to create the directory that will contain the log files
        //print(directoryURLPath)
        try FileManager.default.createDirectory(at: directoryURLPath, withIntermediateDirectories: true, attributes: nil)
    }

    public required convenience init?(configuration: Dictionary<String, Any>) {
        guard let config = type(of: self).DailyRotatingLogConfiguration(configuration) else {
            return nil
        }
        
        do {
            try self.init(name:config.name, dateFormat:config.dateFormat, daysToKeep:config.daysToKeep, directoryPath:config.directoryPath, formatters:config.formatters, filters:config.filters)
        } catch {
            return nil
        }
    }
    
    open class func DailyRotatingLogConfiguration(_ configuration: Dictionary<String, Any>) -> (name: String, dateFormat:String, daysToKeep:Int, directoryPath:String, formatters: [LogFormatter], filters: [LogFilter])?  {
        
        guard let config = self.configuration(configuration: configuration) else {
            return nil
        }
        
        let dateFormat = configuration[DailyRotatingLogFileAppendContants.FilenameDateFormat] as?  String ?? DailyRotatingLogFileAppendContants.DefaultFilenameDateFormat
        let daysToKeepString = configuration[DailyRotatingLogFileAppendContants.DaysToKeep] as?  String ?? DailyRotatingLogFileAppendContants.DefaultDaysToKeep
        let daysToKeep = Int(daysToKeepString) ?? 1
        let directoryPath = configuration[DailyRotatingLogFileAppendContants.DirectoryPath] as?  String ??  DailyRotatingLogFileAppendContants.DefaultDirectoryPath
        
        return (config.0, dateFormat, daysToKeep, directoryPath, config.1, config.2)
    }

    /**
    Returns a string representing the filename that will be used to store logs
    recorded on the given date.
    
    :param:     date The `NSDate` for which the log file name is desired.
    
    :returns:   The filename.
    */
    open func logFilenameForDate(_ date: Date)
        -> String
    {
        return filenameFormatter.string(from: date)
    }

    fileprivate func fileLogRecorderForDate(_ date: Date, directoryPath: String, formatters: [LogFormatter])
        -> FileLogAppend?
    {
        let fileName = self.logFilenameForDate(date)
        let filePath = (directoryPath as NSString).appendingPathComponent(fileName)
        return FileLogAppend(filePath: filePath, formatters: formatters)
    }

    fileprivate func fileLogRecorderForDate(_ date: Date)
        -> FileLogAppend?
    {
        return self.fileLogRecorderForDate(date, directoryPath: directoryPath, formatters: formatters)
    }

    fileprivate func isDate(_ firstDate: Date, onSameDayAs secondDate: Date)
        -> Bool
    {
        let firstDateStr = self.logFilenameForDate(firstDate)
        let secondDateStr = self.logFilenameForDate(secondDate)
        return firstDateStr == secondDateStr
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
        if mostRecentLogTime == nil || !self.isDate(entry.timestamp as Date, onSameDayAs: mostRecentLogTime!) {
            prune()
            currentFileRecorder = fileLogRecorderForDate(entry.timestamp as Date)
        }
        mostRecentLogTime = entry.timestamp as Date

        currentFileRecorder?.recordFormattedMessage(message, forLogEntry: entry, currentQueue: queue, synchronousMode: synchronousMode)
    }

    /**
    Deletes any expired log files (and any other detritus that may be hanging
    around inside our `directoryPath`).
    
    **Important:** The `DailyRotatingLogFileRecorder` is expected to have full
    ownership over its `directoryPath`. Any file not explicitly known to be an
    active log file may be removed during the pruning process. Therefore, be
    careful not to store anything in this directory that you wouldn't mind
    being deleted when pruning occurs.
    */
    open func prune()
    {
        // figure out what files we'd want to keep, then nuke everything else
        let cal = Calendar.current
        var date = Date()
        var filesToKeep = Set<String>()
        for _ in 0..<daysToKeep {
            let filename = self.logFilenameForDate(date)
            filesToKeep.insert(filename)
            date = (cal as NSCalendar).date(byAdding: .day, value: -1, to: date, options: .wrapComponents)!
        }

        do {
            let fileMgr = FileManager.default
            let filenames = try fileMgr.contentsOfDirectory(at: directoryURLPath, includingPropertiesForKeys: nil)

            let pathsToRemove = filenames
                .filter { return !$0.absoluteString.hasPrefix(".") }
                .filter { return !filesToKeep.contains($0.lastPathComponent) }
                .map { return $0 }

            for path in pathsToRemove {
                do {
                    try fileMgr.removeItem(at: path)
                }
                catch {
                    print("Error attempting to delete the unneeded file <\(path)>: \(error)")
                }
            }
        }
        catch {
            print("Error attempting to read directory at path <\(directoryURLPath.absoluteString)>: \(error)")
        }
    }
}

