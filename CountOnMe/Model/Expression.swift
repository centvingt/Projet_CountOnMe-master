//
//  Expression.swift
//  CountOnMe
//
//  Created by Vincent Caronnet on 11/04/2021.
//  Copyright © 2021 Vincent Saluzzo. All rights reserved.
//

import Foundation

class Expression {
    // Expression's parts
    var elements = [String]() {
        // Notification is posted each time elements is modified
        didSet {
            let notification = Notification(name: .udpatedExpression)
            NotificationCenter.default.post(notification)
        }
    }
    
    // Elements added by user to expression
    enum Element {
        case number(String),
             plus,
             minus,
             time,
             dividedBy,
             equal
    }
    
    // Expression is correct if last element isn't an operator
    private var isCorrect: Bool {
        return elements.last != "+"
            && elements.last != "-"
            && elements.last != "×"
            && elements.last != "÷"
    }
    
    // Expression is incomplete if it contains less than three elements
    private var haveEnoughElement: Bool {
        return elements.count >= 3
    }
    
    /* We can only add an operator to the expression
     if its last element is not an operator */
    private var canAddOperator: Bool {
        return elements.last != "+"
            && elements.last != "-"
            && elements.last != "×"
            && elements.last != "÷"
    }
    
    // Expression have result if it contains equal
    private var hasResult: Bool {
        return elements.firstIndex(of: "=") != nil
    }
    
    // Add an element to expression
    func add(element: Element) {
        switch element {
        
        // The element to add to the expression is a number
        case .number(var string):
            // Reset expression if it already has result
            if hasResult {
                elements = []
            }
            
            // Add number to expression
            if let lastString = elements.last,
               canAddOperator {
                elements.removeLast()
                string = lastString + string
            }
            elements.append(string)
            
        // The element to add to the expression is an operator
        case .plus,
             .minus,
             .time,
             .dividedBy:
            
            /* Post notification if isn't possible
             to add an operator to the expression */
            guard canAddOperator else {
                let notification = Notification(name: .operatorAlreadySet)
                NotificationCenter.default.post(notification)
                return
            }
            
            // Add operator to expression
            let op = getOperatorString(from: element)
            elements.append(op)
            
        // The element to add to the expression is an equal
        case .equal:
            // Add result to expression
            setResult()
        }
    }
    
    // Add result to expression
    private func setResult() {
        // Post notification if expression's last element is an operator
        guard isCorrect else {
            let notification = Notification(name: .notCorrectExpression)
            NotificationCenter.default.post(notification)
            return
        }
        
        /* Post notification if expressio is incomplete
         or if it has already a result */
        guard haveEnoughElement && !hasResult else {
            let notification = Notification(name: .notEnoughElement)
            NotificationCenter.default.post(notification)
            return
        }
        
        // Get expression's result
        let result = calculate(elements: elements)
        
        // Add result to expression
        elements.append(contentsOf: ["=", "\(result)"])
    }
    
    // Run result's calculation
    private func calculate(elements: [String]) -> String {
        // Create local copy of expression's elements
        var resultElements = elements
        
        // First, run multiplications and divisions
        multiplicationsAndDivisions(resultElements: &resultElements)
        
        // Then, run additions and substractions
        additionsAndSubstractions(result: &resultElements)
        
        /* additionsAndSubstractions() obligatorily returns an array
         containing a number in a single character's string, so :
         1. resultElements.first is unwrapped with exclamation point,
         2. Float() is also unwrapped with exclamation point */
        let resultElement = resultElements.first!
        let float = Float(resultElement)!
        
        /* Returns a character's string containing :
         1. either an integer,
         1. or a floating point number with a comma in place
         in place of a period */
        return float.rounded(.down) == float.rounded(.up)
            ? String(Int(float))
            : String(float).replacingOccurrences(
                of: ".",
                with: ","
            )
    }
    
    // Process multiplications and divisions of the expression
    private func multiplicationsAndDivisions(resultElements: inout [String]) {
        // Iterate over operations while an operator still here
        while resultElements.contains("×") || resultElements.contains("÷") {
            /* Get :
             1. index of operator in array,
             1. the operation's numbers */
            guard
                let opIndex = resultElements.firstIndex(
                    where: { (string) -> Bool in
                        string == "×" || string == "÷"
                    }
                ),
                let left = Float(resultElements[opIndex - 1]),
                let right = Float(resultElements[opIndex + 1])
            else { return }
            
            // Get the operation's operator
            let op = resultElements[opIndex]
            
            // Process multiplication or division
            let productOrQuotient = [
                String( op == "×"
                            ? left * right
                            : left / right
                )
            ]
            
            /* Replace the three parts of the operation in
             resultElement array by the result of this operation */
            let leftIndex = opIndex - 1
            let rightIndex = opIndex + 1
            resultElements.replaceSubrange(
                leftIndex...rightIndex,
                with: productOrQuotient
            )
        }
    }
    
    // Process stracions and subtractions of the expression
    private func additionsAndSubstractions(result: inout [String]) {
        // Iterate over operations while an operation still here
        while result.count >= 3 {
            // Get the operation's numbers
            guard let left = Float(result[0]),
                  let right = Float(result[2]) else { return }
            
            // Get the operation's operator
            let op = result[1]
            
            // Process addition or substraction
            let sumOrDifference = [String(op ==  "+" ? left + right : left - right)]
            
            /* Replace the three parts of the operation in
             resultElement array by the result of this operation */
            result.replaceSubrange(0...2, with: sumOrDifference)
        }
    }
    
    // Get character's string from an operator
    private func getOperatorString(from element: Element) -> String {
        switch element {
        case .plus:
            return "+"
        case .minus:
            return "-"
        case .time:
            return "×"
        default:
            return "÷"
        }
    }
}

// Notifications launched by application
extension Notification.Name {
    static let udpatedExpression = Notification.Name("udpatedExpression")
    static let operatorAlreadySet = Notification.Name("operatorAlreadySet")
    static let notCorrectExpression = Notification.Name("notCorrectExpression")
    static let notEnoughElement = Notification.Name("notEnoughElement")
}
