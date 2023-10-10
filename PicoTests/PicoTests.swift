//
//  PicoTests.swift
//  PicoTests
//
//  Created by 최하늘 on 2023/09/25.
//

@testable import Pico
import XCTest

final class StringExtensionTests: XCTestCase {
    var sut: String?

    override func setUpWithError() throws {
        sut = "01000000000"
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func test_formattedTextFieldText_함수를_사용해서_전화번호_11자리에_대쉬가_추가되는지() throws {
//        let expectation = XCTestExpectation()
        // given - 어떤 환경에서
        var result = ""
        
        // when - 어떤 액션을 했을 때
        result = sut!.formattedTextFieldText()
        
        // then - 어떤 결과가 나오는지
        XCTAssertEqual(result, "010-0000-0000")
//        expectation.fulfill()
//        wait(for: [expectation], timeout: 3)
    }
}
