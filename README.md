# SwiftyXMLKit

## Included Libraries

## [SwiftyXMLCoding](#SwiftyXMLCoding): **V0.5(Beta )**

#### An XMLEncoder and XMLDecoder using Swift's `Encodable` and `Decodable` protocols with a `PropertyWrapper` to handle XML Attributes.

### [SwiftyXMLModelGenerator](#SwiftyXMLModelGenerator): **Coming Soon**

#### A tool for generating Swift Models from XML. Default will be for the models to be compatible with SwiftyXMLCoding.

### [SwiftyXMLStandards](#SwiftyXMLStandards): **Coming Soon**

#### A library with Simple implementations of standardized XML Formats, e.g. RSS, Podcasts, etc.

## Installation

### Swift Package Manager

Since SPM now has integrated support everywhere Swift is used and modern Swift is required anyway, there are currently no plans to support any other dependency management tool. More info can be found [here](https://swift.org/package-manager/) 

If you're working directly in a Package, add SwiftyXMLKit to you Package.swift file

```swift
dependencies: [
    .package(url: "https://github.com/PeeJWeeJ/SwiftyXMLKit.git", .upToNextMajor(from: "0.0.0" )),
]
```

Otherwise In your Xcode project go to `File->Swift Packages->Add Package Dependency...`, and search for the git url:

`https://github.com/PeeJWeeJ/SwiftyXMLKit.git`

# SwiftyXMLCoding

## Example
```swift
import SwiftyXMLCoding

let xmlStr = """
<?xml version="1.0"?>
<book id="bk101">
    <author>Gambardella, Matthew</author>
    <description>An in-depth look at creating applications with XML.</description>
    <genre>Computer</genre>
    <price>44.95</price>
    <publish_date>2000-10-01</publish_date>
    <title>XML Developer&apos;s Guide</title>
</book>
"""
    
struct Book: Codable, Equatable {
    
    @XMLAttributeProperty 
    var id: String

    var author: String
    var title: String
    var genre: String
    var price: Double
    var description: String
}

if let xmlData = xmlStr.data(using: .utf8) {
    do {
        let book: Book = try XMLDecoder().decode(from: xmlData)
        //or
        let book = try XMLDecoder().decode(Book.self, from: xmlData)
        // Use your decoded Book
    }
    catch  {
        print(error.localizedDescription)
    }
     
}
```

## Compatability

Due to the use of a PropertyWrapper, Swift 5.1+ is required, which is included in iOS 13 and macOS 10.15. For backwards-compatable parsers I recommend [SWXMLHash](https://github.com/drmohundro/SWXMLHash) and [XMLParsing](https://github.com/ShawnMoore/XMLParsing)

Linux is not currently supported, but is a future goal.

## Details

### What Problem's Being Solved?
Many existing methods of dealing with XML in Swift take a more direct parsing approach. This is well suited for some situations, but is heavy handed for basic xml import/export.

Codable allows a simplified, Type-level declarative approach that greatly reduces the amount of boilerplate need to for serialization. 

Unfortunately previous to Swift 5.1 the only way to handle XML's complications like _Attributes_ was adding an way in the Serializers to manually handle cases where a property should be mapped to an Attribute. 

### Solution
Using a [Property Wrapper](https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md), this library enables the same declarative method for XML Attributes. These are also compatable with `JSON(En/De)coder` allowing use of the same models for serializing XML and JSON.


### Formatting Options

XMLEncoder's formatting options mirror [JSONEncoder](https://developer.apple.com/documentation/foundation/jsonencoder) and XMLDecoder's formatting options mirror [JSONDecoder](https://developer.apple.com/documentation/foundation/jsondecoder).

Currently the only additional option available is `XMLEncoder.StringEncodingStrategy.cdata`.

### Unit Tests

The goal is for this to be a _testable_ and _tested_ library. Given the constrained nature of the libraries approach a robust test suite is very achievable. The bulk of this work (encoding/decoding) is already done.

## Future Directions/Improvements

* Support declarative CData String setting with a PropertyWrapper.
* Platform-agnostic Support.
* Convert XMLDecoder to use SWXMLHash, Open up additional (simple) customization options for XMLDecoder and easier Linux support.
* Performance Unit Tests. There are likely places where speed can be optimized, but Performance Tests should be added first to avoid unintended regression.
* Github integration with CI pipline to automate Unit Tests for pushes and pull requests.
* Integrate SwiftLint.

## Acknowledgements

Thanks to the originator of the project used as the seed: [XMLParsing](https://github.com/ShawnMoore/XMLParsing)! Much of it has been heavily refactored, but it cut out a good amount of time that would've been spent wrangling Swift's `JSON(En/De)Coder` implementation to work with XML.

Thanks to [SWXMLHash](https://github.com/drmohundro/SWXMLHash) for handling my use cases until this was possible.

# SwiftyXMLModelGenerator

### Description

A tool for generating Swift Models from XML. Default will be for the models to be compatible with SwiftyXMLCoding.

# SwiftyXMLStandards

### Description
A library with Simple implementations of standardized XML Formats, e.g. RSS, Podcasts, etc.
