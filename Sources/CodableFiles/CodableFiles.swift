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

private enum SL: String {
    case json = "json"
    case fileDirectory = "file://"
    case myAppDirectory = "MyAppDirectory"
    case cfbundleName = "CFBundleName"
    case dot = "."
}

public enum CodableFilesError: Error {
    case directoryNotFound
    case fileNotFoundInDocsDirectory
    case fileInBundleNotFound
    case unableToCreateFullPath

    public var debugDescription: String {
        switch self {
        case .directoryNotFound: return "Directory with given name not found."
        case .fileNotFoundInDocsDirectory: return "File with given name not found."
        case .fileInBundleNotFound: return "File with given name not found in the current Bundle."
        case .unableToCreateFullPath: return "Unable to create full path from given URL."
        }
    }
}

// MARK: - CodableFiles

public final class CodableFiles {

    // MARK: - Properties

    /// Shared singleton instance
    public static let shared = CodableFiles()

    /// Private properties
    private var fileManager: FileManager
    private var defaultDirectory: String

    // MARK: - Initialization

    private init() {
        self.fileManager = FileManager.default

        // Remove whitespaces from Bundle name.
        if let bundleName = Bundle.main.object(forInfoDictionaryKey: SL.cfbundleName.rawValue) as? String {
            self.defaultDirectory = bundleName.filter { !$0.isWhitespace }
        } else {
            self.defaultDirectory = SL.myAppDirectory.rawValue
        }
    }
}

// MARK: - Public Extensions

public extension CodableFiles {
    /// Save Encodable Object.
    /// - Parameters:
    ///   - object: Encodable object.
    ///   - filename: File name to save objects data.
    ///   - directory: Directory to save the object.
    /// - Returns: Returns an optional directory URL where file data is saved.
    func save(object: Encodable, withFilename filename: String, atDirectory directory: String?=nil) throws -> URL? {
        // Convert object to dictionary string
        let objectDictionary = try object.toDictionary()

        // Get default document directory path url.
        var documentDirectoryUrl = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

        // Check if its needed to append the new directory name.
        if let directory = directory {
            let directoryUrl = documentDirectoryUrl.appendingPathComponent(directory)
            documentDirectoryUrl = directoryUrl
        } else {
            let defaultDirectoryUrl = documentDirectoryUrl.appendingPathComponent(defaultDirectory)
            documentDirectoryUrl = defaultDirectoryUrl
        }

        // Create the right directory if it does not exist, specified one or default one.
        if fileManager.fileExists(atPath: documentDirectoryUrl.path) == false {
            try fileManager.createDirectory(at: documentDirectoryUrl, withIntermediateDirectories: false)
        }

        // Append file name to the directory path url.
        var fileURL = documentDirectoryUrl.appendingPathComponent(filename)
        fileURL = fileURL.appendingPathExtension(SL.json.rawValue)

        // Write data to file url.
        let data = try JSONSerialization.data(withJSONObject: objectDictionary, options: [.prettyPrinted])
        try data.write(to: fileURL, options: [.atomicWrite])
        return fileURL
    }

    /// Save array of Encodable objects.
    /// - Parameters:
    ///   - objects: Encodable objects.
    ///   - filename: File name to save objects data.
    ///   - directory: directory to save the object.
    /// - Returns: Returns an optional directory URL where file data is saved.
    func saveAsArray(objects: [Encodable], withFilename filename: String, atDirectory directory: String?=nil) throws -> URL? {
        // Convert object to dictionary string.
        let objectDictionary = try objects.map { try $0.toDictionary() }

        // Get default document directory path url.
        var documentDirectoryUrl = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

        // Check if its needed to append the new directory name.
        if let directory = directory {
            let directoryUrl = documentDirectoryUrl.appendingPathComponent(directory)
            documentDirectoryUrl = directoryUrl
        } else {
            let defaultDirectoryUrl = documentDirectoryUrl.appendingPathComponent(defaultDirectory)
            documentDirectoryUrl = defaultDirectoryUrl
        }

        // Create the right directory if it does not exist, specified one or default one.
        if fileManager.fileExists(atPath: documentDirectoryUrl.path) == false {
            try fileManager.createDirectory(at: documentDirectoryUrl, withIntermediateDirectories: false)
        }

        // Append file name to the directory path url.
        var fileURL = documentDirectoryUrl.appendingPathComponent(filename)
        fileURL = fileURL.appendingPathExtension(SL.json.rawValue)

        // Write data to file url.
        let data = try JSONSerialization.data(withJSONObject: objectDictionary, options: [.prettyPrinted])
        try data.write(to: fileURL, options: [.atomicWrite])
        return fileURL
    }

    /// Load object from Document Directory.
    /// - Parameters:
    ///   - objectType: Decodable object.
    ///   - filename: Object name.
    ///   - directory: Directory to load the object from.
    /// - Returns: Returns optional Decodable object.
    func load<T: Decodable>(objectType type: T.Type, withFilename filename: String, atDirectory directory: String?=nil) throws -> T? {
        // Get default document directory path url.
        var documentDirectoryUrl = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

        // Check if its needed to use a specific directory.
        if let directory = directory {
            documentDirectoryUrl = documentDirectoryUrl.appendingPathComponent(directory)
        } else {
            documentDirectoryUrl = documentDirectoryUrl.appendingPathComponent(defaultDirectory)
        }

        // Append file name to the directory path url.
        var fileURL = documentDirectoryUrl.appendingPathComponent(filename)
        fileURL = fileURL.appendingPathExtension(SL.json.rawValue)

        // Get data from path url.
        let contentData = try Data(contentsOf: fileURL)

        // Get json object from data.
        let jsonObject = try JSONSerialization.jsonObject(with: contentData, options: [.mutableContainers, .mutableLeaves])

        // Convert json object to data type.
        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])

        // Decode data to Decodable object.
        let decoder = JSONDecoder()
        let decodedObject = try decoder.decode(T.self, from: jsonData)

        return decodedObject
    }

    /// Load array of Encodable objects from Documents Directory.
    /// - Parameters:
    ///   - objectType: Decodable object.
    ///   - filename: Object name.
    ///   - directory: Directory to load data from.
    /// - Returns: Returns optional Decodable object.
    func loadAsArray<T: Decodable>(objectType type: T.Type, withFilename filename: String, atDirectory directory: String?=nil) throws -> [T?] {
        // Get default document directory path url.
        var documentDirectoryUrl = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

        // Check if its needed to use a specific directory.
        if let directory = directory {
            documentDirectoryUrl = documentDirectoryUrl.appendingPathComponent(directory)
        } else {
            documentDirectoryUrl = documentDirectoryUrl.appendingPathComponent(defaultDirectory)
        }

        // Append file name to the directory path url.
        var fileURL = documentDirectoryUrl.appendingPathComponent(filename)
        fileURL = fileURL.appendingPathExtension(SL.json.rawValue)

        // Get data from path url.
        let contentData = try Data(contentsOf: fileURL)

        // Get json object from data.
        let jsonObject = try JSONSerialization.jsonObject(with: contentData, options: [.mutableContainers, .mutableLeaves])

        // Convert json object to data type.
        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])

        // Decode data to Decodable object.
        let decoder = JSONDecoder()
        let decodedObject = try decoder.decode([T].self, from: jsonData)

        return decodedObject
    }

    /// Load Encodable Object from specified path.
    /// - Parameters:
    ///   - objectType: Decodable object.
    ///   - atPath: Path url to load the object from, ex. ".../user.json".
    /// - Returns: Returns optional Decodable object.
    func load<T: Decodable>(fromBundle bundle: Bundle?=Bundle.main, objectType type: T.Type, fileName: String) throws -> T? {
        if let bundlePath = bundle?.url(forResource: fileName, withExtension: SL.json.rawValue) {

            // Get data from path url.
            let contentData = try Data(contentsOf: bundlePath)

            // Get json object from data
            let jsonObject = try JSONSerialization.jsonObject(with: contentData, options: [.mutableContainers, .mutableLeaves])

            // Convert json object to data type.
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])

            // Decode data to Decodable object.
            let decoder = JSONDecoder()
            let decodedObject = try decoder.decode(T.self, from: jsonData)

            return decodedObject
        } else {
            throw CodableFilesError.fileInBundleNotFound

        }
    }

    /// Load array of Encodable objects from specified path.
    /// - Parameters:
    ///   - objectType: Decodable object.
    ///   - atPath: Path url to load the objects from, ex. ".../users.json".
    /// - Returns: Returns array of optional Decodable objects.
    func loadAsArray<T: Decodable>(fromBundle bundle: Bundle?=Bundle.main, objectType type: T.Type, fileName: String) throws -> [T?] {
        if let bundlePath = bundle?.url(forResource: fileName, withExtension: SL.json.rawValue) {
            // Get data from path url.
            let contentData = try Data(contentsOf: bundlePath)

            // Get json object from data.
            let jsonObject = try JSONSerialization.jsonObject(with: contentData, options: [.mutableContainers, .mutableLeaves])

            // Convert json object to data type.
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])

            // Decode data to Decodable object.
            let decoder = JSONDecoder()
            let decodedObject = try decoder.decode([T].self, from: jsonData)

            return decodedObject
        } else {
            throw CodableFilesError.fileInBundleNotFound
        }
    }

    /// Delete file with given name at given directory.
    /// Note: if directory name is not given, it try to delete from Documents folder.
    /// - Parameters:
    ///   - fileName: file name to delete without extension.
    ///   - directoryName: directory name where the file is located.
    func deleteFile(withFileName fileName: String, atDirectory directory: String?=nil) throws {
        // Get default document directory path url.
        var pathUrl = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fullFileName = fileName + SL.dot.rawValue + SL.json.rawValue

        // Check if we should delete specific directory.
        if let folderPath = directory {
            let folderPath = pathUrl.appendingPathComponent(folderPath)
            pathUrl = folderPath.appendingPathComponent(fullFileName)
        } else {
            pathUrl = pathUrl.appendingPathComponent(defaultDirectory).appendingPathComponent(fullFileName)
        }

        // Check if the directory to be deleted already exists.
        if fileManager.fileExists(atPath: pathUrl.path) {
            try fileManager.removeItem(atPath: pathUrl.path)
        } else {
            throw CodableFilesError.fileNotFoundInDocsDirectory
        }
    }

    /// Delete specific directory, if not specified it deletes the default document directory.
    /// - Parameter name: Directory name to delete.
    func deleteDirectory(directoryName name: String?=nil) throws {
        // Get default document directory path url.
        var documentDirectoryUrl = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

        // Check if we should delete specific directory.
        if let path = name {
            documentDirectoryUrl = documentDirectoryUrl.appendingPathComponent(path)
        } else {
            documentDirectoryUrl = documentDirectoryUrl.appendingPathComponent(defaultDirectory)
        }

        // Check if the directory to be deleted already exists.
        if fileManager.fileExists(atPath: documentDirectoryUrl.path) {
            // TODO: is throwing error in Tests
            try fileManager.removeItem(atPath: documentDirectoryUrl.path)
        } else {
            throw CodableFilesError.directoryNotFound
        }
    }

    /// Copy file with given name from a Bundle to documents directory.
    /// - Parameters:
    ///   - bundle: Bundle to copy files from.
    ///   - fileName: File name to copy.
    ///   - directory: Directory to save file to.
    func copyFileFromBundle(bundle: Bundle?=Bundle.main, fileName: String, toDirectory directory: String?=nil) throws -> URL? {
        if let bundlePath = bundle?.url(forResource: fileName, withExtension: SL.json.rawValue) {
            // Get default document directory path url.
            var documentDirectoryUrl = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            // Check if its needed to append the new directory name.
            if let directory = directory {
                let directoryUrl = documentDirectoryUrl.appendingPathComponent(directory)
                documentDirectoryUrl = directoryUrl
            } else {
                let defaultDirectoryUrl = documentDirectoryUrl.appendingPathComponent(defaultDirectory)
                documentDirectoryUrl = defaultDirectoryUrl
            }

            // Create the right directory if it does not exist, specified one or default one.
            if fileManager.fileExists(atPath: documentDirectoryUrl.path) == false {
                try fileManager.createDirectory(at: documentDirectoryUrl, withIntermediateDirectories: false)
            }

            // Append file name
            let fileName = fileName + SL.dot.rawValue + SL.json.rawValue
            documentDirectoryUrl = documentDirectoryUrl.appendingPathComponent(fileName)

            // Replace file if already exists
            if fileManager.fileExists(atPath: documentDirectoryUrl.path) == true {
                let savedPath = try fileManager.replaceItemAt(documentDirectoryUrl, withItemAt: bundlePath)
                return savedPath
            } else {
                // Copy file from bundle to documents directory.
                try fileManager.copyItem(at: bundlePath, to: documentDirectoryUrl)
                return documentDirectoryUrl
            }
        } else {
            throw CodableFilesError.fileInBundleNotFound
        }
    }

    /// Change default directory name to a new one.
    /// - Parameter directoryName: Directory name to save and load objects.
    func setDefaultDirectoryName(directoryName: String) {
        defaultDirectory = directoryName
    }
}

// MARK: - Computed Properties

public extension CodableFiles {
    /// A string representation of the default directory name.
    var defaultDirectoryName: String {
        return defaultDirectory
    }
}
