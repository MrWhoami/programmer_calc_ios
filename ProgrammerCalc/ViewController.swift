//
//  ViewController.swift
//  ProgrammerCalc
//
//  Created by LiuJiyuan on 5/24/16.
//  Copyright © 2016 Joel Liu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // MARK: Properties
    @IBOutlet weak var numberScreen: UILabel!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        // Change the status bar color
        return UIStatusBarStyle.LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Change status bar color
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

