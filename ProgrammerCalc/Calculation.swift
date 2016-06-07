//
//  Calculation.swift
//  ProgrammerCalc
//
//  Created by LiuJiyuan on 5/30/16.
//  Copyright © 2016 Joel Liu. All rights reserved.
//

import Foundation

enum CalculatorError: ErrorType {
    case InvalidOperator(symbol: String)
    case InvalidOperand(operand: UInt64)
    case OperandTooLarge
}

class CalculationStack {
    private var operandStack = [UInt64]()
    private var operatorStack =  [String]()
    
    // Get a new operand and a operator.
    // Accept "+", "-", "*", "/", "X<<Y", "X>>Y", "=" as operators.
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
        // But firstly, if this is a "+" or "-", we can clear the stack and calculate now.
        if symbol == "+" || symbol == "-"  {
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
            default:
                throw CalculatorError.InvalidOperator(symbol: symbol)
            }
            operandStack.append(result)
        }
        if operandStack.count > 1 {
            operandStack.removeFirst(operandStack.count - 1)
        }
    }
}