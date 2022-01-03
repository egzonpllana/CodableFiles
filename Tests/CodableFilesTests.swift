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
private enum SL: String {
    case testsDirectory = "TestsDirectory"
    case anotherTestsDirectory = "AnotherTestsDirectory"
    case bundleNameKey = "CFBundleName"
    case fileName = "userModel"
    case userModelName = "UserModel"
    case json = "json"
}

// User object with dummy data to be used for testing purpose.
private let userModel: User = User(firstName: "First name", lastName: "Last name")
private let anotherUserModel: User = User(firstName: "Another First name", lastName: "Another Last name")

// MARK: - CodableFiles XCTestCase

class CodableFilesTests: XCTestCase {

    // MARK: - Properties

    private var sut: CodableFiles!

    // MARK: - Test life cycle

    override func setUp() {
        super.setUp()
        // This method is called before the invocation of each test method in the class.

        // Create CodableFiles object
        sut = CodableFiles.shared
    }

    override func tearDown() {
        // This method is called after the invocation of each test method in the class.

        // Delete created directories during tests
        try? sut.deleteDirectory()
        try? sut.deleteDirectory(directoryName: SL.testsDirectory.rawValue)
        try? sut.deleteDirectory(directoryName: SL.anotherTestsDirectory.rawValue)

        // Reset CodableFiles
        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    /// Load json data from json file inside the Tests bundles
    func testLoadJSONFileFromBundle() {
        let testBundle = Bundle(for: type(of: self))
        let objectPath = testBundle.path(forResource: SL.userModelName.rawValue, ofType: SL.json.rawValue)!
        let objectPathURL = URL(string: objectPath)!
        let loadedObject = try? sut.load(objectType: User.self, atPath: objectPathURL)
        XCTAssertNotNil(loadedObject)
    }

    /// Save file without providing a directory name
    /// Will use the default one.
    func testSaveFileToDefaultDirectory() {
        let savedPathURL = try? sut.save(object: userModel, withFilename: SL.fileName.rawValue)
        XCTAssertNotNil(savedPathURL)
    }

    /// Load file without providing a directory name
    /// Will use the default one.
    func testLoadFileFromDefaultDirectory() {
        let _ = try? sut.save(object: userModel, withFilename: SL.fileName.rawValue)
        let loadedObject = try? sut.load(objectType: User.self, withFilename: SL.fileName.rawValue)
        XCTAssertNotNil(loadedObject)
    }

    /// Check if saved files without providing a directory name
    /// are saved in a default directory.
    func testSavedFileAreInDefaultDirectory() {
        let savedPathURL = try? sut.save(object: userModel, withFilename: SL.fileName.rawValue)
        XCTAssertTrue(savedPathURL!.pathComponents.contains(sut.defaultDirectoryName))
    }

    /// Change default directory name.
    func testSetDefaultDirectoryName() {
        sut.setDefaultDirectoryName(directoryName: SL.anotherTestsDirectory.rawValue)
        XCTAssertEqual(SL.anotherTestsDirectory.rawValue, sut.defaultDirectoryName)
    }

    /// Delete default directory without providing directory name.
    func testDeleteDefaultDirectory() {
        let _ = try? sut.save(object: userModel, withFilename: SL.fileName.rawValue)
        try? sut.deleteDirectory()
        XCTAssertFalse(FileManager.default.fileExists(atPath: sut.defaultDirectoryName))
    }

    /// Delete a directory with provided directory name.
    func testDeleteSpecificDirectory() {
        let _ = try? sut.save(object: userModel, withFilename: SL.fileName.rawValue, atDirectory: SL.testsDirectory.rawValue)
        try? sut.deleteDirectory(directoryName: SL.testsDirectory.rawValue)
        XCTAssertFalse(FileManager.default.fileExists(atPath: SL.testsDirectory.rawValue))
    }

    /// Check if possible to save array of objects.
    func testSaveArrayOfObjects() {
        let objectsToSave = [userModel, anotherUserModel]
        let savedPathURL = try? sut.saveAsArray(objects: objectsToSave, withFilename: SL.fileName.rawValue, atDirectory: SL.testsDirectory.rawValue)
        XCTAssertNotNil(savedPathURL)
    }

    /// Check if loaded objects count is same with saved objects count..
    func testLoadArrayOfObjects() {
        let objectsToSave = [userModel, anotherUserModel]
        let savedPathURL = try? sut.saveAsArray(objects: objectsToSave, withFilename: SL.fileName.rawValue, atDirectory: SL.testsDirectory.rawValue)
        XCTAssertNotNil(savedPathURL)
        let optionalObjects = try? sut.loadAsArray(objectType: User.self, withFilename: SL.fileName.rawValue, atDirectory: SL.testsDirectory.rawValue)
        XCTAssertNotNil(optionalObjects)
        let loadedObjects = optionalObjects!.compactMap({ $0 })
        XCTAssertEqual(objectsToSave.count, loadedObjects.count)
    }
}
