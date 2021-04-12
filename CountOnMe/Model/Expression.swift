//
//  Expression.swift
//  CountOnMe
//
//  Created by Vincent Caronnet on 11/04/2021.
//  Copyright © 2021 Vincent Saluzzo. All rights reserved.
//

import Foundation

struct Expression {
    var elements: [String]
    
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
}
