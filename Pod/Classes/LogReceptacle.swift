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
    public func log(entry: LogEntry)
    {
        var appendersCount: UInt = 0
        var logger: LogConfiguration? = entry.logger
        let synchronous = logger!.synchronousMode
        let acceptDispatcher = dispatcherForQueue(acceptQueue, synchronous: synchronous)
        acceptDispatcher {
            var config: LogConfiguration
            repeat {
                config = logger!
                if ((entry.logLevel>=config.effectiveLevel) || (config.effectiveLevel == LogLevel.Off && config.identifier != entry.logger.identifier)) {
                    for appender in config.appenders {
                        if self.logEntry(entry, passesFilters: appender.filters) {
                            let recordDispatcher = self.dispatcherForQueue(appender.queue, synchronous: synchronous)
                            recordDispatcher {
                                for formatter in appender.formatters {
                                    if let formatted = formatter.formatLogEntry(entry) {
                                        appender.recordFormattedMessage(formatted, forLogEntry: entry, currentQueue: appender.queue, synchronousMode: synchronous)
                                        appendersCount=appendersCount+1
                                    }
                                }
                            }
                        }
                    }
                    logger = config.parent
                } else if config.identifier != entry.logger.identifier {
                    logger = config.parent
                } else {
                    logger = nil
                }
            } while(config.additivity == true && logger != nil)
        }
    }
    
    private lazy var acceptQueue: dispatch_queue_t = dispatch_queue_create("LogBackReceptacle.acceptQueue", DISPATCH_QUEUE_SERIAL)
    
    private func logEntry(entry: LogEntry, passesFilters filters: [LogFilter]) -> Bool
    {
        for filter in filters {
            if !filter.shouldRecordLogEntry(entry) {
                return false
            }
        }
        return true
    }
    
    private func dispatcherForQueue(queue: dispatch_queue_t, synchronous: Bool)(block: dispatch_block_t)
    {
        if synchronous {
            return dispatch_sync(queue, block)
        } else {
            return dispatch_async(queue, block)
        }
    }

}
