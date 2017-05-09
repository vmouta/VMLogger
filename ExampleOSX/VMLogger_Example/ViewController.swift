//
//  ViewController.swift
//  VMLogger_Example
//
//  Created by Vasco Mouta on 09.05.17.
//  Copyright © 2017 Sonova AG. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    internal static let logger = AppLogger.logger(NSStringFromClass(ViewController.classForCoder()))
    internal static let loggerChildrenGrandchildren = AppLogger.logger("VMLogger_Example.ViewController.children.grandchildren")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ViewController.loggerChildrenGrandchildren.error(self)
        ViewController.logger.info(ViewController.loggerChildrenGrandchildren.fullName())
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

