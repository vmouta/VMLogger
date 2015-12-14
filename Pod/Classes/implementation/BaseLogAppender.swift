/**
 * @name            BaseLogAppender.swift
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
A partial implementation of the `LogRecorder` protocol.

Note that this implementation provides no mechanism for log file rotation
or log pruning. It is the responsibility of the developer to keep the log
file at a reasonable size.
*/
public class BaseLogAppender: LogAppender
{
    /** The name of the `LogRecorder`, which is constructed automatically
    based on the `filePath`. */
    public let name: String

    /** The `LogFormatter`s that will be used to format messages for
    the `LogEntry`s to be logged. */
    public let formatters: [LogFormatter]

    /** The list of `LogFilter`s to be used for filtering log messages. */
    public let filters: [LogFilter]
    
    /** The GCD queue that should be used for logging actions related to
    the receiver. */
    public let queue: dispatch_queue_t

    /**
    Initialize a new `LogRecorderBase` instance to use the given parameters.

    :param:     name The name of the log recorder, which must be unique.

    :param:     formatters The `LogFormatter`s to use for the recorder.
    */
    public init(name: String, formatters: [LogFormatter] = [DefaultLogFormatter()], filters: [LogFilter] = [])
    {
        self.name = name
        self.formatters = formatters
        self.queue = dispatch_queue_create(name, DISPATCH_QUEUE_SERIAL)
        self.filters = filters
    }

    /**
    This implementation does nothing. Subclasses must override this function
    to provide actual log recording functionality.

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
    public func recordFormattedMessage(message: String, forLogEntry entry: LogEntry, currentQueue: dispatch_queue_t, synchronousMode: Bool)
    {
        precondition(false, "Must override this")
    }
    
    // MARK: - CustomDebugStringConvertible
    public var debugDescription: String {
        get {
            return "\(Mirror(reflecting: self).subjectType): \(name)"
        }
    }
}

