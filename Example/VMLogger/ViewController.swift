//
//  ViewController.swift
//  VMLogger
//
//  Created by Vasco Mouta on 12/14/2015.
//  Copyright (c) 2015 Vasco Mouta. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    internal static let logger = AppLogger.logger(NSStringFromClass(ViewController.classForCoder()))
    
    internal static let logger1 = AppLogger.logger("VMLogger-Example.ViewController.children.grandchildren")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ViewController.logger1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func dump(sender: AnyObject) {
        AppLogger.dump()
    }
}

