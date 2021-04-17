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
    // Expression's instance
    var expression: Expression!
    
    // Check that a notification has been posted
    var isNotificationPosted: Bool!
    
    // setUp() is executed for each test
    override func setUp() {
        super.setUp()
        expression = Expression()
        isNotificationPosted = false
    }
    
    /* notificationPosted() is executed
     when a notification is observed */
    @objc func notificationPosted() {
        isNotificationPosted = true
    }
    
    // Numbers's tests
    func testGivenExpressionHasResult_WhenNumberAdded_ThenExpressionHasOnlyNumber() {
        // Given
        expression.elements = ["2","+","2","=","4"]
        
        // When
        expression.add(element: .number("2"))
        
        // Then
        XCTAssert(expression.elements == ["2"])
    }
    func testGivenExpressionHasntResult_WhenNumberAdded_ThenNumberAddedToExpression() {
        // Given
        expression.elements = ["2","+"]
        
        // When
        expression.add(element: .number("2"))
        
        // Then
        XCTAssert(expression.elements == ["2","+","2"])
    }
    func testGivenLastElementExpressionIsNumber_WhenNewNumberAdded_ThenNewNumberAddedToExpression() {
        // Given
        expression.elements = ["2","+","2"]
        
        // When
        expression.add(element: .number("2"))
        
        // Then
        XCTAssert(expression.elements == ["2","+","22"])
    }
    
    // Operator's tests
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
            XCTAssert(self.isNotificationPosted)
        }
    }
    func testGivenCanAddOperator_WhenMinusAdded_ThenMinusAddedToExpression() {
        // Given
        expression.elements = ["2","+","2"]
        
        // When
        expression.add(element: .minus)
        
        // Then
        XCTAssert(expression.elements == ["2","+","2","-"])
    }
    func testGivenCanAddOperator_WhenPlusAdded_ThenPlusAddedToExpression() {
        // Given
        expression.elements = ["2","+","2"]
        
        // When
        expression.add(element: .plus)
        
        // Then
        XCTAssert(expression.elements == ["2","+","2","+"])
    }
    func testGivenCanAddOperator_WhenTimeAdded_ThenTimeAddedToExpression() {
        // Given
        expression.elements = ["2","+","2"]
        
        // When
        expression.add(element: .time)
        
        // Then
        XCTAssert(expression.elements == ["2","+","2","×"])
    }
    func testGivenCanAddOperator_WhenDividedByAdded_ThenDividedByAddedToExpression() {
        // Given
        expression.elements = ["2","+","2"]
        
        // When
        expression.add(element: .dividedBy)
        
        // Then
        XCTAssert(expression.elements == ["2","+","2","÷"])
    }
    
    // Equal's tests
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
            XCTAssert(self.isNotificationPosted)
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
            XCTAssert(self.isNotificationPosted)
        }
    }
    func testGivenEnoughElement_WhenEqualAdded_ThenResultSet() {
        // Given
        expression.elements = ["2","+","2","-","2","×","2","÷","2"]
        
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
                "×",
                "2",
                "÷",
                "2",
                "=",
                "2"
            ]
        )
    }
    func testGivenFloatExpressionResult_WhenEqualAdded_ThenResultContainsComma() {
        // Given
        expression.elements = ["7","÷","52"]
        
        // When
        expression.add(element: .equal)
        
        // Then
        XCTAssert(
            expression.elements == [
                "7",
                "÷",
                "52",
                "=",
                "0,13461539"
            ]
        )
    }
    func testGivenExpressionHasResult_WhenEqualAdded_ThenResultNotificationPosted() {
        // Given
        expression.elements = ["2","+","2","=","4"]
        
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
            XCTAssert(self.isNotificationPosted)
        }
    }
    func testGivenExpressionHasDivisionByZero_WhenEqualAdded_ThenNoResultAndNotificationPosted() {
        // Given
        expression.elements = ["2","+","2","÷","0","×","8"]
        
        // When
        let notificationName = Notification.Name.divisionByZero
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
            XCTAssert(
                self.expression.elements == ["2","+","2","÷","0","×","8"]
                    && self.isNotificationPosted
            )
        }
    }
    func testGivenExpressionWithFloatResult_WhenEqualAdded_ThenResultHasComma() {
        // Given
        expression.elements = ["7","÷","2"]
        
        // When
        expression.add(element: .equal)
        
        // Then
        XCTAssert(
            expression.elements == ["7","÷","2","=","3,5"]
        )
    }
    
    // Test deleting expression
    func testGivenExpression_WhenClearExpression_ThenExpressionEmpty() {
        // Given
        expression.elements = ["2","+","2","-","2","×","2","÷","2"]
        
        // When
        expression.clear()
        
        // Then
        XCTAssert(
            expression.elements == []
        )
    }
    func testGivenEmptyExpression_WhenClearExpression_ThenExpressionEmpty() {
        // Given
        expression.elements = []
        
        // When
        expression.clear()
        
        // Then
        XCTAssert(
            expression.elements == []
        )
    }
}
