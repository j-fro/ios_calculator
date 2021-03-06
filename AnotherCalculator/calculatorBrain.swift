//
//  calculatorBrain.swift
//  AnotherCalculator
//
//  Created by Jacob Froman on 2/25/17.
//  Copyright © 2017 Jacob Froman. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private var accumulator = 0.0
    private var internalProgram = [AnyObject]()
    
    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand as AnyObject)
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol as AnyObject)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let constVal):
                accumulator = constVal
            case .UnaryOperation(let function):
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                executeBinaryOperation()
                pending = PendingBinaryOperation(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                executeBinaryOperation()
                
            }
        }
    }
    
    private func executeBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    private var pending: PendingBinaryOperation?
    
    private var operations: Dictionary<String, Operation> = [
        "π": .Constant(M_PI),
        "e": .Constant(M_E),
        "√": .UnaryOperation(sqrt),
        "x": .BinaryOperation({ $0 * $1 }),
        "/": .BinaryOperation({ $0 / $1 }),
        "-": .BinaryOperation({ $0 - $1 }),
        "+": .BinaryOperation({ $0 + $1 }),
        "=": .Equals
    ]
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    private struct PendingBinaryOperation {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand: operand)
                    } else if let operation = op as? String {
                        performOperation(symbol: operation)
                    }
                }
            }
        }
    }
    
    func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
}
