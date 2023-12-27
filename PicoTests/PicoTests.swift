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
    var sut2: String?

    override func setUpWithError() throws {
        sut = "01000000000"
        sut2 = "2023-12-25"
    }

    override func tearDownWithError() throws {
        sut = nil
        sut2 = nil
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
    
    func test_timeAgoSinceDate_시간을_현_시간과_비교해서_얼마나_지났는지() throws {
        
        var result = ""
        let sut2DateDouble = sut2?.toDate().timeIntervalSince1970
        
        result = sut2DateDouble!.timeAgoSinceDate()
        XCTAssertEqual(result, "2일 전")
    }
}
