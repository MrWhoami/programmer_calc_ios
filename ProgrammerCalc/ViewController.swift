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
    let disabledColor = UIColor.lightGrayColor()
    let enabledColor = UIColor.blackColor()
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        // Change the status bar color
        return UIStatusBarStyle.LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        button8.setTitleColor(enabledColor, forState: UIControlState.Normal)
        button9.setTitleColor(enabledColor, forState: UIControlState.Normal)
        buttonA.setTitleColor(enabledColor, forState: UIControlState.Normal)
        buttonB.setTitleColor(enabledColor, forState: UIControlState.Normal)
        buttonC.setTitleColor(enabledColor, forState: UIControlState.Normal)
        buttonD.setTitleColor(enabledColor, forState: UIControlState.Normal)
        buttonE.setTitleColor(enabledColor, forState: UIControlState.Normal)
        buttonF.setTitleColor(enabledColor, forState: UIControlState.Normal)
        buttonFF.setTitleColor(enabledColor, forState: UIControlState.Normal)
        button8.setTitleColor(disabledColor, forState: UIControlState.Disabled)
        button9.setTitleColor(disabledColor, forState: UIControlState.Disabled)
        buttonA.setTitleColor(disabledColor, forState: UIControlState.Disabled)
        buttonB.setTitleColor(disabledColor, forState: UIControlState.Disabled)
        buttonC.setTitleColor(disabledColor, forState: UIControlState.Disabled)
        buttonD.setTitleColor(disabledColor, forState: UIControlState.Disabled)
        buttonE.setTitleColor(disabledColor, forState: UIControlState.Disabled)
        buttonF.setTitleColor(disabledColor, forState: UIControlState.Disabled)
        buttonFF.setTitleColor(disabledColor, forState: UIControlState.Disabled)
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
                if printMode == 16 {
                    numberScreen.text = "0x0"
                } else {
                    numberScreen.text = "0"
                }
            } else {
                // Other situations, just replace the printing number.
                if printMode == 16 {
                    numberScreen.text = "0x" + sender.currentTitle!
                } else {
                    numberScreen.text = sender.currentTitle!
                }
            }
            justTouchedOperator = false
            return
        }
        
        // If the screen do dot need to refresh.
        if numberScreen.text! == "0" {
            // If the screen is printing out 0, we need to replace the number.
            if sender.currentTitle! != "00" {
                // Of course, in this situation, 00 is not accepted.
                numberScreen.text = sender.currentTitle!
            }
        }
        else if numberScreen.text! == "0x0" {
            // If the screen is printing out 0x0, we need to replace the number.
            if sender.currentTitle! != "00" {
                // Of course, in this situation, 00 is not accepted.
                numberScreen.text = "0x" + sender.currentTitle!
            }
        }
        else {
            // If the screen already has something to print out, just append the new number.
            var printingStr:String
            if printMode == 16 {
                printingStr = numberScreen.text!.substringFromIndex(numberScreen.text!.startIndex.advancedBy(2))
            } else {
                printingStr = numberScreen.text!
            }
            printingStr += sender.currentTitle!
            if UInt64(printingStr, radix: printMode) == nil {
                printingStr = String(UInt64.max, radix: printMode).uppercaseString
            }
            if printMode == 16 {
                numberScreen.text = "0x" + printingStr
            } else {
                numberScreen.text = printingStr
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
        var printingNumber = UInt64(printMode == 16 ? numberScreen.text!.substringFromIndex(numberScreen.text!.startIndex.advancedBy(2)) : numberScreen.text!, radix: printMode)!
        switch sender.currentTitle! {
        case "<<":
            printingNumber = printingNumber << 1;
        case ">>":
            printingNumber = printingNumber >> 1;
        case "1's":
            printingNumber = ~printingNumber;
        case "2's":
            printingNumber = ~printingNumber &+ 1;
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
        if printMode == 16 {
            numberScreen.text = "0x" + String(printingNumber, radix: printMode)
        } else {
            numberScreen.text = String(printingNumber, radix: printMode)
        }
        justTouchedOperator = true
    }
    
    // "+", "-", "*", "/", "=", "X<<Y", "X>>Y", "AND", "OR", "NOR", "XOR"
    @IBAction func normalCalculationTouched(sender: UIButton) {
        var printingNumber = UInt64(printMode == 16 ? numberScreen.text!.substringFromIndex(numberScreen.text!.startIndex.advancedBy(2)) : numberScreen.text!, radix: printMode)!
        do {
            try printingNumber = expression.pushOperator(printingNumber, symbol: sender.currentTitle!)
            if printMode == 16 {
                numberScreen.text = "0x" + String(printingNumber, radix: printMode)
            } else {
                numberScreen.text = String(printingNumber, radix: printMode)
            }
            justTouchedOperator = true
        } catch {
            if printMode == 16 {
                numberScreen.text = "0x0"
            } else {
                numberScreen.text = "0"
            }
        }
    }
    
    @IBAction func printingModeControl(sender: UISegmentedControl) {
        let printingNumber = UInt64(printMode == 16 ? numberScreen.text!.substringFromIndex(numberScreen.text!.startIndex.advancedBy(2)) : numberScreen.text!, radix: printMode)!
        switch sender.selectedSegmentIndex {
        case 0:
            printMode = 8
            numberScreen.text = String(printingNumber, radix: 8)
            changeNumberPadStatus(8)
        case 1:
            printMode = 10
            numberScreen.text = String(printingNumber, radix: 10)
            changeNumberPadStatus(10)
        case 2:
            printMode = 16
            numberScreen.text = "0x" + String(printingNumber, radix: 16)
            changeNumberPadStatus(16)
        default:
            print("Unknown mode in printingModeControl: \(sender.selectedSegmentIndex)\n")
        }
    }
    
    // MARK: tools
    private func changeNumberPadStatus(radix: Int) {
        switch radix {
        case 8:
            button8.enabled = false
            button9.enabled = false
            buttonA.enabled = false
            buttonB.enabled = false
            buttonC.enabled = false
            buttonD.enabled = false
            buttonE.enabled = false
            buttonF.enabled = false
            buttonFF.enabled = false
        case 10:
            button8.enabled = true
            button9.enabled = true
            buttonA.enabled = false
            buttonB.enabled = false
            buttonC.enabled = false
            buttonD.enabled = false
            buttonE.enabled = false
            buttonF.enabled = false
            buttonFF.enabled = false
        case 16:
            button8.enabled = true
            button9.enabled = true
            buttonA.enabled = true
            buttonB.enabled = true
            buttonC.enabled = true
            buttonD.enabled = true
            buttonE.enabled = true
            buttonF.enabled = true
            buttonFF.enabled = true
        default:
            print("Error while changing number pad statusn")
        }
    }
}

