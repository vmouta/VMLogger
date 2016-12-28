/**
 * @name             Log.swift
 * @partof           zucred AG
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

// MARK: - Log
// - The main logging class
open class Log: BaseLogConfiguration {

    private static let LoggerInfoFile: String = "VMLogger-Info"
    private static let LoggerConfig: String = "LOGGER_CONFIG"
    private static let LoggerAppenders: String = "LOGGER_APPENDERS"
    private static let LoggerLevel: String = "LOGGER_LEVEL"
    private static let LoggerSynchronous: String = "LOGGER_SYNCHRONOUS"
    private static let Appenders: String = "APPENDERS"
    
    private static var _root: RootLogConfiguration?
    
    private static var _event: LogChannel?
    private static var _severe: LogChannel?
    private static var _error: LogChannel?
    private static var _warning: LogChannel?
    private static var _info: LogChannel?
    private static var _debug: LogChannel?
    private static var _verbose: LogChannel?
    
    public static var sharedInstance: LogConfiguration {
        if(_root == nil) {
            start(root: RootLogConfiguration(), logReceptacle: LogReceptacle())
        }
        return _root!;
    }
    
    private static func channelForSeverity(severity: LogLevel) -> LogChannel?
    {
        switch severity {
        case .verbose:  return _verbose
        case .debug:    return _debug
        case .info:     return _info
        case .warning:  return _warning
        case .error:    return _error
        case .severe:   return _severe
        case .event:    return _event
        default:        return nil
        }
    }
    
    @discardableResult
    public static func enableFromFile(fileName: String = Log.LoggerInfoFile) -> NSDictionary? {
        if let path = Bundle.main.path(forResource: fileName, ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) {
            self.enable(dict)
            return dict
        } else {
            ///  No zucred configuration file, set default values
            /// Logger Configuration
            #if DEBUG
                Log.enable(.Debug)
            #else
                Log.enable()
            #endif
            Log.error("Log configuration file not found: \(fileName)")
        }
        return nil
    }

    public static func enable(_ values: NSDictionary) {
        #if DEBUG
            var rootLevel: LogLevel = .debug
           
        #else
            var rootLevel: LogLevel = .info
        #endif
        var rootSynchronous = false
        var appenders: [String:LogAppender] = [:]
        var rootAppenders: [LogAppender] = []
        
        /// Appenders for the log
        if let appendersConfig = values.value(forKey: Log.Appenders) as? Array<Dictionary<String, Any> > {
            for appenderConfig in appendersConfig {
                if let className = appenderConfig[LogAppenderConstants.Class] as? String {
                    if let swiftClass = NSClassFromString(className) as? LogAppender.Type {
                        if let appender = swiftClass.init(configuration: appenderConfig) {
                            appenders[appender.name] = appender
                        }
                    }
                }
            }
        }
        
        /// Root Appenders
        if let rootAppendersConfig = values.value(forKey: Log.LoggerAppenders) as? Array<String> {
            for rootAppender in rootAppendersConfig {
                if let appender = appenders[rootAppender] {
                    rootAppenders.append(appender)
                }
            }
        } else if let appender = appenders[ConsoleLogAppender.CONSOLE_IDENTIFIER] {
            rootAppenders.append(appender)
        }
        /// Root Log Level
        if let rootLoggerLevel = values.value(forKey: Log.LoggerLevel) as? String {
            rootLevel = LogLevel(level: rootLoggerLevel)
        }
        // Root synchronous mode
        if let rootLoggerSynchronous = values.value(forKey: Log.LoggerSynchronous) as? Bool {
            rootSynchronous = rootLoggerSynchronous
        }
        Log.enable(root: RootLogConfiguration(assignedLevel:rootLevel, appenders:rootAppenders, synchronousMode:rootSynchronous), minimumSeverity:rootLevel)
        
        /// Logs Configuration
        if let logsConfig = values.value(forKey: Log.LoggerConfig) as? Dictionary<String, Any> {
            for (logName, configValue) in logsConfig {
                if let configuration = configValue as? Dictionary<String, Any> {
                    let currentChild = self.getLogger(logName)
                    if let parent = currentChild.parent {
                        let newChild = self.init(currentChild.identifier, parent: parent, allAppenders:appenders, configuration: configuration)
                        parent.addChildren(newChild!, copyGrandChildren: true)
                    } else {
                        // Changing root configuration
                        // TODO: possibility to reset root configuration
                    }
                } else {
                    Log.error("Log configuration for \(logName) is not valid. Dictionary<String, Any> is required")
                }
            }
        }
        
        Log.verbose("Log Configuration:\n" + values.pretty)
    }
    
    /**
     Enables logging with the specified minimum `LogSeverity` using the
     `DefaultLogConfiguration`.
     
     This variant logs to the Apple System Log and to the `stderr` output
     stream of the application process. In Xcode, log messages will appear in
     the console.
     
     :param:     minimumSeverity The minimum `LogSeverity` for which log messages
     will be accepted. Attempts to log messages less severe than
     `minimumSeverity` will be silently ignored.
     
     :param:     synchronousMode Determines whether synchronous mode logging
     will be used. **Use of synchronous mode is not recommended in
     production code**; it is provided for use during debugging, to
     help ensure that messages send prior to hitting a breakpoint
     will appear in the console when the breakpoint is hit.
     */
    public static func enable(assignedLevel: LogLevel = .info, synchronousMode: Bool = false)
    {
        let root = RootLogConfiguration(assignedLevel: assignedLevel, appenders:[ConsoleLogAppender()], synchronousMode:synchronousMode)
        Log.start(root: root, logReceptacle: LogReceptacle(), minimumSeverity: root.effectiveLevel)
    }
    
    public static func enable(root: RootLogConfiguration, minimumSeverity: LogLevel)
    {
        Log.start(root: root, logReceptacle: LogReceptacle(), minimumSeverity: minimumSeverity)
    }
    
    private static func start(root: RootLogConfiguration, logReceptacle: LogReceptacle, minimumSeverity: LogLevel = .info)
    {
        start( root: root,
            eventChannel: self.createLogChannelWithSeverity(severity: .event, receptacle: logReceptacle, minimumSeverity: minimumSeverity),
            severeChannel: self.createLogChannelWithSeverity(severity: .severe, receptacle: logReceptacle, minimumSeverity: minimumSeverity),
            errorChannel: self.createLogChannelWithSeverity(severity: .error, receptacle: logReceptacle, minimumSeverity: minimumSeverity),
            warningChannel: self.createLogChannelWithSeverity(severity: .warning, receptacle: logReceptacle, minimumSeverity: minimumSeverity),
            infoChannel: self.createLogChannelWithSeverity(severity: .info, receptacle: logReceptacle, minimumSeverity: minimumSeverity),
            debugChannel: self.createLogChannelWithSeverity(severity: .debug, receptacle: logReceptacle, minimumSeverity: minimumSeverity),
            verboseChannel: self.createLogChannelWithSeverity(severity: .verbose, receptacle: logReceptacle, minimumSeverity: minimumSeverity)
        )
    }
    
    /**
     Enables logging using the specified `LogChannel`s.
     
     The static `error`, `warning`, `info`, `debug`, and `verbose` properties of
     `Log` will be set using the specified values.
     
     If you know that the configuration of a given `LogChannel` guarantees that
     it will never perform logging, it is best to pass `nil` instead. Otherwise,
     needless overhead will be added to the application.
     
     :param:     errorChannel The `LogChannel` to use for logging messages with
     a `severity` of `.Error`.
     
     :param:     warningChannel The `LogChannel` to use for logging messages with
     a `severity` of `.Warning`.
     
     :param:     infoChannel The `LogChannel` to use for logging messages with
     a `severity` of `.Info`.
     
     :param:     debugChannel The `LogChannel` to use for logging messages with
     a `severity` of `.Debug`.
     
     :param:     verboseChannel The `LogChannel` to use for logging messages with
     a `severity` of `.Verbose`.
     */
    private static func start(root: RootLogConfiguration, eventChannel: LogChannel?, severeChannel: LogChannel?, errorChannel: LogChannel?, warningChannel: LogChannel?, infoChannel: LogChannel?, debugChannel: LogChannel?, verboseChannel: LogChannel?)
    {
        let enableOnce: () = {
            self._root = root
            self._event = eventChannel
            self._severe = severeChannel
            self._error = errorChannel
            self._warning = warningChannel
            self._info = infoChannel
            self._debug = debugChannel
            self._verbose = verboseChannel
        }()
        _ = enableOnce
    }
    
    private static func createLogChannelWithSeverity(severity: LogLevel, receptacle: LogReceptacle, minimumSeverity: LogLevel) -> LogChannel?
    {
        if severity >= minimumSeverity {
            return LogChannel(severity: severity, receptacle: receptacle)
        }
        return nil
    }
    
    public class func getLogger(_ identifier: String) -> LogConfiguration {
        
        var name = identifier
        var parent: LogConfiguration = Log.sharedInstance
        while (true) {
            if let child = parent.getChildren(name) {
                return child
            } else {
                var token: [String] = name.components(separatedBy: BaseLogConfiguration.DOT)
                if token.count == 1 {
                    let child = self.init(token[0], parent: parent)
                    parent.addChildren(child, copyGrandChildren: true)
                    return child
                } else {
                    var child = parent.getChildren(token[0])
                    if child == nil  {
                        child = self.init(token[0], parent: parent)
                        parent.addChildren(child!, copyGrandChildren: true)
                    }
                    parent = child!
                    let range = name.range(of: BaseLogConfiguration.DOT)!
                    name = name.substring(from: range.upperBound)
                }
            }
        }
    }
    
    public required init?(_ identifier: String, parent: LogConfiguration, allAppenders:[String:LogAppender], configuration: Dictionary<String,Any>) {
        var additivity = true
        var logLevel:LogLevel? = nil
        var appenders: [LogAppender] = []
        var synchronous: Bool = false
        
        /// Log level
        if let config = configuration[LogConfigurationConstants.Level] as? String {
            logLevel = LogLevel(level: config)
        }
        /// Log additivity
        if let config = configuration[LogConfigurationConstants.Additivity] as? Bool {
            additivity = config
        }
        // Log synchronous mode
        if let logSynchronous = configuration[LogConfigurationConstants.Synchronous] as? Bool {
            synchronous = logSynchronous
        }
        /// Log Appenders
        if let config = configuration[LogConfigurationConstants.Appenders] as? Array<String> {
            for appenderName in config {
                if let appender = allAppenders[appenderName] {
                    appenders.append(appender)
                }
            }
        }
        super.init(identifier, assignedLevel:logLevel, parent:parent, appenders:appenders, synchronousMode:synchronous, additivity:additivity)
    }
    
    public required init(_ identifier: String, parent: LogConfiguration){
        super.init(identifier, assignedLevel:nil, parent: parent, appenders: [], synchronousMode:parent.synchronousMode)
    }
    
    // MARK: - Convenience logging methods
    // MARK: * Verbose
    public class func verbose(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.trace(logger: Log.sharedInstance, severity: .verbose, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public class func verbose(_ message: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.message(logger: Log.sharedInstance, severity: .verbose, message: message, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public class func verbose(_ value: Any?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.value(logger: Log.sharedInstance, severity: .verbose, value: value, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func verbose(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.trace(logger: self, severity: .verbose, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func verbose(_ message: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.message(logger: self, severity: .verbose, message: message, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func verbose(_ value: Any?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.value(logger: self, severity: .verbose, value: value, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    // MARK: * Debug
    public class func debug(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.trace(logger: Log.sharedInstance, severity: .debug, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public class func debug(_ message: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.message(logger: Log.sharedInstance, severity: .debug, message: message, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public class func debug(_ value: Any?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.value(logger: Log.sharedInstance, severity: .debug, value: value, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func debug(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.trace(logger: self, severity: .debug, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func debug(_ message: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.message(logger: self, severity: .debug, message: message, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func debug(_ value: Any?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.value(logger: self, severity: .debug, value: value, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    // MARK: * Info
    public class func info(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.trace(logger: Log.sharedInstance, severity: .info, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public class func info(_ message: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.message(logger: Log.sharedInstance, severity: .info, message: message, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public class func info(_ value: Any?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.value(logger: Log.sharedInstance, severity: .info, value: value, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func info(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.trace(logger: self, severity: .info, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func info(_ message: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.message(logger: self, severity: .info, message: message, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func info(_ value: Any?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.value(logger: self, severity: .info, value: value, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    // MARK: * Warning
    public class func warning(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.trace(logger: Log.sharedInstance, severity: .warning, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public class func warning(_ message: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.message(logger: Log.sharedInstance, severity: .warning, message: message, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public class func warning(_ value: Any?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.value(logger: Log.sharedInstance, severity: .warning, value: value, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func warning(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.trace(logger: self, severity: .warning, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func warning(_ message: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.message(logger: self, severity: .warning, message: message, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func warning(_ value: Any?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.value(logger: self, severity: .warning, value: value, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    // MARK: * Error
    public class func error(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.trace(logger: Log.sharedInstance, severity: .error, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public class func error(_ message: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.message(logger: Log.sharedInstance, severity: .error, message: message, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public class func error(_ value: Any?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.value(logger: Log.sharedInstance, severity: .error, value: value, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func error(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.trace(logger: self, severity: .error, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func error(_ message: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.message(logger: self, severity: .error, message: message, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func error(_ value: Any?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.value(logger: self, severity: .error, value: value, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    // MARK: * Severe
    public class func severe(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.trace(logger: Log.sharedInstance, severity: .severe, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public class func severe(_ message: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.message(logger: Log.sharedInstance, severity: .severe, message: message, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public class func severe(_ value: Any?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.value(logger: Log.sharedInstance, severity: .severe, value: value, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func severe(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.trace(logger: self, severity: .severe, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func severe(_ message: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.message(logger: self, severity: .severe, message: message, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func severe(_ value: Any?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.value(logger: self, severity: .severe, value: value, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    //MARK: * Event
    public func event(_ value: Any?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.value(logger: self, severity: .event, value: value, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public class func event(_ value: Any?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        Log.value(logger: Log.sharedInstance, severity: .event, value: value, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    /**
     Writes program execution trace information to the log using the specified
     severity. This information includes the signature of the calling function,
     as well as the source file and line at which the call to `trace()` was
     issued.
     
     :param:     severity The `LogSeverity` for the message being recorded.
     
     :param:     function The default value provided for this parameter captures
     the signature of the calling function. **You should not provide
     a value for this parameter.**
     
     :param:     filePath The default value provided for this parameter captures
     the file path of the code issuing the call to this function.
     **You should not provide a value for this parameter.**
     
     :param:     fileLine The default value provided for this parameter captures
     the line number issuing the call to this function. **You should
     not provide a value for this parameter.**
     */
    private static func trace(logger: LogConfiguration, severity: LogLevel, function: String = #function, filePath: String = #file, fileLine: Int = #line)
    {
        channelForSeverity(severity: severity)?.trace(logger, function: function, filePath: filePath, fileLine: fileLine)
    }
    
    /**
     Writes a string-based message to the log using the specified severity.
     
     :param:     severity The `LogSeverity` for the message being recorded.
     
     :param:     msg The message to log.
     
     :param:     function The default value provided for this parameter captures
     the signature of the calling function. **You should not provide
     a value for this parameter.**
     
     :param:     filePath The default value provided for this parameter captures
     the file path of the code issuing the call to this function.
     **You should not provide a value for this parameter.**
     
     :param:     fileLine The default value provided for this parameter captures
     the line number issuing the call to this function. **You should
     not provide a value for this parameter.**
     */
    private static func message(logger: LogConfiguration, severity: LogLevel, message: String, function: String = #function, filePath: String = #file, fileLine: Int = #line)
    {
        channelForSeverity(severity: severity)?.message(logger, msg: message, function: function, filePath: filePath, fileLine: fileLine)
    }
    
    /**
     Writes an arbitrary value to the log using the specified severity.
     
     :param:     severity The `LogSeverity` for the message being recorded.
     
     :param:     value The value to write to the log. The underlying logging
     implementation is responsible for converting `value` into a
     text representation. If that is not possible, the log request
     may be silently ignored.
     
     :param:     function The default value provided for this parameter captures
     the signature of the calling function. **You should not provide
     a value for this parameter.**
     
     :param:     filePath The default value provided for this parameter captures
     the file path of the code issuing the call to this function.
     **You should not provide a value for this parameter.**
     
     :param:     fileLine The default value provided for this parameter captures
     the line number issuing the call to this function. **You should
     not provide a value for this parameter.**
     */
    private static func value(logger: LogConfiguration, severity: LogLevel, value: Any?, function: String = #function, filePath: String = #file, fileLine: Int = #line)
    {
        channelForSeverity(severity: severity)?.value(logger, value: value, function: function, filePath: filePath, fileLine: fileLine)
    }
    
    public static func dumpLog(log: LogConfiguration = Log.sharedInstance, severity: LogLevel = .info) {
        var description = "assigned: "
        if let assignedLevel = log.assignedLevel?.description {
            description = description + String(assignedLevel.characters.first! as Character)
        } else { description = description + "-" }
        description = description + " | effective: " + String(log.effectiveLevel.description.characters.first! as Character)
        description = description + " | appenders: " + log.appenders.description
        description = description + " | name: " + log.fullName()
        switch(severity) {
            case .verbose:
                Log.verbose(description)
            case .debug:
                Log.debug(description)
            case .info:
                Log.info(description)
            case .warning:
                Log.warning(description)
            case .error:
                Log.error(description)
            case .severe:
                Log.severe(description)
            case .event:
                Log.event(description)
            default:
                break
        }
        for child in log.children {
            Log.dumpLog(log: child, severity:severity)
        }
    }
}

extension NSDictionary {
    var pretty: String {
        get {
            if let stringData = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted), let string = String(data: stringData, encoding: String.Encoding.utf8){
                return string
            }
            return "Invalid File"
        }
    }
}



