/**
 * @name            XcodeColor.swift
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
    
public struct XcodeColor {
    public static let escape = "\u{001b}["
    public static let resetFg = "\u{001b}[fg;"
    public static let resetBg = "\u{001b}[bg;"
    public static let reset = "\u{001b}[;"
    
    public var fg: (Int, Int, Int)? = nil
    public var bg: (Int, Int, Int)? = nil
    
    public func format() -> String {
        guard fg != nil || bg != nil else {
            // neither set, return reset value
            return XcodeColor.reset
        }
        
        var format: String = ""
        
        if let fg = fg {
            format += "\(XcodeColor.escape)fg\(fg.0),\(fg.1),\(fg.2);"
        }
        else {
            format += XcodeColor.resetFg
        }
        
        if let bg = bg {
            format += "\(XcodeColor.escape)bg\(bg.0),\(bg.1),\(bg.2);"
        }
        else {
            format += XcodeColor.resetBg
        }
        
        return format
    }
    
    public init(fg: (Int, Int, Int)? = nil, bg: (Int, Int, Int)? = nil) {
        self.fg = fg
        self.bg = bg
    }
    
    #if os(OSX)
    public init(fg: NSColor, bg: NSColor? = nil) {
    if let fgColorSpaceCorrected = fg.colorUsingColorSpaceName(NSCalibratedRGBColorSpace) {
    self.fg = (Int(fgColorSpaceCorrected.redComponent * 255), Int(fgColorSpaceCorrected.greenComponent * 255), Int(fgColorSpaceCorrected.blueComponent * 255))
    }
    else {
    self.fg = nil
    }
    
    if let bg = bg,
    let bgColorSpaceCorrected = bg.colorUsingColorSpaceName(NSCalibratedRGBColorSpace) {
    
    self.bg = (Int(bgColorSpaceCorrected.redComponent * 255), Int(bgColorSpaceCorrected.greenComponent * 255), Int(bgColorSpaceCorrected.blueComponent * 255))
    }
    else {
    self.bg = nil
    }
    }
    #else
    public init(fg: UIColor, bg: UIColor? = nil) {
        var redComponent: CGFloat = 0
        var greenComponent: CGFloat = 0
        var blueComponent: CGFloat = 0
        var alphaComponent: CGFloat = 0
        
        fg.getRed(&redComponent, green: &greenComponent, blue: &blueComponent, alpha:&alphaComponent)
        self.fg = (Int(redComponent * 255), Int(greenComponent * 255), Int(blueComponent * 255))
        if let bg = bg {
            bg.getRed(&redComponent, green: &greenComponent, blue: &blueComponent, alpha:&alphaComponent)
            self.bg = (Int(redComponent * 255), Int(greenComponent * 255), Int(blueComponent * 255))
        }
        else {
            self.bg = nil
        }
    }
    #endif
    
    public static var defaultXcodeColors: [LogLevel: XcodeColor] = [
        .Verbose: .lightGrey,
        .Debug: .darkGrey,
        .Info: .blue,
        .Warning: .orange,
        .Error: .red,
        .Severe: .whiteOnRed
    ]
    
    public static let red: XcodeColor = {
        return XcodeColor(fg: (255, 0, 0))
    }()
    
    public static let green: XcodeColor = {
        return XcodeColor(fg: (0, 255, 0))
    }()
    
    public static let blue: XcodeColor = {
        return XcodeColor(fg: (0, 0, 255))
    }()
    
    public static let black: XcodeColor = {
        return XcodeColor(fg: (0, 0, 0))
    }()
    
    public static let white: XcodeColor = {
        return XcodeColor(fg: (255, 255, 255))
    }()
    
    public static let lightGrey: XcodeColor = {
        return XcodeColor(fg: (211, 211, 211))
    }()
    
    public static let darkGrey: XcodeColor = {
        return XcodeColor(fg: (169, 169, 169))
    }()
    
    public static let orange: XcodeColor = {
        return XcodeColor(fg: (255, 165, 0))
    }()
    
    public static let whiteOnRed: XcodeColor = {
        return XcodeColor(fg: (255, 255, 255), bg: (255, 0, 0))
    }()
    
    public static let darkGreen: XcodeColor = {
        return XcodeColor(fg: (0, 128, 0))
    }()
}
