//
//  Expression.swift
//  CountOnMe
//
//  Created by Vincent Caronnet on 11/04/2021.
//  Copyright © 2021 Vincent Saluzzo. All rights reserved.
//

import Foundation

class Expression {
    var elements = [String]() {
        didSet {
            let notification = Notification(name: .udpatedExpression)
            NotificationCenter.default.post(notification)
        }
    }
    
    // Error check computed variables
    var isCorrect: Bool {
        return elements.last != "+" && elements.last != "-"
    }
    
    var haveEnoughElement: Bool {
        return elements.count >= 3
    }
    
    var canAddOperator: Bool {
        return elements.last != "+" && elements.last != "-"
    }
    
    var haveResult: Bool {
        return elements.firstIndex(of: "=") != nil
    }
    
    enum ExpressionError {
        case connection
        case undefined
        case response
        case statusCode
        case data
        case pictures
    }
    enum Element {
        case number(String),
             plus,
             minus,
             equal
    }
    
    func add(element: Element) {
        switch element {
        case .number(let string):
            if haveResult {
                elements = []
            }
            elements.append(string)
        case .plus, .minus:
            guard canAddOperator else {
                let notification = Notification(name: .operatorAlreadySet)
                NotificationCenter.default.post(notification)
                return
            }
            let op = getOperatorString(from: element)
            elements.append(op)
        case .equal:
            setResult()
        }
    }
    private func setResult() {
        print("plus")
        guard isCorrect else {
            let notification = Notification(name: .notCorrectExpression)
            NotificationCenter.default.post(notification)
            return
        }
        
        guard haveEnoughElement else {
            let notification = Notification(name: .notEnoughElement)
            NotificationCenter.default.post(notification)
            return
        }
        
        // Create local copy of operations
        var operationsToReduce = elements
        
        // Iterate over operations while an operand still here
        while operationsToReduce.count > 1 {
            let left = Int(operationsToReduce[0])!
            let operand = operationsToReduce[1]
            let right = Int(operationsToReduce[2])!
            
            let result: Int
            switch operand {
            case "+": result = left + right
            case "-": result = left - right
            default: fatalError("Unknown operator !")
            }
            
            operationsToReduce = Array(operationsToReduce.dropFirst(3))
            operationsToReduce.insert("\(result)", at: 0)
        }
        
        let array = ["=", "\(operationsToReduce.first!)"]
//        elements.append("= \(operationsToReduce.first!)")
        elements = elements + array
    }
    private func getOperatorString(from element: Element) -> String {
        switch element {
        case .plus:
            return "+"
        case .minus:
            return "-"
        default:
            fatalError("This is not an operator!")
        }
    }
}

extension Notification.Name {
    static let udpatedExpression = Notification.Name("udpatedExpression")
    static let operatorAlreadySet = Notification.Name("operatorAlreadySet")
    static let notCorrectExpression = Notification.Name("notCorrectExpression")
    static let notEnoughElement = Notification.Name("notEnoughElement")
}