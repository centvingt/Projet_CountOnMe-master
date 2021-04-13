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
        
        let resultArray = makeCalculations(elements: elements)
        
        let array = ["=", "\(resultArray.first!.replacingOccurrences(of: ".", with: ","))"]
        elements = elements + array
    }
    private func makeCalculations(elements: [String]) -> [String] {
        var copyElements = elements
        
        if copyElements.contains("×") {
            var multiplicationElements = [String]()

            while copyElements.contains("×") {
                if let index = copyElements.firstIndex(of: "×") {
                    multiplicationElements += makeAdditionsAndSubstractions(elements: Array(copyElements.prefix(index)))
                    copyElements.removeSubrange(0...index)
                }
            }
            multiplicationElements += makeDivisions(elements: copyElements)
            while multiplicationElements.count > 1 {
                let left = Float(multiplicationElements[0])!
                let right = Float(multiplicationElements[1])!
                let result = left * right
                multiplicationElements = Array(multiplicationElements.dropFirst(2))
                multiplicationElements.insert("\(result)", at: 0)
            }
    //        divisionElements[0] = divisionElements[0].replacingOccurrences(of: ".", with: ",")
            return multiplicationElements
        }
        if copyElements.contains("÷") {
            return makeDivisions(elements: copyElements)
        }
        return makeAdditionsAndSubstractions(elements: copyElements)
    }
    private func makeDivisions(elements: [String]) -> [String] {
        var copyElements = elements
        var divisionElements = [String]()

        while copyElements.contains("÷") {
            if let index = copyElements.firstIndex(of: "÷") {
                divisionElements += makeAdditionsAndSubstractions(elements: Array(copyElements.prefix(index)))
                copyElements.removeSubrange(0...index)
            }
        }
        divisionElements += makeAdditionsAndSubstractions(elements: copyElements)
        while divisionElements.count > 1 {
            let left = Float(divisionElements[0])!
            let right = Float(divisionElements[1])!
            let result = left / right
            divisionElements = Array(divisionElements.dropFirst(2))
            divisionElements.insert("\(result)", at: 0)
        }
        return divisionElements
    }
    private func makeAdditionsAndSubstractions(elements: [String]) -> [String] {
        var operationsToReduce = elements
        
        // Iterate over operations while an operand still here
        while operationsToReduce.count > 1 {
            let left = Int(operationsToReduce[0])!
            let operand = operationsToReduce[1]
            let right = Int(operationsToReduce[2])!
            
            let result = operand == "+" ? left + right : left - right
            
            operationsToReduce = Array(operationsToReduce.dropFirst(3))
            operationsToReduce.insert("\(result)", at: 0)
        }
        
        return operationsToReduce
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
