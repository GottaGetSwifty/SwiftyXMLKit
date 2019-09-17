# SwiftyXMLKit

## Availible Libraries

## [SwiftyXMLCoding](#SwiftyXMLCoding): **V0.6.0(Beta )**

 An XMLEncoder and XMLDecoder that serializes Swift's `[Encodable](https://developer.apple.com/documentation/swift/encodable)` and `[Decodable](https://developer.apple.com/documentation/swift/decodable)` protocols to XML using `PropertyWrapper`s to indicate XML Attributes and CData Strings

## Installation

### Swift Package Manager

Since SPM now has integrated support everywhere Swift is used and modern Swift is required anyway, there are currently no plans to support any other dependency management tool. More info can be found at the [SPM Website](https://swift.org/package-manager/)

If you're working directly in a Package, add SwiftyXMLKit to your Package.swift file

```swift
dependencies: [
    .package(url: "https://github.com/PeeJWeeJ/SwiftyXMLKit.git", .upToNextMajor(from: "0.6.0-beta" )),
]
```

Otherwise In your Xcode project select `File->Swift Packages->Add Package Dependency...` and search for the package name: `SwiftyXMLKit` or git url:

`https://github.com/PeeJWeeJ/SwiftyXMLKit.git`

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
        // Decode the data
        /*
        Verbose version:
        let book = try XMLDecoder().decode(Book.self, from: xmlData)
        return book
        */
        // Concise Version:
        return try XMLDecoder().decode(from: xmlData)
    }
    catch  {
        print(error.localizedDescription)
        return nil
    }
}


func encodeBookAsXML(_ book: Book) -> String? {}
    do {
         /* encode as utf8 Data
        let bookXMLData: Data = try XMLEncoder().encode(book, withRootKey: "book", header: XMLHeader(version: 1.0)
        */
        // encode as a String:
        return try XMLEncoder().encodeAsString(book, withRootKey: "book", header: XMLHeader(version: 1.0)
       
    }
    catch  {
        print(error.localizedDescription)
        return nil
    }
}
```

## Compatibility

Due to the use of a PropertyWrapper, Swift 5.1+ is required, which is included in iOS 13 and macOS 10.15. For backwards-compatible parsers I recommend [SWXMLHash](https://github.com/drmohundro/SWXMLHash) and [XMLParsing](https://github.com/ShawnMoore/XMLParsing)

Linux is not currently supported, but is a future goal.

## Details

### What Problem's Being Solved?

Many existing methods of dealing with XML in Swift take a more direct parsing approach. This is well suited for some situations, but is heavy handed for basic xml import/export.

[Codable](https://developer.apple.com/documentation/swift/codable) allows a simplified, Type-level declarative approach that greatly reduces the amount of boilerplate need to for serialization.

Unfortunately previous to Swift 5.1 the only way to handle XML's complications like _Attributes_ was adding an way in the Serializers to manually handle cases where a property should be mapped to an Attribute.

### Solution

Using a [Property Wrapper](https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md), this library enables the same declarative method for XML Attributes. These are also compatible with `JSON(En/De)coder` allowing use of the same models for serializing XML and JSON.

### Formatting Options

XMLEncoder's formatting options mirror [JSONEncoder](https://developer.apple.com/documentation/foundation/jsonencoder) and XMLDecoder's formatting options mirror [JSONDecoder](https://developer.apple.com/documentation/foundation/jsondecoder).

### Unit Tests

The goal is for this to be a _testable_ and _tested_ library. Given the constrained nature of the libraries approach a robust test suite is very achievable. The bulk of this work (encoding/decoding) is already done.

## Future Directions/Improvements

* Platform-agnostic Support.
* Convert XMLDecoder to use SWXMLHash, Open up additional (simple) customization options for XMLDecoder and easier Linux support.
* Performance Unit Tests. There are likely places where speed can be optimized, but Performance Tests should be added first to avoid unintended regression.
* Github integration with CI pipline to automate Unit Tests for pushes and pull requests.
* Integrate SwiftLint.

## Acknowledgements

Thanks to the originator of the project used as the seed: [XMLParsing](https://github.com/ShawnMoore/XMLParsing)! Much of it has been heavily refactored, but it cut out a good amount of time that would've been spent wrangling Swift's `JSON(En/De)Coder` implementation to work with XML.

Thanks to [SWXMLHash](https://github.com/drmohundro/SWXMLHash) for handling my use cases until this was possible.

# Planned Additional Library Targets

## SwiftyXMLModelGenerator

A tool for generating Swift Models from XML. Default format will be for the models formatted for SwiftyXMLCoding.

## SwiftyXMLStandards

A library with Simple implementations of standardized XML Formats, e.g. RSS, Podcasts, etc.
