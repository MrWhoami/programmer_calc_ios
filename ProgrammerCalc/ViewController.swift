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
    
    // "<<", ">>"
    @IBAction func instantActions(sender: UIButton) {
        var printingNumber = UInt64.init(numberScreen.text!)!
        if sender.currentTitle! == "<<" {
            printingNumber = printingNumber << 1;
        } 
        else {
            printingNumber = printingNumber >> 1;
        }
        do {
            try printingNumber = expression.pushOperator(printingNumber, symbol: "=")
            numberScreen.text = printingNumber.description
            justTouchedOperator = true
        } catch CalculatorError.InvalidOperand(_){
            numberScreen.text = "0"
        } catch CalculatorError.InvalidOperator(_){
            numberScreen.text = "0"
        } catch {
            numberScreen.text = "0"
        }
    }
    
    // "+", "-", "*", "/", "=", "X<<Y", "X>>Y"
    @IBAction func normalCalculationTouched(sender: UIButton) {
        var printingNumber = UInt64.init(numberScreen.text!)!
        do {
            try printingNumber = expression.pushOperator(printingNumber, symbol: sender.currentTitle!)
            numberScreen.text = printingNumber.description
            justTouchedOperator = true
        } catch CalculatorError.InvalidOperand(_){
            numberScreen.text = "0"
        } catch CalculatorError.InvalidOperator(_){
            numberScreen.text = "0"
        } catch {
            numberScreen.text = "0"
        }
    }

    // "AND", "OR", "NOR", "XOR"
    @IBAction func logicalCalculationTouched(sender: UIButton) {
        var printingNumber = UInt64.init(numberScreen.text!)!
        do {
            try printingNumber = expression.pushOperator(printingNumber, symbol: "=")
            // Push logical operator.
            numberScreen.text = printingNumber.description
            justTouchedOperator = true
        } catch CalculatorError.InvalidOperand(_){
            numberScreen.text = "0"
        } catch CalculatorError.InvalidOperator(_){
            numberScreen.text = "0"
        } catch {
            numberScreen.text = "0"
        }
    }
}

