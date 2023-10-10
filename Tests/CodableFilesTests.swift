/**
 * MIT License

 * Copyright (c) 2022 Egzon Pllana

 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:

 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import Foundation
import XCTest
import CodableFiles

// Enum for String literals
private extension String {
    static let testsDirectory = "TestsDirectory"
    static let anotherTestsDirectory = "AnotherTestsDirectory"
    static let bundleNameKey = "CFBundleName"
    static let fileName = "userModel"
    static let userJSONFileName = "User"
    static let usersArrayJSONFileName = "UsersArray"
    static let json = "json"
}

// User object with dummy data to be used for testing purpose.
private let userModel: User = User(firstName: "First name", lastName: "Last name")
private let anotherUserModel: User = User(firstName: "Another First name", lastName: "Another Last name")

// MARK: - CodableFiles XCTestCase

class CodableFilesTests: XCTestCase {

    // MARK: - Properties

    private var sut: CodableFiles!
    private let testsDirectory = CodableFilesDirectory.directoryName(.testsDirectory)
    private let anotherTestsDirectory = CodableFilesDirectory.directoryName(.anotherTestsDirectory)

    // MARK: - Test life cycle

    override func setUp() {
        super.setUp()
        // init
        sut = CodableFiles.shared
        sut.setBundle(Bundle(for: type(of: self)))
    }

    override func tearDown() {
        // delete created directories during tests
        try? sut.deleteDirectory()
        try? sut.deleteDirectory(directoryName: testsDirectory)
        try? sut.deleteDirectory(directoryName: anotherTestsDirectory)

        // rest
        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_initialization_success() {
        let codableFiles = CodableFiles.shared
        XCTAssertNotNil(codableFiles)
    }

    func test_load_single_file_success() throws {
        // given
        let fileName: String = .userJSONFileName
        let directory = testsDirectory

        // when
        let user: User = try sut.load(withFilename: fileName, atDirectory: directory)

        // then
        XCTAssertNotNil(user)
    }
}
