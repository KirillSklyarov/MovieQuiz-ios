//
//  MovieQuizTests.swift
//  MovieQuizTests
//
//  Created by Kirill Sklyarov on 09.11.2023.
//

import XCTest

struct ArithmeticOperations {
    func addiction(num1: Int, num2: Int, handler: @escaping(Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            handler(num1 + num2)
        }
    }
    
    func subtraction(num1: Int, num2: Int, handler: @escaping(Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            handler(num1 - num2)
        }
    }
    
    func multiplication(num1: Int, num2: Int, handler: @escaping(Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            handler(num1 * num2)
        }
    }
}


class MovieQuizTests: XCTestCase {
    
    func testAddiction() throws {
        let arithmeticOperations = ArithmeticOperations()
        let num1 = 1
        let num2 = 2
        let expectation = expectation(description: "Addiction function expectation")
        let result = arithmeticOperations.addiction(num1: num1, num2: num2) { result in
            XCTAssertEqual(result, 3)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
    }
}

