/**
 * @name            URLLogAppend.swift
 * @partof          zucred AG
 * @description
 * @author	 		Vasco Mouta
 * @created			19/09/16
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
import Alamofire

struct URLLogAppendContants {
    static let ServerUrl: String = "url"
    static let Headers: String = "headers"
    static let Method: String = "method"
    static let Parameter: String = "parameter"
}

/**
A `LogRecorder` implementation that stores log messages in a file.

**Note:** This implementation provides no mechanism for log file rotation
or log pruning. It is the responsibility of the developer to keep the log
file at a reasonable size. Use `DailyRotatingLogFileRecorder` instead if you'd 
rather not have to think about such details.
*/
open class URLLogAppend: BaseLogAppender
{
    internal let url: String

    internal let headers: Dictionary<String, String>
    
    internal let method: String
    
    internal let parameter: String?

    /**
    Attempts to initialize a new `FileLogRecorder` instance to use the
    given file path and log formatters. This will fail if `filePath` could
    not be opened for writing.
    
    :param:     url
     
    :param:     apiKey
    
    :param:     formatters The `LogFormatter`s to use for the recorder.
    */
    public convenience init?(url: String, method:String, parameter:String?, headers: Dictionary<String, String>, formatters: [LogFormatter] = [DefaultLogFormatter()])
    {
        self.init(name: "URLLogRecorder[\(url)]", url:url, method: method, parameter: parameter, headers: headers, formatters: formatters)
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
    public init?(name:String, url:String, method:String, parameter:String?, headers: Dictionary<String, String>, formatters: [LogFormatter] = [DefaultLogFormatter()], filters:[LogFilter] = [])
    {
        self.url = url
        self.method = method
        self.headers = headers
        self.parameter = parameter
        super.init(name:name, formatters: formatters, filters:filters)
    }

    public required convenience init?(configuration: Dictionary<String, AnyObject>) {
        guard let config = type(of: self).URLLogConfiguration(configuration) else {
            return nil
        }
        
        self.init(name:config.name, url:config.url, method:config.method, parameter:config.parameter, headers:config.headers, formatters:config.formatters, filters:config.filters)
    }
    
    internal class func URLLogConfiguration(_ configuration: Dictionary<String, AnyObject>) -> (name: String, url:String, method:String, parameter:String?, headers: Dictionary<String, String>, formatters: [LogFormatter], filters: [LogFilter])?  {
        
        guard let config = self.configuration(configuration: configuration) else {
            return nil
        }
        
        guard let url = configuration[URLLogAppendContants.ServerUrl] as?  String  else {
            return nil
        }
        
        guard let headers = configuration[URLLogAppendContants.Headers] as?  Dictionary<String, String>  else {
            return nil
        }
        
        guard let method = configuration[URLLogAppendContants.Method] as?  String  else {
            return nil
        }
        
        let parameter = configuration[URLLogAppendContants.Parameter] as?  String
        
        return (config.0, url, method, parameter, headers, config.1, config.2)
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
        let URL = Foundation.URL(string: self.url)!
        var URLRequest = NSMutableURLRequest(url: URL)
        URLRequest.httpMethod = self.method
        switch URLRequest.httpMethod {
            case "GET":
                if parameter != nil {
                    
                    //TODO
                    //URLRequest = try URLEncoding.queryString.encode(URLRequest as! URLRequestConvertible, with: [self.parameter!:message])
                }
                break
            default:
                URLRequest.httpBody = (message as NSString).data(using: String.Encoding.utf8.rawValue)
                break
        }
        
        setRequestHeaders(URLRequest)
        request(URLRequest as! URLRequestConvertible)
    }
    
    internal func request(_ URLRequest: URLRequestConvertible) -> Request {
        return Alamofire.request(URLRequest)
    }
    
    internal func setRequestHeaders (_ request: NSMutableURLRequest) -> Void {
        for key in self.headers.keys {
            /* Todo add specific values about the app */
            if let value = self.headers[key] {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
    }
}

