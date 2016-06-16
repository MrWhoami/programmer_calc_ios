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
    @IBOutlet weak var characterScreen: UILabel!
    @IBOutlet weak var button8: UIButton!
    @IBOutlet weak var button9: UIButton!
    @IBOutlet weak var buttonA: UIButton!
    @IBOutlet weak var buttonB: UIButton!
    @IBOutlet weak var buttonC: UIButton!
    @IBOutlet weak var buttonD: UIButton!
    @IBOutlet weak var buttonE: UIButton!
    @IBOutlet weak var buttonF: UIButton!
    @IBOutlet weak var buttonFF: UIButton!
    
    var printMode = 10
    var expression = CalculationStack()
    var justTouchedOperator = false
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        // Change the status bar color
        return UIStatusBarStyle.LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    // Number pad has been touched.
    @IBAction func numberPadTouched(sender: UIButton) {
        if justTouchedOperator {
            // If just finish one calculation, then the screen must be cleared for new input.
            if sender.currentTitle! == "00" {
                // Of course, in this situation, 00 will be accepted as 0.
                numberScreen.text = "0"
            } else {
                numberScreen.text = sender.currentTitle!
            }
            justTouchedOperator = false
            return
        }
        
        if numberScreen.text! == "0" || numberScreen.text! == "0x0" {
            // If the screen is printing out 0, we need to replace the number.
            if sender.currentTitle! != "00" {
                // Of course, in this situation, 00 is not accepted.
                numberScreen.text = sender.currentTitle!
            }
        }
        else {
            // If the screen already has something to print out, just append the new number.
            if numberScreen.text!.characters.count < 20 {
                // But not too long, in detial, not larger than 0xffffffffffffffff (64 bits of 1)
                numberScreen.text! += sender.currentTitle!
            }
        }
    }
    
    // C button at left-top.
    @IBAction func clearTouched(sender: UIButton) {
        if printMode == 16 {
            numberScreen.text = "0x0"
        } else {
            numberScreen.text = "0"
        }
        justTouchedOperator = false
    }
    
    // AC button
    @IBAction func allClearTouched(sender: UIButton) {
        if printMode == 16 {
            numberScreen.text = "0x0"
        } else {
            numberScreen.text = "0"
        }
        expression.clearStack()
        justTouchedOperator = false
    }
    
    // "<<", ">>", "1's", "2's", "byte flip", "word flip", "RoL", "RoR"
    @IBAction func instantActions(sender: UIButton) {
        var printingNumber = UInt64.init(numberScreen.text!)!
        switch sender.currentTitle! {
        case "<<":
            printingNumber = printingNumber << 1;
        case ">>":
            printingNumber = printingNumber >> 1;
        case "1's":
            printingNumber = ~printingNumber;
        case "2's":
            printingNumber = ~printingNumber + 1;
        case "byte flip":
            // Get bytes
            var buffer = [UInt8]()
            var highest = 0
            for i in 0...7 {
                buffer[i] = UInt8(printingNumber >> UInt64(i * 8))
                highest = buffer[i] == 0 ? highest : i
            }
            // Flip bytes
            for i in 0...(highest / 2) {
                let tmp = buffer[i]
                buffer[i] = buffer[highest - i]
                buffer[highest - i] = tmp
            }
            // Get the result
            printingNumber = 0
            for i in 0...7 {
                printingNumber |= UInt64(buffer[i]) << UInt64(i * 8)
            }
        case "word flip":
            // Get words
            var buffer = [UInt16]()
            var highest = 0
            for i in 0...3 {
                buffer[i] = UInt16(printingNumber >> UInt64(i * 16))
                highest = buffer[i] == 0 ? highest : i
            }
            // Flip words
            for i in 0...(highest / 2) {
                let tmp = buffer[i]
                buffer[i] = buffer[highest - i]
                buffer[highest - i] = tmp
            }
            // Get the result
            printingNumber = 0
            for i in 0...3 {
                printingNumber |= UInt64(buffer[i]) << UInt64(i * 16)
            }
        case "RoL":
            let tmp = printingNumber & (UInt64.max - UInt64.max >> 1)
            printingNumber <<= 1
            if tmp != 0 {
                printingNumber |= 1
            }
        case "RoR":
            let tmp = printingNumber & 1
            printingNumber >>= 1
            if tmp != 0 {
                printingNumber |= (UInt64.max - UInt64.max >> 1)
            }
        default:
            print("Unknown operator in instantAction: \(sender.currentTitle!).\n")
        }
        numberScreen.text = printingNumber.description
        justTouchedOperator = true
    }
    
    // "+", "-", "*", "/", "=", "X<<Y", "X>>Y", "AND", "OR", "NOR", "XOR"
    @IBAction func normalCalculationTouched(sender: UIButton) {
        var printingNumber = UInt64.init(numberScreen.text!)!
        do {
            try printingNumber = expression.pushOperator(printingNumber, symbol: sender.currentTitle!)
            numberScreen.text = printingNumber.description
            justTouchedOperator = true
        } catch CalculatorError.InvalidOperand(_){
            numberScreen.text = "0"
        } catch {
            numberScreen.text = "0"
        }
    }
}

