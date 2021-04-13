//
//  ExpressionTestCase.swift
//  CountOnMeTests
//
//  Created by Vincent Caronnet on 13/04/2021.
//  Copyright © 2021 Vincent Saluzzo. All rights reserved.
//

import XCTest
@testable import CountOnMe

class ExpressionTestCase: XCTestCase {
    var expression: Expression!
    var notificationIsPosted: Bool!
    
    override func setUp() {
        super.setUp()
        expression = Expression()
        notificationIsPosted = false
    }
    
    @objc func notificationPosted() {
        notificationIsPosted = true
    }
    
    func testGivenExpressionHaveResult_WhenNumberAdded_ThenExpressionHasOnlyNumber() {
        // Given
        expression.elements = ["2","+","2","=","4"]
        
        // When
        expression.add(element: .number("2"))
        
        // Then
        XCTAssert(expression.elements == ["2"])
    }
    
    func testGivenExpressionHaventResult_WhenNumberAdded_ThenNumberAddedToExpression_Then() {
        // Given
        expression.elements = ["2","+","2"]
        
        // When
        expression.add(element: .number("2"))
        
        // Then
        XCTAssert(expression.elements == ["2","+","22"])
    }
    func testGivenCantAddOperator_WhenOperatorAdded_ThenNotificationPosted() {
        // Given
        expression.elements = ["2","+"]
        
        // When
        let notificationName = Notification.Name.operatorAlreadySet
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationPosted),
            name: notificationName,
            object: nil
        )
        expectation(
            forNotification: notificationName,
            object: nil,
            handler: nil
        )
        
        expression.add(element: .plus)
        
        // Then
        waitForExpectations(timeout: 0.1) { (error) in
            if let error = error {
                XCTFail("timeout errored: \(error)")
                return
            }
            XCTAssert(self.notificationIsPosted)
        }
    }
    func testGivenCanAddOperator_WhenMinusAdded_ThenOperatorAddedToExpression() {
        // Given
        expression.elements = ["2","+","2"]
        
        // When
        expression.add(element: .minus)
        
        // Then
        XCTAssert(expression.elements == ["2","+","2","-"])
    }
    func testGivenCanAddOperator_WhenPlusAdded_ThenOperatorAddedToExpression() {
        // Given
        expression.elements = ["2","+","2"]
        
        // When
        expression.add(element: .plus)
        
        // Then
        XCTAssert(expression.elements == ["2","+","2","+"])
    }

    func testGivenExpressionNotCorrect_WhenEqualAdded_ThenNotificationPosted() {
        // Given
        expression.elements = ["2","+"]
        
        // When
        let notificationName = Notification.Name.notCorrectExpression
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationPosted),
            name: notificationName,
            object: nil
        )
        expectation(
            forNotification: notificationName,
            object: nil,
            handler: nil
        )
        
        expression.add(element: .equal)
        
        // Then
        waitForExpectations(timeout: 0.1) { (error) in
            if let error = error {
                XCTFail("timeout errored: \(error)")
                return
            }
            XCTAssert(self.notificationIsPosted)
        }
    }
    func testGivenNotEnoughElement_WhenEqualAdded_ThenNotificationPosted() {
        // Given
        expression.elements = ["2"]
        
        // When
        let notificationName = Notification.Name.notEnoughElement
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationPosted),
            name: notificationName,
            object: nil
        )
        expectation(
            forNotification: notificationName,
            object: nil,
            handler: nil
        )
        
        expression.add(element: .equal)
        
        // Then
        waitForExpectations(timeout: 0.1) { (error) in
            if let error = error {
                XCTFail("timeout errored: \(error)")
                return
            }
            XCTAssert(self.notificationIsPosted)
        }
    }
    func testGivenEnoughElement_WhenEqualAdded_ThenResultSet() {
        // Given
        expression.elements = ["2","+","2","-","2"]
        
        // When
        expression.add(element: .equal)
        
        // Then
        XCTAssert(
            expression.elements == [
                "2",
                "+",
                "2",
                "-",
                "2",
                "=",
                "2"
            ]
        )
    }

}


