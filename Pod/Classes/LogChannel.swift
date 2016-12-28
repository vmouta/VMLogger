/**
 * @name            LogChannel.swift
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

/**
`LogChannel` instances provide the high-level interface for accepting log
messages.

They are responsible for converting log requests into `LogEntry` instances
that they then pass along to their associated `LogReceptacle`s to perform the
actual logging.

`LogChannel`s are provided as a convenience, exposed as static properties
through `Log`. Use of `LogChannel`s and the `Log` is not required for logging;
you can also perform logging by creating `LogEntry` instances manually and 
passing them along to a `LogReceptacle`.
*/
public struct LogChannel
{
    /** The `LogSeverity` of this `LogChannel`, which determines the severity
    of the `LogEntry` instances it creates. */
    public let severity: LogLevel

    /** The `LogReceptacle` into which this `LogChannel` will deposit
    the `LogEntry` instances it creates. */
    public let receptacle: LogReceptacle

    /**
    Initializes a new `LogChannel` instance using the specified parameters.
    
    :param:     severity The `LogSeverity` to use for log entries written to the
                receiving channel.
    
    :param:     receptacle A `LogFormatter` instance to use for formatting log
                entries.
    */
    public init(severity: LogLevel, receptacle: LogReceptacle)
    {
        self.severity = severity
        self.receptacle = receptacle
    }

    /**
    Writes program execution trace information to the log. This information
    includes the signature of the calling function, as well as the source file
    and line at which the call to `trace()` was issued.
    
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
    public func trace(_ logger: LogConfiguration, function: String = #function, filePath: String = #file, fileLine: Int = #line)
    {
        var threadID: UInt64 = 0
        pthread_threadid_np(nil, &threadID)

        let entry = LogEntry(logger: logger, payload: .trace, logLevel: severity, callingFunction: function, callingFilePath: filePath, callingFileLine: fileLine, callingThreadID: threadID)
        receptacle.log(entry)
    }

    /**
    Writes a string-based message to the log.
    
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
    public func message(_ logger: LogConfiguration, msg: String, userInfo: [String: Any] = [:], function: String = #function, filePath: String = #file, fileLine: Int = #line)
    {
        var threadID: UInt64 = 0
        pthread_threadid_np(nil, &threadID)

        let entry = LogEntry(logger: logger, payload: .message(msg), logLevel: severity, callingFunction: function, callingFilePath: filePath, callingFileLine: fileLine, callingThreadID: threadID)
        receptacle.log(entry)
    }

    /**
    Writes an arbitrary value to the log.

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
    public func value(_ logger: LogConfiguration, value: Any?, function: String = #function, filePath: String = #file, fileLine: Int = #line)
    {
        var threadID: UInt64 = 0
        pthread_threadid_np(nil, &threadID)

        let entry = LogEntry(logger: logger, payload: .value(value), logLevel: severity, callingFunction: function, callingFilePath: filePath, callingFileLine: fileLine, callingThreadID: threadID)
        receptacle.log(entry)
    }
}
