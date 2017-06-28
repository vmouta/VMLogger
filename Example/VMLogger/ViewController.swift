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
    
    internal static let alex = "VMLogger_Example.ViewController.children.alex"
    internal static let tania = "VMLogger_Example.ViewController.children.tania"
    
    internal static let logger = AppLogger.logger(NSStringFromClass(ViewController.classForCoder()))
    
    internal static let loggerChildrenAlex = AppLogger.logger(ViewController.alex)
    internal static let loggerChildrenTania = AppLogger.logger(ViewController.tania)
    internal static let loggerChildrenGrandchildren = AppLogger.logger("VMLogger_Example.ViewController.children.grandchildren")
    
    @IBOutlet var alexLabel: UILabel!
    @IBOutlet var alexLogLevel: UISegmentedControl!
    @IBOutlet var taniaLabel: UILabel!
    @IBOutlet var taniaLogLevel: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        ViewController.loggerChildrenGrandchildren.error(self)
        ViewController.logger.info(ViewController.loggerChildrenGrandchildren.fullName())
        
        alexLabel.text = ViewController.alex
        taniaLabel.text = ViewController.tania
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
    
    @IBAction func printFileLocation(_ sender: AnyObject) {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        /// Got to command line and do a cat to the lo.txt file. (The default log configuration - print the log with colors)
        /// For a better log use tail -f and the log.txt file so that you can have a nice colorfull log
        print(url.absoluteString ?? "Something went wrong")
    }
    
    @IBAction func alexValueChange(_ sender: AnyObject) {
        let value = alexLogLevel.selectedSegmentIndex
        ViewController.logger.info("Alex new value:\(value)")
    }
    
    @IBAction func alexLogLevel(_ sender: AnyObject) {
        ViewController.logger.info()
        
        let value = alexLogLevel.selectedSegmentIndex
        switch(value) {
        case 0:
            break
        case 1:
            ViewController.loggerChildrenAlex.verbose()
        case 2:
            ViewController.loggerChildrenAlex.debug()
        case 3:
            ViewController.loggerChildrenAlex.warning()
        case 4:
            ViewController.loggerChildrenAlex.error()
        case 5:
            ViewController.loggerChildrenAlex.severe()
        case 6:
            ViewController.loggerChildrenAlex.event("AlexEvent")
        default:
            break
        }
    }
    
    @IBAction func taniaValueChange(_ sender: AnyObject) {
        let value = taniaLogLevel.selectedSegmentIndex
        ViewController.logger.info("Tania new value:\(value)")
    }
    
    @IBAction func taniaLogLevel(_ sender: AnyObject) {
        ViewController.logger.info()
        
        let value = taniaLogLevel.selectedSegmentIndex
        switch(value) {
            case 0:
                break
            case 1:
                ViewController.loggerChildrenTania.verbose()
            case 2:
                ViewController.loggerChildrenTania.debug()
            case 3:
                ViewController.loggerChildrenTania.warning()
            case 4:
                ViewController.loggerChildrenTania.error()
            case 5:
                ViewController.loggerChildrenTania.severe()
            case 6:
                ViewController.loggerChildrenTania.event("TaniaEvent")
            default:
                break
        }
    }
}


