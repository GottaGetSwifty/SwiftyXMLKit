//
//  BookTests.swift
//  
//  Created by PJ Fechner on 9/5/19.
//  Copyright © 2019 PJ Fechner. All rights reserved.
//

@testable import SwiftyXMLCoding
import Foundation
import Quick
import Nimble

private let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()

class SerializationTests: QuickSpec {
    
    let encoder: XMLEncoder = {
        let encoder = XMLEncoder()
//        encoder.dateEncodingStrategy = .formatted(formatter)
        return encoder
    }()
    let decoder: XMLDecoder = {
        let decoder = XMLDecoder()
//        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }()
    
    private func compareOptions(_ left: OptionsTestType, _ right: OptionsTestType) {
        expect(left.millesecondsSinceDate) == right.millesecondsSinceDate
    }
    
    override func spec() {
        describe("XMLDecoding") {
            describe("Coding") {
                it("Encodes") {
                    let data = try! self.encoder.encode(testItem, withRootKey: "options", header: XMLHeader(version: 1.0))
                    let xmlString = String(data: data, encoding: .utf8)!
                    expect(xmlString).to(haveEqualLines(to: testXML))
                }
                it("Decodes") {
                    let data = testXML.data(using: .utf8)!
                    expect{_ = try self.decoder.decode(OptionsTestType.self, from: data)}.toNot(throwError())
                    let decodedItem = try? self.decoder.decode(OptionsTestType.self, from: data)
                    expect(decodedItem).toNot(beNil())
                    if let realItem = decodedItem {
                        self.compareOptions(realItem, testItem)
                    }
                }
            }
        }
    }
}

private struct OptionsTestType: Codable {
    @CustomCoding<DateCoders.MillisecondsSince1970>
    var millesecondsSinceDate: Date
    
    //TODO: Test for a CData attribute when multiple PropertyWrappers are supported
    @XMLAttributeProperty  var id: String
}

private let testItem = OptionsTestType(millesecondsSinceDate: Date(timeIntervalSince1970: 12345.678), id: "Test CData")
private let testXML = """
<?xml version="1.0"?>
<options id="Test CData">
    <millesecondsSinceDate>12345678.0</millesecondsSinceDate>
</options>
"""
