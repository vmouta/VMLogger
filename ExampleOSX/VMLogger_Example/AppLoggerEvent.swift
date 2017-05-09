/**
 * @name             AppLogger.swift
 * @partof           zucred AG
 * @description
 * @author	 		Vasco Mouta
 * @created			22/09/16
 *
 * Copyright (c) 2016 zucred AG All rights reserved.
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

open class AppLoggerEvent: NSObject
{
    open static let GROUP:String = "Group"
    open static let TYPE:String = "Type"
    open static let PARAMS:String = "Params"
    
    open static let ERROR:String = "Error"
    
    open static let EVENT:String = "Event"
    open static let LOG:String = "Log"
    open static let UI:String = "UI"
    open static let UI_SCREENDISPLAY:String = "Display"
    open static let UI_SCREENDISPLAYDURATION:String = "DisplayDuration"
    
    open static let NAME:String = "name"
    open static let LABEL:String = "label"
    open static let VALUE:String = "value"
    
    open static let CLASS:String = "class"
    
    internal var requestValues: [String:Any] = [PARAMS:[String:Any]()]
    
    open static func createViewEvent(_ name: String) -> AppLoggerEvent {
        return createEvent(AppLoggerEvent.UI, action: UI_SCREENDISPLAY, label: name, value: nil)
    }
    
    open static func createViewEvent(_ name: String, params: [String:Any]) -> AppLoggerEvent {
        let appEvent = createEvent(AppLoggerEvent.UI, type: UI_SCREENDISPLAY, params: params)
        appEvent.set(name, forKey: AppLoggerEvent.LABEL)
        return appEvent
    }
    
    open static func createViewDurationEvent(_ name: String, duration: Double) -> AppLoggerEvent {
        return createEvent(AppLoggerEvent.UI, action: UI_SCREENDISPLAYDURATION, label: name, value:"\(duration)")
    }
    
    open static func createViewDurationEvent(_ name: String, duration: Double, params: [String:Any]) -> AppLoggerEvent {
        let appEvent = createEvent(AppLoggerEvent.UI, type: UI_SCREENDISPLAYDURATION, params:params)
        appEvent.set(name, forKey: AppLoggerEvent.LABEL)
        appEvent.set("\(duration)", forKey: AppLoggerEvent.VALUE)
        return appEvent
    }
    
    /**
     Returns a GAIDictionaryBuilder object with parameters specific to an event hit.
    :
     - parameter category: <#category description#>
     - parameter action:   <#action description#>
     - parameter label:    <#label description#>
     - parameter value:    <#value description#>
     */
    open static func createEvent(_ category: String, action: String, label: String?, value: String?) -> AppLoggerEvent {
        return AppLoggerEvent(category: category, action: action, label: label, value: value)
    }
    
    open static func createEvent(_ group: String, type: String, params: [String:Any]) -> AppLoggerEvent {
        return AppLoggerEvent(group: group, type: type, params: params)
    }
    
    internal override init() {
        super.init()
    }
    
    internal init(group: String, type: String, params: [String:Any]) {
        super.init()
        requestValues[AppLoggerEvent.GROUP] = group
        requestValues[AppLoggerEvent.TYPE] = type
        setAllParams(params)
    }
    
    internal init(category: String, action: String, label: String?, value: String?) {
        super.init()
        requestValues[AppLoggerEvent.GROUP] = category as AnyObject?
        requestValues[AppLoggerEvent.TYPE] = action as AnyObject?
        if label != nil {
            set(label, forKey: AppLoggerEvent.LABEL)
        }
        
        if value != nil {
            set(value, forKey: AppLoggerEvent.VALUE)
        }
    }
    
    @discardableResult
    open func set(_ value: String!, forKey key: String!) -> AppLoggerEvent! {
        guard var paramsDic = requestValues[AppLoggerEvent.PARAMS] as? [String:AnyObject] else {
            return nil
        }
        paramsDic[key] = value as AnyObject?
        setAllParams(paramsDic)
        return self
    }
    
    /*!
     * Copies all the name-value pairs from params into this object, ignoring any
     * keys that are not NSString and any values that are neither NSString or
     * NSNull.
     */
    @discardableResult
    open func setAll(_ values: [String:AnyObject]) -> AppLoggerEvent! {
        requestValues = values
        return self
    }
    
    /*!
     * Copies all the name-value pairs from params into this object, ignoring any
     * keys that are not NSString and any values that are neither NSString or
     * NSNull.
     */
    @discardableResult
    open func setAllParams(_ params: [String:Any]) -> AppLoggerEvent! {
        requestValues[AppLoggerEvent.PARAMS] = params
        return self
    }
    
    /*!
     * Returns the value for the input parameter paramName, or nil if paramName
     * is not present.
     */
    open func get(_ paramName: String!) -> String! {
        guard let value = requestValues[paramName] as? String else {
            guard let paramsDic = requestValues[AppLoggerEvent.PARAMS] as? [String:AnyObject] else {
                return nil
            }
            guard let paramValue = paramsDic[paramName] as? String else {
                return nil
            }
            return paramValue
        }
        return value
    }
    
    /*!
     * Return an NSMutableDictionary object with all the parameters set in this
     */
    open func build() -> [String:Any] {
        return requestValues
    }
    
    func customDescription() -> String {
        var jsonString:String?
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self.build(), options: JSONSerialization.WritingOptions.prettyPrinted)
            jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print(error)
        }
        return (jsonString != nil ? "\n\(jsonString!)" : "wrong json format:\(self.build())")
    }
    
    override open var description: String {
        return customDescription()
    }
}
