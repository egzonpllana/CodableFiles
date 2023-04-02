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

// MARK: - Private enum for string literals

private extension String {
    static let jsonExtension = "json"
    static let fileDirectory = "file://"
    static let cfbundleName = "CFBundleName"
    static let dotSymbol = "."
    static let myAppDirectory = "MyAppDirectory"
}

public enum CodableFilesDirectory {
    case defaultDirectory
    case directoryName(_ name: String)
}

// MARK: - CodableFiles

public final class CodableFiles {

    // MARK: - Properties

    /// Shared singleton instance
    public static let shared = CodableFiles()

    /// Private properties
    private var fileManager: FileManager
    private var writeDirectory: String

    // MARK: - Initialization

    private init() {
        self.fileManager = FileManager.default

        // Remove whitespaces from Bundle name.
        if let bundleName = Bundle.main.object(forInfoDictionaryKey: .cfbundleName) as? String {
            self.writeDirectory = bundleName.filter { !$0.isWhitespace }
        } else {
            self.writeDirectory = .myAppDirectory
        }
    }
}

// MARK: - Public extensions

public extension CodableFiles {
    /// A string representation of the default directory name.
    var writeDirectoryName: String {
        return writeDirectory
    }

    /// Saves an encodable object to a file in the specified directory and returns the URL of the saved file.
    ///
    /// - Parameters:
    ///   - object: The encodable object to save.
    ///   - filename: The name of the file to create.
    ///   - directory: The directory in which to create the file.
    /// - Returns: The URL of the saved file.
    /// - Throws: `CodableFilesError.failedToGetDocumentsDirectory` if the documents directory cannot be found or created, or any other errors encountered during file saving.
    func save<T: Encodable>(_ object: T, withFilename filename: String, atDirectory directory: CodableFilesDirectory? = .defaultDirectory) throws -> URL {
        // Get the URL of the specified directory in the documents directory.
        let documentDirectoryUrl = try getDirectoryFullPath(directory ?? .defaultDirectory).unwrap(orThrow: CodableFilesError.failedToGetDocumentsDirectory)

        // Create the URL of the file to be saved.
        let fileURL = documentDirectoryUrl
            .appendingPathComponent(filename)
            .appendingPathExtension(.jsonExtension)

        // Encode the object to JSON data and save it to the file.
        let data = try JSONEncoder().encode(object)
        try data.write(to: fileURL,options: [.atomicWrite])

        return fileURL
    }

    /// Loads a decodable object from a file in the specified directory.
    ///
    /// - Parameters:
    ///   - filename: The name of the file to load.
    ///   - directory: The directory in which the file is located.
    /// - Returns: The decodable object loaded from the file.
    /// - Throws: `CodableFilesError.failedToGetDocumentsDirectory` if the documents directory cannot be found or created, `CodableFilesError.fileInBundleNotFound` if the file is not found in the app bundle, or any other errors encountered during file loading or decoding.
    func load<T: Decodable>(withFilename filename: String, atDirectory directory: CodableFilesDirectory? = .defaultDirectory) throws -> T {
        // Copy the file from the app bundle to the documents directory if needed.
        try copyFromBundleIfNeeded(fileName: filename)

        // Get the URL of the specified directory in the documents directory.
        let documentDirectoryUrl = try getDirectoryFullPath(directory ?? .defaultDirectory).unwrap(orThrow: CodableFilesError.failedToGetDocumentsDirectory)

        // Get the URL of the file to be loaded.
        let fileURL = documentDirectoryUrl
            .appendingPathComponent(filename)
            .appendingPathExtension(.jsonExtension)

        // Load the JSON data from the file and decode it to the desired type.
        let contentData = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(T.self, from: contentData)
    }

    /// Deletes a file with the specified name in the specified directory.
    ///
    /// - Parameters:
    ///   - fileName: The name of the file to delete.
    ///   - directory: The directory in which the file is located.
    /// - Throws: `CodableFilesError.failedToGetDocumentsDirectory` if the documents directory cannot be found or created, or `CodableFilesError.fileInDocumentsDirNotFound` if the file to be deleted is not found.
    func deleteFile(withFileName fileName: String, atDirectory directory: CodableFilesDirectory? = .defaultDirectory) throws {
        // Get the URL of the specified directory in the documents directory.
        let directoryUrl = try getDirectoryFullPath(directory ?? .defaultDirectory).unwrap(orThrow: CodableFilesError.fileNotFound)

        // Delete the file
        try fileManager.removeItem(at: directoryUrl)
    }

    /// Deletes a directory at the given path, or the default document directory if no path is provided.
    ///
    /// - Parameter directoryName: The name of the directory to delete, or nil to delete the default directory.
    /// - Throws: An error of type `CodableFilesError.directoryNotFound` if the directory to be deleted does not exist, or any other error thrown by `FileManager`.
    func deleteDirectory(directoryName directory: CodableFilesDirectory? = .defaultDirectory) throws {
        // Get the URL of the specified directory in the documents directory.
        let directoryUrl = try getDirectoryFullPath(directory ?? .defaultDirectory).unwrap(orThrow: CodableFilesError.fileNotFound)

        // Check if the directory to be deleted already exists
        if fileManager.fileExists(atPath: directoryUrl.path) {
            try fileManager.removeItem(atPath: directoryUrl.path)
        } else {
            throw CodableFilesError.directoryNotFound
        }
    }

    /// Copies a file from the app bundle to a specified directory.
    /// - Parameters:
    ///   - bundle: The bundle containing the file to copy.
    ///   - fileName: The name of the file to copy.
    ///   - directory: The directory to copy the file to.
    /// - Throws: `CodableFilesError` if the operation fails for any reason.
    /// - Returns: The URL of the copied file.
    func copyFileFromBundle(bundle: Bundle, fileName: String, toDirectory directory: CodableFilesDirectory? = .defaultDirectory) throws -> URL {
        // Check if the file exists in the bundle
        guard let bundlePath = bundle.url(forResource: fileName, withExtension: .jsonExtension) else {
            throw CodableFilesError.fileInBundleNotFound
        }

        // Get the full path of the specified directory
        guard let documentDirectoryUrl = getDirectoryFullPath(directory ?? .defaultDirectory) else {
            throw CodableFilesError.failedToGetDocumentsDirectory
        }

        // Create the directory if it does not exist
        if !fileManager.fileExists(atPath: documentDirectoryUrl.path) {
            try fileManager.createDirectory(at: documentDirectoryUrl, withIntermediateDirectories: false)
        }

        // Append the file name and extension to the directory path
        let fileURL = documentDirectoryUrl.appendingPathComponent(fileName).appendingPathExtension(.jsonExtension)

        // Delete the file if it already exists
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }

        // Copy the file from the bundle to the directory
        try fileManager.copyItem(at: bundlePath, to: fileURL)

        // Return the URL of the copied file
        return fileURL
    }

    /// Returns the file path in the documents directory for the specified file name.
    /// - Parameter fileName: The name of the file to get the path for.
    /// - Throws: `CodableFilesError` if the documents directory cannot be accessed.
    /// - Returns: The URL of the file path if it exists, otherwise nil.
    func getFilePath(forFileName fileName: String, fromDirectory directory: CodableFilesDirectory? = .defaultDirectory) throws -> URL? {
        // Get the full path of the directory
        let directoryUrl = try getDirectoryFullPath(directory ?? .defaultDirectory).unwrap(orThrow: CodableFilesError.fileNotFound)
            .appendingPathComponent(fileName + .dotSymbol + .jsonExtension)

        // Check if the file exists in the documents directory
        guard fileManager.fileExists(atPath: directoryUrl.path) else {
            return nil
        }

        // Return the URL of the file path
        return directoryUrl
    }

    /// Checks whether a file with the specified name exists in the documents directory.
    /// - Parameter fileName: The name of the file to check for.
    /// - Throws: `CodableFilesError` if the documents directory cannot be accessed.
    /// - Returns: `true` if the file exists, otherwise `false`.
    func isInDirectory(fileName: String, directory: CodableFilesDirectory? = .defaultDirectory) throws -> Bool {
        // Get the full path of the directory
        let directoryUrl = try getDirectoryFullPath(directory ?? .defaultDirectory).unwrap(orThrow: CodableFilesError.fileNotFound)
            .appendingPathComponent(fileName + .dotSymbol + .jsonExtension)

        // Check if the file exists
        return fileManager.fileExists(atPath: directoryUrl.path)
    }

    /// Sets the default directory name to use for file read/write operations.
    /// - Parameter directoryName: The name of the directory to use.
    func setDefaultDirectoryName(directoryName: String) {
        writeDirectory = directoryName
    }
}

// MARK: - Private extensions

private extension CodableFiles {
    /// This method returns the full path URL for a specified CodableFilesDirectory enum case.
    /// - Parameter directory: The enum case for the directory location to retrieve.
    /// - Returns: A URL for the specified directory location, or nil if the directory cannot be found.
    private func getDirectoryFullPath(_ directory: CodableFilesDirectory) -> URL? {
        // Attempt to get the URL for the documents directory.
        guard let documentDirectoryUrl = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }

        // Switch statement to handle different directory cases.
        switch directory {
        case .defaultDirectory:
            // Get the URL for the default write directory.
            let defaultDirectoryUrl = documentDirectoryUrl.appendingPathComponent(writeDirectory)
            return defaultDirectoryUrl
        case .directoryName(let directory):
            // Get the URL for a custom directory.
            let directoryUrl = documentDirectoryUrl.appendingPathComponent(directory)
            return directoryUrl
        }
    }

    /// This method copies a file from the app bundle to the default directory if the file does not exist there already.
    /// - Parameter fileName: The name of the file to copy.
    /// - Throws: An error if the file cannot be copied.
    private func copyFromBundleIfNeeded(fileName: String, toDirectory directory: CodableFilesDirectory? = .defaultDirectory) throws {
        // Check if the file already exists in the documents directory.
        if (try getFilePath(forFileName: fileName, fromDirectory: directory) == nil) {
            // Get the app bundle and copy the file to the default directory.
            let bundle = Bundle(for: type(of: self))
            _ = try copyFileFromBundle(bundle: bundle, fileName: fileName, toDirectory: directory)
        }
    }

}
