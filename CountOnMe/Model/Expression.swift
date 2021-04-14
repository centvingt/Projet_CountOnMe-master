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
            print(elements)
            let notification = Notification(name: .udpatedExpression)
            NotificationCenter.default.post(notification)
        }
    }
    enum Element {
        case number(String),
             plus,
             minus,
             time,
             dividedBy,
             equal
    }
    private enum Operand: String {
        case plus = "+",
             minus = "-",
             time = "×",
             dividedBy = "÷"
    }
    
    // Error check computed variables
    private var isCorrect: Bool {
        return elements.last != "+"
            && elements.last != "-"
            && elements.last != "×"
            && elements.last != "÷"
    }
    
    private var haveEnoughElement: Bool {
        return elements.count >= 3
    }
    
    private var canAddOperator: Bool {
        return elements.last != "+"
            && elements.last != "-"
            && elements.last != "×"
            && elements.last != "÷"
    }
    
    private var haveResult: Bool {
        return elements.firstIndex(of: "=") != nil
    }
    
    func add(element: Element) {
        switch element {
        case .number(var string):
            if haveResult {
                elements = []
            }
            if let lastString = elements.last,
               lastString != "-"
                && lastString != "+"
                && lastString != "×"
                && lastString != "÷" {
                elements.removeLast()
                string = lastString + string
            }
            elements.append(string)
        case .plus,
             .minus,
             .time,
             .dividedBy:
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
        
        guard let result = calculate(elements: elements) else {
            return
        }
        
        elements.append(contentsOf: ["=", "\(result)"])
    }
    private func calculate(elements: [String]) -> String? {
        var resultElements = elements
        
        multiplicationsAndDivisions(resultElements: &resultElements)
        additionsAndSubstractions(result: &resultElements)
        
        guard let resultElement = resultElements.first,
              let float = Float(resultElement) else {
            return nil
        }
        
        return float.rounded(.down) == float.rounded(.up)
            ? String(Int(float))
            : String(float).replacingOccurrences(of: ".", with: ",")
    }

    private func multiplicationsAndDivisions(resultElements: inout [String]) {
        // Iterate over operations while an operand still here
        while resultElements.contains("×") || resultElements.contains("÷") {
            guard
                let opIndex = resultElements.firstIndex(where: { (string) -> Bool in
                    string == "×" || string == "÷"
                }),
                let left = Float(resultElements[opIndex - 1]),
                let right = Float(resultElements[opIndex + 1])
            else { return }
            
            let op = resultElements[opIndex]
            let productOrQuotient = [String(op == "×" ? left * right : left / right)]
            
            let leftIndex = opIndex - 1
            let rightIndex = opIndex + 1
            resultElements.replaceSubrange(leftIndex...rightIndex, with: productOrQuotient)
        }
    }
    private func additionsAndSubstractions(result: inout [String]) {
        while result.count >= 3 {
            guard let left = Float(result[0]),
                  let right = Float(result[2]) else { return }
            
            let op = result[1]
            let sumOrDifference = [String(op ==  "+" ? left + right : left - right)]
            result.replaceSubrange(0...2, with: sumOrDifference)
        }
    }
    private func getOperatorString(from element: Element) -> String {
        switch element {
        case .plus:
            return "+"
        case .minus:
            return "-"
        case .time:
            return "×"
        case .dividedBy:
            return "÷"
        case .number, .equal:
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
