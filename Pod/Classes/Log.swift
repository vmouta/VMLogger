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
public class Log: BaseLogConfiguration {

    private static var enableOnce = dispatch_once_t()
    
    private static var _root: BaseLogConfiguration?
    
    private static var _severe: LogChannel?
    private static var _error: LogChannel?
    private static var _warning: LogChannel?
    private static var _info: LogChannel?
    private static var _debug: LogChannel?
    private static var _verbose: LogChannel?
    
    public static var sharedInstance: BaseLogConfiguration {
        if(_root == nil) {
            start(RootLogConfiguration(), logReceptacle: LogReceptacle())
        }
        return _root!;
    }
    
    private static func channelForSeverity(severity: LogLevel) -> LogChannel?
    {
        switch severity {
        case .Verbose:  return _verbose
        case .Debug:    return _debug
        case .Info:     return _info
        case .Warning:  return _warning
        case .Error:    return _error
        case .Severe:   return _severe
        default:        return nil
        }
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
    public static func enable(effectiveLevel: LogLevel = .Info, synchronousMode: Bool = false)
    {
        let root = RootLogConfiguration(assignedLevel: effectiveLevel, appenders:[ConsoleLogAppender()])
        Log.start(root, logReceptacle: LogReceptacle(), minimumSeverity: root.effectiveLevel)
    }
    
    private static func start(root: BaseLogConfiguration, logReceptacle: LogReceptacle, minimumSeverity: LogLevel = .Info)
    {
        start( root,
            severeChannel: self.createLogChannelWithSeverity(.Severe, receptacle: logReceptacle, minimumSeverity: minimumSeverity),
            errorChannel: self.createLogChannelWithSeverity(.Error, receptacle: logReceptacle, minimumSeverity: minimumSeverity),
            warningChannel: self.createLogChannelWithSeverity(.Warning, receptacle: logReceptacle, minimumSeverity: minimumSeverity),
            infoChannel: self.createLogChannelWithSeverity(.Info, receptacle: logReceptacle, minimumSeverity: minimumSeverity),
            debugChannel: self.createLogChannelWithSeverity(.Debug, receptacle: logReceptacle, minimumSeverity: minimumSeverity),
            verboseChannel: self.createLogChannelWithSeverity(.Verbose, receptacle: logReceptacle, minimumSeverity: minimumSeverity)
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
    private static func start(root: BaseLogConfiguration, severeChannel severChannel: LogChannel?, errorChannel: LogChannel?, warningChannel: LogChannel?, infoChannel: LogChannel?, debugChannel: LogChannel?, verboseChannel: LogChannel?)
    {
        dispatch_once(&enableOnce) {
            self._root = root
            self._severe = severChannel
            self._error = errorChannel
            self._warning = warningChannel
            self._info = infoChannel
            self._debug = debugChannel
            self._verbose = verboseChannel
        }
    }
    
    private static func createLogChannelWithSeverity(severity: LogLevel, receptacle: LogReceptacle, minimumSeverity: LogLevel) -> LogChannel?
    {
        if severity >= minimumSeverity {
            return LogChannel(severity: severity, receptacle: receptacle)
        }
        return nil
    }
    
    public static func getLogger(identifier: String) -> Log {
        
        var name = identifier
        var parent: LogConfiguration = Log.sharedInstance
        var child: Log?
        while (true) {
            child = parent.getChildren(name) as? Log
            if child != nil {
                return child!
            } else {
                var token: [String] = name.componentsSeparatedByString(BaseLogConfiguration.DOT)
                if token.count == 1 {
                    let newLogger = Log(identifier: token[0], parent: parent)
                    parent.addChildren(newLogger)
                    return newLogger
                } else {
                    child = parent.getChildren(token[0]) as? Log
                    if child == nil  {
                        child = Log(identifier: token[0], parent: parent)
                        parent.addChildren(child!)
                    }
                    parent = child!
                    let range = name.rangeOfString(BaseLogConfiguration.DOT)!
                    name = name.substringFromIndex(range.endIndex)
                }
            }
        }
        
    }
    
    //public required init(identifier: String, minimumLevel: LogLevel = .Info, appenders: [LogAppender], filters: [LogFilter] = [], synchronousMode: Bool = false, additivity: Bool = true) {
    //    super.init(identifier: identifier, minimumLevel:minimumLevel, appenders: appenders, filters:filters, synchronousMode:synchronousMode, additivity:additivity)
    //}
    
    // MARK: - Convenience logging methods
    // MARK: * Verbose
    public class func verbose(functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.trace(Log.sharedInstance, severity: .Verbose, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public class func verbose(message message: String, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.message(Log.sharedInstance, severity: .Verbose, message: message, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public class func verbose(value: Any?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.value(Log.sharedInstance, severity: .Verbose, value: value, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func verbose(functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.trace(self, severity: .Verbose, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func verbose(message message: String, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.message(self, severity: .Verbose, message: message, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func verbose(value: Any?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.value(self, severity: .Verbose, value: value, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    // MARK: * Debug
    public class func debug(functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.trace(Log.sharedInstance, severity: .Debug, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public class func debug(message message: String, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.message(Log.sharedInstance, severity: .Debug, message: message, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public class func debug(value: Any?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.value(Log.sharedInstance, severity: .Debug, value: value, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func debug(functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.trace(self, severity: .Debug, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func debug(message message: String, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.message(self, severity: .Debug, message: message, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func debug(value: Any?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.value(self, severity: .Debug, value: value, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    // MARK: * Info
    public class func info(functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.trace(Log.sharedInstance, severity: .Info, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public class func info(message message: String, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.message(Log.sharedInstance, severity: .Info, message: message, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public class func info(value: Any?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.value(Log.sharedInstance, severity: .Info, value: value, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func info(functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.trace(self, severity: .Info, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func info(message message: String, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.message(self, severity: .Info, message: message, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func info(value: Any?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.value(self, severity: .Info, value: value, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    // MARK: * Warning
    public class func warning(functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.trace(Log.sharedInstance, severity: .Warning, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public class func warning(message message: String, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.message(Log.sharedInstance, severity: .Warning, message: message, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public class func warning(value: Any?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.value(Log.sharedInstance, severity: .Warning, value: value, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func warning(functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.trace(self, severity: .Warning, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func warning(message message: String, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.message(self, severity: .Warning, message: message, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func warning(value: Any?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.value(self, severity: .Warning, value: value, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    // MARK: * Error
    public class func error(functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.trace(Log.sharedInstance, severity: .Error, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public class func error(message message: String, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.message(Log.sharedInstance, severity: .Error, message: message, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public class func error(value: Any?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.value(Log.sharedInstance, severity: .Error, value: value, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func error(functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.trace(self, severity: .Error, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func error(message message: String, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.message(self, severity: .Error, message: message, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func error(value: Any?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.value(self, severity: .Error, value: value, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    // MARK: * Severe
    public class func severe(functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.trace(Log.sharedInstance, severity: .Severe, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public class func severe(message message: String, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.message(Log.sharedInstance, severity: .Severe, message: message, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public class func severe(value: Any?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.value(Log.sharedInstance, severity: .Severe, value: value, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func severe(functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.trace(self, severity: .Severe, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func severe(message message: String, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.message(self, severity: .Severe, message: message, function: functionName, filePath: fileName, fileLine: lineNumber)
    }
    
    public func severe(value: Any?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        Log.value(self, severity: .Severe, value: value, function: functionName, filePath: fileName, fileLine: lineNumber)
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
    private static func trace(logger: LogConfiguration, severity: LogLevel, function: String = __FUNCTION__, filePath: String = __FILE__, fileLine: Int = __LINE__)
    {
        channelForSeverity(severity)?.trace(logger, function: function, filePath: filePath, fileLine: fileLine)
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
    private static func message(logger: LogConfiguration, severity: LogLevel, message: String, function: String = __FUNCTION__, filePath: String = __FILE__, fileLine: Int = __LINE__)
    {
        channelForSeverity(severity)?.message(logger, msg: message, function: function, filePath: filePath, fileLine: fileLine)
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
    private static func value(logger: LogConfiguration, severity: LogLevel, value: Any?, function: String = __FUNCTION__, filePath: String = __FILE__, fileLine: Int = __LINE__)
    {
        channelForSeverity(severity)?.value(logger, value: value, function: function, filePath: filePath, fileLine: fileLine)
    }
}