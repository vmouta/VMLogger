//
//  ViewController.swift
//  VMLogger
//
//  Created by Vasco Mouta on 12/14/2015.
//  Copyright (c) 2015 Vasco Mouta. All rights reserved.
//

import UIKit
import VMLogger

class ViewController: UIViewController {

    internal static let logger = AppLogger.logger(NSStringFromClass(ViewController.classForCoder()))
    internal static let loggerChildrenGrandchildren = AppLogger.logger("VMLogger_Example.ViewController.children.grandchildren")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ViewController.loggerChildrenGrandchildren.error(self)
        ViewController.logger.info(ViewController.loggerChildrenGrandchildren.fullName())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func dump(_ sender: AnyObject) {
        AppLogger.dump()
    }
    
    @IBAction func printFile(_ sender: AnyObject) {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        let filePath = url.appendingPathComponent("log.txt")?.path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath!) {
            print("***** FILE AVAILABLE ***** ")
            if let readString = try? String(contentsOfFile: filePath!, encoding: String.Encoding.utf8) {
                print(readString)
            }
        } else {
            print("*****  FILE NOT AVAILABLE ***** ")
        }
    }
}

