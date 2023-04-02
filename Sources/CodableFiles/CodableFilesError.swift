//
//  CodableFilesError.swift
//  CodableFiles
//
//  Created by Egzon Pllana on 2.4.23.
//

import Foundation

public enum CodableFilesError: Error {
    case fileInBundleNotFound
    case fileInDocumentsDirNotFound
    case failedToGetDocumentsDirectory
    case directoryNotFound
    case fileNotFound

    var debugDescription: String {
        switch self {
        case .fileInBundleNotFound: return "File with given name not found in the current Bundle."
        case .fileInDocumentsDirNotFound: return "File with given name not found in Documents directory."
        case .failedToGetDocumentsDirectory: return "Failed to get documents directory full path URL."
        case .directoryNotFound: return "Provided directory name not found."
        case .fileNotFound: return "File not found."
        }
    }
}
