//
//  Calculation.swift
//  ProgrammerCalc
//
//  Created by LiuJiyuan on 5/30/16.
//  Copyright © 2016 Joel Liu. All rights reserved.
//

import Foundation

enum CalculatorError: ErrorType {
    case InvalidOperand(operand: UInt64)
    case OperandTooLarge
}

class CalculationStack {
    private var operandStack = [UInt64]()
    private var operatorStack =  [String]()
    
    // The priority is based on the priority of Swift operators.
    // Reference: https://developer.apple.com/library/ios/documentation/Swift/Reference/Swift_StandardLibrary_Operators/index.html#//apple_ref/doc/uid/TP40016054
    private func getPriority(symbol: String) -> Int {
        switch symbol {
        case "X<<Y", "X>>Y":
            return 160
        case "×", "÷", "AND":
            return 150
        case "+", "-", "OR", "NOR", "XOR":
            return 140
        default:
            print("Unknown operator in getPriority: \(symbol)\n")
            return 0
        }
    }
    
    // Get a new operand and a operator.
    // Accept "+", "-", "*", "/", 
    // "X<<Y", "X>>Y", "=" , "AND", "OR", "NOR", "XOR" as operators.
    func pushOperator(operand: UInt64, symbol: String) throws -> UInt64 {
        // Get the previous operand first.
        operandStack.append(operand)
        
        // If the symbol is "=", just calculate the expression.
        if symbol == "=" {
            try calculate()
            return operandStack.popLast()!
        }
        
        // If there is no operator in the stack, let this one be the first.
        if operatorStack.count == 0 {
            operatorStack.append(symbol)
            return operandStack.last!
        }
        
        // If this is not the first operator, push it into the stack.
        // Before push the symbol into the stack, check priority first.
        // If the priority is the lowest(140), just calculate the expression first.
        if getPriority(symbol) == 140 {
            try calculate()
        }
        operatorStack.append(symbol)
        return operandStack.last!
    }
    
    // Clear the stack without any other actions.
    func clearStack() {
        operatorStack = []
        operandStack = []
    }
    
    // Calculate the expression, the result will be storaged in the stack.
    func calculate() throws {
        while !operatorStack.isEmpty {
            let operandB = operandStack.popLast()!
            let operandA = operandStack.popLast()!
            let symbol = operatorStack.popLast()!
            var result:UInt64
            switch symbol {
            case "+":
                result = operandA + operandB
            case "-":
                result = operandA - operandB
            case "×":
                result = operandA * operandB
            case "÷":
                guard operandB != 0 else {
                    throw CalculatorError.InvalidOperand(operand: operandB)
                }
                result = operandA / operandB
            case "X<<Y":
                result = operandA << operandB
            case "X>>Y":
                result = operandA >> operandB
            case "AND":
                result = operandA & operandB
            case "OR":
                result = operandA | operandB
            case "XOR":
                result = operandA ^ operandB
            case "NOR":
                result = ~(operandA | operandB)
            default:
                // In fact, we can never reach here since all the operators are provided.
                print("Unknown operator in getPriority: \(symbol)\n")
                result = 0
            }
            operandStack.append(result)
        }
        if operandStack.count > 1 {
            operandStack.removeFirst(operandStack.count - 1)
        }
    }
}
