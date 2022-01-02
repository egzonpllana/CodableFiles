<p align="center">
    <img src="logo.png" width="300" max-width="50%" alt=“CodableFiles” />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.0-orange.svg" />
    <a href="https://cocoapods.org/pods/CodableFiles">
        <img src="https://img.shields.io/cocoapods/v/CodableFiles.svg" alt="CocoaPods" />
    </a>
    <a href="https://github.com/Carthage/Carthage">
        <img src="https://img.shields.io/badge/carthage-compatible-4BC51D.svg?style=flat" alt="Carthage" />
    </a>
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
</p>

Welcome to **CodableFiles**, a simple library that provides an easier way to save, load or delete Codable objects in Documents directory. It’s primarily aimed to save Encodable objects as json string and loads back from string to Decodable object. It's essentially a thin wrapper around the `FileManager` APIs that `Foundation` provides.

## Features

- [X] Modern, object-oriented API for accessing, reading and writing files.
- [X] Unified, simple `do, try, catch` error handling.
- [X] Easily to find and interact with saved files.
- [X] Unit tests for most of the use cases.

## Examples

Codable object
```swift
struct User: Codable {
    let name: String
    let lastName: String
}
```

CodableFiles shared reference.

```swift
let codableFiles = CodableFiles.shared
```

Save Codable object at default directory.
```swift
let user = User(name: "First name", lastName: "Last name")
let savePath = try? codableFiles.save(object: user, withFilename: "userModel")
```

Load Codable object from default directory.

```swift
let loadedObject = try? codableFiles.load(objectType: User.self, withFilename: "userModel")
```
## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate CodableFiles into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'CodableFiles'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate CodableFiles into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "egzonpllana/CodableFiles"
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding CodableFiles as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/egzonpllana/CodableFiles.git", .upToNextMajor(from: "0.1.0"))
]
```

### As a file

Since all of CodableFiles is implemented within a single file, you can easily use it in any project by simply dragging the file `CodableFiles.swift` into your Xcode project.

## Questions or feedback?

Feel free to [open an issue](https://github.com/egzonpllana/CodableFiles/issues/new), or find me [@egzonpllana on LinkedIn](https://www.linkedin.com/in/egzon-pllana/).
