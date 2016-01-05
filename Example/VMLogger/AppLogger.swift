/**
* @name             AppLogger.swift
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
import VMLogger

/// Class to encapsulate the Log class to avoid carring around VMLogger dependence
public class AppLogger : Log {
    
    public static func logger(identifier: String) -> AppLogger {
        return super.getLogger(identifier) as! AppLogger
    }
    
    public static func dump() {
        super.dumpLog()
    }
}
