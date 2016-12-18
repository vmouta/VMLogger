/**
 * @name            LogReceptacle.swift
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
`LogReceptacle`s provide the low-level interface for accepting log messages.

Although you could use a `LogReceptacle` directly to perform all logging
functions, the `Log` implementation provides a higher-level interface that's
more convenient to use within your code.
*/
public final class LogReceptacle
{
    /**
     This function accepts a `LogEntry` instance and attempts to record it
     to the underlying log storage facility.
     
     :param:     entry The `LogEntry` being logged.
     */
    public func log(_ entry: LogEntry)
    {
        var appendersCount: UInt = 0
        var logger: LogConfiguration? = entry.logger
        let synchronous = logger!.synchronousMode
        _ = dispatcherForQueue(acceptQueue, synchronous: synchronous, block: {
            var config: LogConfiguration
            repeat {
                config = logger!
                if ((entry.logLevel>=config.effectiveLevel) || (config.effectiveLevel == LogLevel.off && config.identifier != entry.logger.identifier)) {
                    for appender in config.appenders {
                        if self.logEntry(entry, passesFilters: appender.filters) {
                            _ = self.dispatcherForQueue(appender.queue, synchronous: synchronous, block: {
                                var formatted: String = BaseLogFormatter.stringRepresentationForPayload(entry)
                                for formatter in appender.formatters {
                                    _ = formatter.formatLogEntry(entry, message: formatted).map { formatted = $0 }
                                }
                                appender.recordFormattedMessage(formatted, forLogEntry: entry, currentQueue: appender.queue, synchronousMode: synchronous)
                                appendersCount=appendersCount+1
                            })
                        }
                    }
                    logger = config.parent
                } else if config.identifier != entry.logger.identifier {
                    logger = config.parent
                } else {
                    logger = nil
                }
            } while(config.additivity == true && logger != nil)
        })
    }
    
    fileprivate lazy var acceptQueue: DispatchQueue = DispatchQueue(label: "LogBackReceptacle.acceptQueue", attributes: [])
    
    fileprivate func logEntry(_ entry: LogEntry, passesFilters filters: [LogFilter]) -> Bool
    {
        for filter in filters {
            if !filter.shouldRecordLogEntry(entry) {
                return false
            }
        }
        return true
    }
    
    fileprivate func dispatcherForQueue(_ queue: DispatchQueue, synchronous: Bool, block: @escaping ()->())
    {
        if synchronous {
            return queue.sync(execute: block)
        } else {
            return queue.async(execute: block)
        }
    }

}
