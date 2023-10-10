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

    func test_load_single_dto_success() throws {
        // given
        let fileName: String = .userJSONFileName
        let directory = testsDirectory

        // when
        let user: User = try sut.load(withFilename: fileName, atDirectory: directory)

        // then
        XCTAssertNotNil(user)
    }

    func test_load_array_of_dto_success() throws {
        // given
        let fileName: String = .usersArrayJSONFileName
        let directory = testsDirectory

        // when
        let users: [User] = try sut.load(withFilename: fileName, atDirectory: directory)

        // then
        XCTAssertNotNil(users)
    }

    func test_save_single_dto_success() throws {
        // given
        let userFileName: String = .userJSONFileName
        let user: User = .fake()

        // when
        try sut.save(user, withFilename: userFileName)

        // then
    }

    func test_save_multiple_dtos_success() throws {
        // given
        let usersFileName: String = .usersArrayJSONFileName
        let directory = testsDirectory

        // when
        let users: [User] = try sut.load(withFilename: usersFileName, atDirectory: directory)

        // then
        XCTAssertNotEqual(users.count, 0)

        // given
        let userFileName: String = .userJSONFileName

        // when
        try sut.save(users, withFilename: userFileName)

        // then
    }

    func test_delete_file_success() throws {
        // given
        let fileName: String = .userJSONFileName
        let user: User = .fake()

        // when
        try sut.save(user, withFilename: fileName)

        // when
        try sut.deleteFile(withFileName: fileName)

        // when
        let isInDirectory = try sut.isInDirectory(fileName: fileName)

        // then
        XCTAssertFalse(isInDirectory)
    }

    func test_delete_directory_success() throws {
        // given
        let userFileName: String = .userJSONFileName
        let user: User = .fake()

        // when
        try sut.save(user, withFilename: userFileName)

        // then
        try sut.deleteDirectory()
    }

    func test_copy_file_from_bundle_success() throws {
        // given
        let fileName: String = .userJSONFileName
        let bundle = Bundle(for: type(of: self))

        // when
        try sut.copyFileFromBundle(bundle: bundle, fileName: fileName)

        // when
        let user: User = try sut.load(withFilename: fileName)

        // then
        XCTAssertNotNil(user)
    }
}
