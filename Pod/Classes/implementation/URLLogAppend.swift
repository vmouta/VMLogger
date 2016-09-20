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
public class URLLogAppend: BaseLogAppender
{
    private let url: String

    private let headers: Dictionary<String, String>
    
    private let method: String
    
    private let parameter: String?

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
        guard let url = configuration[URLLogAppendContants.ServerUrl] as?  String  else {
            return nil
        }
        
        guard let headers = configuration[URLLogAppendContants.Headers] as?  Dictionary<String, String>  else {
            return nil
        }
        
        guard let method = configuration[URLLogAppendContants.Method] as?  String  else {
            return nil
        }
        
        guard let config = self.dynamicType.configuration(configuration) else {
            return nil
        }
        
        let parameter = configuration[URLLogAppendContants.Parameter] as?  String
        
        self.init(name:config.name, url:url, method: method, parameter:parameter, headers:headers, formatters:config.formatters, filters:config.filters)
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
    public override func recordFormattedMessage(message: String, forLogEntry entry: LogEntry, currentQueue: dispatch_queue_t, synchronousMode: Bool)
    {
        let URL = NSURL(string: self.url)!
        var URLRequest = NSMutableURLRequest(URL: URL)
        URLRequest.HTTPMethod = self.method
        switch URLRequest.HTTPMethod {
            case "GET":
                if parameter != nil {
                    URLRequest = Alamofire.ParameterEncoding.URL.encode(URLRequest, parameters:[self.parameter!:message]).0
                }
                break
            default:
                URLRequest.HTTPBody = (message as NSString).dataUsingEncoding(NSUTF8StringEncoding)
                break
        }
        
        setRequestHeaders(URLRequest)
        Alamofire.request(URLRequest)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                print(response)
                //to get status code
                let status = response.response?.statusCode
                //to get JSON return value
                let result = response.result.value
        }
    }
    
    internal func setRequestHeaders (request: NSMutableURLRequest) -> Void {
        for key in self.headers.keys {
            /* Todo add specific values about the app */
            if let value = self.headers[key] {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
    }
}

