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
    case userJSONFileName = "User"
    case usersArrayJSONFileName = "UsersArray"
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

    /// Test initialization shared instance.
    func testInitialization() {
        let codableFiles = CodableFiles.shared
        XCTAssertNotNil(codableFiles)
    }

    /// Load json data from json file inside the Tests bundles.
    func testLoadJSONFileFromBundle() throws {
        let testBundle = Bundle(for: type(of: self))
        let loadPath = try sut.load(fromBundle: testBundle, objectType: User.self, fileName: SL.userJSONFileName.rawValue)
        XCTAssertNotNil(loadPath)
    }

    /// Load JSON array of data from bundle file.
    func testLoadJSONArrayFileFromBundle() throws {
        let testBundle = Bundle(for: type(of: self))
        let loadPath = try sut.loadAsArray(fromBundle: testBundle, objectType: User.self, fileName: SL.usersArrayJSONFileName.rawValue)
        XCTAssertNotNil(loadPath)
    }

    /// Save file without providing a directory name
    /// Will use the default one.
    func testSaveFileToDefaultDirectory() throws {
        let savedPathURL = try sut.save(object: userModel, withFilename: SL.fileName.rawValue)
        XCTAssertNotNil(savedPathURL)
    }

    /// Load file without providing a directory name
    /// Will use the default one.
    func testLoadFileFromDefaultDirectory() throws {
        let _ = try sut.save(object: userModel, withFilename: SL.fileName.rawValue)
        let loadedObject = try sut.load(objectType: User.self, withFilename: SL.fileName.rawValue)
        XCTAssertNotNil(loadedObject)
    }

    /// Check if saved files without providing a directory name
    /// are saved in a default directory.
    func testSavedFileAreInDefaultDirectory() throws {
        let savedPathURL = try sut.save(object: userModel, withFilename: SL.fileName.rawValue)
        XCTAssertTrue(savedPathURL.pathComponents.contains(sut.defaultDirectoryName))
    }

    /// Change default directory name.
    func testSetDefaultDirectoryName() {
        sut.setDefaultDirectoryName(directoryName: SL.anotherTestsDirectory.rawValue)
        XCTAssertEqual(SL.anotherTestsDirectory.rawValue, sut.defaultDirectoryName)
    }

    /// Delete default directory without providing directory name.
    func testDeleteDefaultDirectory() throws {
        let _ = try sut.save(object: userModel, withFilename: SL.fileName.rawValue)
        try sut.deleteDirectory()
        XCTAssertFalse(FileManager.default.fileExists(atPath: sut.defaultDirectoryName))
    }

    /// Delete a directory with provided directory name.
    func testDeleteSpecificDirectory() throws {
        let _ = try sut.save(object: userModel, withFilename: SL.fileName.rawValue, atDirectory: SL.testsDirectory.rawValue)
        try sut.deleteDirectory(directoryName: SL.testsDirectory.rawValue)
        XCTAssertFalse(FileManager.default.fileExists(atPath: SL.testsDirectory.rawValue))
    }

    /// Check if possible to save array of objects.
    func testSaveArrayOfObjects() throws {
        let objectsToSave = [userModel, anotherUserModel]
        let savedPathURL = try sut.saveAsArray(objects: objectsToSave, withFilename: SL.fileName.rawValue, atDirectory: SL.testsDirectory.rawValue)
        XCTAssertNotNil(savedPathURL)
    }

    /// Check if loaded objects count is same with saved objects count.
    func testLoadArrayOfObjects() throws  {
        let objectsToSave = [userModel, anotherUserModel]
        let savedPathURL = try sut.saveAsArray(objects: objectsToSave, withFilename: SL.fileName.rawValue, atDirectory: SL.testsDirectory.rawValue)
        XCTAssertNotNil(savedPathURL)
        let optionalObjects = try sut.loadAsArray(objectType: User.self, withFilename: SL.fileName.rawValue, atDirectory: SL.testsDirectory.rawValue)
        let loadedObjects = optionalObjects.compactMap({ $0 })
        XCTAssertEqual(objectsToSave.count, loadedObjects.count)
    }

    /// Try deleting single file at default directory.
    func testDeleteSingleFileFromDefaultDirectory() throws {
        // Save file
        let _ = try sut.save(object: userModel, withFilename: SL.fileName.rawValue)
        // Delete file
        try sut.deleteFile(withFileName: SL.fileName.rawValue)
    }

    /// Try deleting single file at given directory name.
    func testDeleteSingleFileFromGivenDirectory() throws {
        // Save file
        let _ = try sut.save(object: userModel, withFilename: SL.fileName.rawValue, atDirectory: SL.testsDirectory.rawValue)
        // Delete file
        try sut.deleteFile(withFileName: SL.fileName.rawValue, atDirectory: SL.testsDirectory.rawValue)
    }

    /// Try to copy file from bundle with given file name.
    func testCopyFileFromBundleToDefaultDirectory() throws {
        // Filename.
        let fileName = SL.userJSONFileName.rawValue
        // Test bundle.
        let testBundle = Bundle(for: type(of: self))
        // Copy file.
        let savedPathURL = try sut.copyFileFromBundle(bundle: testBundle, fileName: fileName)
        // Check if file is copied.
        XCTAssertNotNil(savedPathURL)
    }

    /// Try to copy file from bundle with given file name.
    func testCopyFileFromBundleToGivenDirectory() throws {
        // Filename.
        let fileName = SL.userJSONFileName.rawValue
        // Test bundle.
        let testBundle = Bundle(for: type(of: self))
        // Copy file.
        let savedPathURL = try sut.copyFileFromBundle(bundle: testBundle, fileName: fileName, toDirectory: SL.testsDirectory.rawValue)
        // Check if file is copied.
        XCTAssertNotNil(savedPathURL)
    }

    /// Test debugDescription for CodableFiles error enumeration.
    func testCFErrordebugDescription() {
        let directoryNotFound = CodableFilesError.directoryNotFound
        XCTAssertNotNil(directoryNotFound.debugDescription)

        let fileNotFoundInDocsDirectory = CodableFilesError.fileNotFoundInDocsDirectory
        XCTAssertNotNil(fileNotFoundInDocsDirectory.debugDescription)

        let fileInBundleNotFound = CodableFilesError.fileInBundleNotFound
        XCTAssertNotNil(fileInBundleNotFound.debugDescription)

        let unableToCreateFullPath = CodableFilesError.unableToCreateFullPath
        XCTAssertNotNil(unableToCreateFullPath.debugDescription)
    }
}
