//
//  XMLEncodableIntegerTests.swift
//  
//
//  Created by PJ Fechner on 9/5/19.
//  Copyright © 2019 PJ Fechner. All rights reserved.
//

@testable import SwiftyXMLCoding
import Foundation
import Quick
import Nimble

private let encoder: XMLEncoder = {
    let encoder = XMLEncoder()
    return encoder
}()

private struct SingleValue<T: Decodable>: Decodable {
    let value: T
}
private func mockEncoder(options: XMLEncoder._Options) -> _XMLEncoder {
    _XMLEncoder(options: options)
}

private let mockOptions = XMLEncoder().options

class XMLEncodableIntegerTests: QuickSpec {

    
    func testSignedFixedWidthInt<T: FixedWidthInteger>(type: T.Type) where T: Decodable, T: SignedInteger, T: XMLEncodable {
        let _encoder = mockEncoder(options: mockOptions)
        it("DecodesPositive") {
            expect{_ = try T("5")?.encodeAsAny(encoder: _encoder)}.toNot(throwError())
            let value = try? T("5")?.encodeAsAny(encoder: _encoder)
            expect(value).to(beAKindOf(String.self))
            if let stringValue = value as? String {
                expect(stringValue) == "5"
            }
        }
        it("DecodesNegative") {
            expect{_ = try T("-5")?.encodeAsAny(encoder: _encoder)}.toNot(throwError())
            let value = try? T("-5")?.encodeAsAny(encoder: _encoder)
            expect(value).to(beAKindOf(String.self))
            if let stringValue = value as? String {
                expect(stringValue) == "-5"
            }
        }
    }
    
    func testUnsignedFixedWidthInt<T: FixedWidthInteger>(type: T.Type) where T: Decodable, T: UnsignedInteger, T: XMLEncodable {
        let _encoder = mockEncoder(options: mockOptions)
        it("DecodesPositive") {
            expect{_ = try T("5")?.encodeAsAny(encoder: _encoder)}.toNot(throwError())
            let value = try? T("5")?.encodeAsAny(encoder: _encoder)
            expect(value).to(beAKindOf(String.self))
            if let stringValue = value as? String {
                expect(stringValue) == "5"
            }
        }
    }
    
    override func spec() {
        describe("XMLDecodable") {
            describe("EncodesSingleValueCorrectly") {
                context("WhenItemIs") {
                    describe("Int") {
                        testSignedFixedWidthInt(type: Int.self)
                    }
                    describe("Int8") {
                        testSignedFixedWidthInt(type: Int8.self)
                    }
                    describe("Int16") {
                        testSignedFixedWidthInt(type: Int16.self)
                    }
                    describe("Int32") {
                        testSignedFixedWidthInt(type: Int32.self)
                    }
                    describe("Int64") {
                        testSignedFixedWidthInt(type: Int64.self)
                    }
                    describe("UInt") {
                        testUnsignedFixedWidthInt(type: UInt.self)
                    }
                    describe("UInt8") {
                        testUnsignedFixedWidthInt(type: UInt8.self)
                    }
                    describe("UInt16") {
                        testUnsignedFixedWidthInt(type: UInt16.self)
                    }
                    describe("UInt32") {
                        testUnsignedFixedWidthInt(type: UInt32.self)
                    }
                    describe("UInt64") {
                        testUnsignedFixedWidthInt(type: UInt64.self)
                    }
                }
            }
        }
    }
}
