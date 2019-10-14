# SwiftyXMLKit

## Availible Libraries

## [SwiftyXMLCoding](#SwiftyXMLCoding): **v0.6.2(Beta)**

 An XMLEncoder and XMLDecoder that serializes Swift's [`Encodable`](https://developer.apple.com/documentation/swift/encodable) and [`Decodable`](https://developer.apple.com/documentation/swift/decodable) protocols to XML using `PropertyWrapper`s to indicate XML Attributes and CData Strings

## Compatibility

Due to the use of `PropertyWrappers`, Swift 5.1+ is required, (included in Apple's 2019 major releases). For backwards-compatible parsers I recommend [SWXMLHash](https://github.com/drmohundro/SWXMLHash) and [XMLParsing](https://github.com/ShawnMoore/XMLParsing)

Currently only Apple platforms are supported. Support for other platforms is a secondary goal.

## Installation

### Swift Package Manager

Since SPM now has integrated support everywhere Swift 5.1 is used, there are currently no plans to support other dependency management tools. If SPM in unavailable, [Git-Submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules) is an option. More info can be found at the [SPM Website](https://swift.org/package-manager/)

If you're working directly in a Package, add SwiftyXMLKit to your Package.swift file

```swift
dependencies: [
    .package(url: "https://github.com/GottaGetSwifty/SwiftyXMLKit.git", .upToNextMajor(from: "0.6.0-beta" )),
]
```

If working in an Xcode project select `File->Swift Packages->Add Package Dependency...` and search for the package name: `SwiftyXMLKit` or the git url:

`https://github.com/GottaGetSwifty/SwiftyXMLKit.git`

# SwiftyXMLCoding

## Example

```swift
import SwiftyXMLCoding

let xmlStr = """
<?xml version="1.0"?>
<book id="bk101">
    <author>Gambardella, Matthew</author>
    <description><![CDATA[An in-depth look & analysis of creating applications with XML.]]></description>
    <genre>Computer</genre>
    <price>44.95</price>
    <publish_date>2000-10-01</publish_date>
    <title>XML Developer&apos;s Guide</title>
</book>
"""

struct Book: Codable {

    @XMLAttributeProperty
    var id: String

    var author: String
    var title: String
    var genre: String
    var price: Double

    @XMLCDataProperty
    var description: String
}

func decodeBookXML(from data: Data) -> Book? {
    do {
        // Verbose Decoding
        let book = try XMLDecoder().decode(Book.self, from: xmlData)
        return book
        
        // Concise Decoding:
        return try XMLDecoder().decode(from: xmlData)
    }
    catch  {
        print(error.localizedDescription)
        return nil
    }
}


func encodeBookAsXML(_ book: Book) -> String? {}
    do {
         /* utf8 Data Encoding
        let bookXMLData: Data = try XMLEncoder().encode(book, withRootKey: "book", header: XMLHeader(version: 1.0)
        */
        // String decoding
        return try XMLEncoder().encodeAsString(book, withRootKey: "book", header: XMLHeader(version: 1.0)
       
    }
    catch  {
        print(error.localizedDescription)
        return nil
    }
}
```
## Details

### The Problem Being Solved

Many current Swift libraries for working with XML have a more direct parsing approach. This is well suited for some use cases but heavy handed for basic XML import/export.

[Codable](https://developer.apple.com/documentation/swift/codable) enables a simplified Type-level declarative API that greatly reduces the amount of boilerplate needed for serialization.

Unfortunately previous to Swift 5.1 the only way to handle XML's complications like _Attributes_ was adding a way in the Serializer options to manually handle cases where a property should be mapped to an Attribute.

### Solution

Using a [Property Wrapper](https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md), this library enables the same declarative method for XML Attributes and CData Strings. These are also compatible with other Codable parsers (e.g. `JSON(En/De)coder`) allowing use of the same models for serializing XML and other formats.

### Formatting Options

Formatting options for `XMLEncoder` mirror [`JSONEncoder`](https://developer.apple.com/documentation/foundation/jsonencoder).

Formatting options for `XMLDecoder` mirror [`JSONDecoder`](https://developer.apple.com/documentation/foundation/jsondecoder).

## Future Directions/Improvements

### Testing

The goal is for this to be a _tested_ and easily _testable_ library. Given the constrained nature of the approach taken a robust test suite is very achievable. The bulk of this work (encoding/decoding) is already done. Performance testing and using real-world XML is next on the list.

### Other
* Have a declarative API for encoder's "root key"
* Replace other (En/De)coder options with a `PropertyWrapper`
* Platform-agnostic Support.
* Convert XMLDecoder to use SWXMLHash, Open up additional (simple) customization options for XMLDecoder and easier Linux support.
* Performance Unit Tests. There are likely places where speed can be optimized, but Performance Tests should be added first to avoid unintended regression.
* Github integration with CI pipline to automate Unit Tests for pushes and pull requests.
* Integrate SwiftLint.

## Acknowledgements

Thanks to the author of the project used as the seed: [XMLParsing](https://github.com/ShawnMoore/XMLParsing)! Much of it has been refactored, but it cut out a good amount of time that would've been spent wrangling Swift's `JSON(En/De)Coder` implementation to work with XML.

Thanks to [SWXMLHash](https://github.com/drmohundro/SWXMLHash) for handling my use cases until this was possible.

# Planned Additional Library Targets

## SwiftyXMLModelGenerator

A tool for generating Swift Models from XML. Default format will be for compatibility with SwiftyXMLCoding.

## SwiftyXMLStandards

A library with simple SwiftyXMLCoding compatible implementations of standardized XML Formats, e.g. RSS, Podcasts, etc.
