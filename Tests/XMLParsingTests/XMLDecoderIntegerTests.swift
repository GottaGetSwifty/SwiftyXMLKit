//
//  File.swift
//  
//
//  Created by Paul Fechner Jr on 9/5/19.
//

@testable import SwiftyXMLCoding
import Foundation
import Quick
import Nimble

private let decoder: XMLDecoder = {
    let decoder = XMLDecoder()
    return decoder
}()

private struct SingleValue<T: Decodable>: Decodable {
    let value: T
}
private func mockDecoder(options: XMLDecoder._Options) -> _XMLDecoder {
    _XMLDecoder(referencing: "", options: options)
}

private let mockOptions = XMLDecoder().options

class XMLDecoderIntegerTests: QuickSpec {

    
    func testSignedFixedWidthInt<T: FixedWidthInteger>(type: T.Type) where T: Decodable, T: SignedInteger, T: XMLDecodable {
        let _decoder = mockDecoder(options: mockOptions)
        it("DecodesPositive") {
            expect{_ = try T.unbox("5", decoder: _decoder)}.toNot(throwError())
            let decodedValue = try! T.unbox("5", decoder: _decoder)
            expect(decodedValue) == 5
        }
        it("DecodesNegative") {
            expect{_ = try T.unbox("-5", decoder: _decoder)}.toNot(throwError())
            let decodedValue = try! T.unbox("-5", decoder: _decoder)
            expect(decodedValue) == -5
        }
        it("FailsDecodingText") {
            expect{_ = try T.unbox("five", decoder: _decoder)}.to(throwError())
        }
        it("FailsDecodingGreaterThanMax") {
            expect{_ = try T.unbox("\(type.max)1", decoder: _decoder)}.to(throwError())
        }
        it("FailsDecodingLessThanMin") {
            expect{_ = try T.unbox("\(type.min)1", decoder: _decoder)}.to(throwError())
        }
    }
    
    func testUnsignedFixedWidthInt<T: FixedWidthInteger>(type: T.Type) where T: Decodable, T: UnsignedInteger, T: XMLDecodable {
        let _decoder = mockDecoder(options: mockOptions)
        it("DecodesPositive") {
            expect{_ = try T.unbox("5", decoder: _decoder)}.toNot(throwError())
            let decodedValue = try! T.unbox("5", decoder: _decoder)
            expect(decodedValue) == 5
        }
        it("FailsDecodingNegative") {
            expect{_ = try T.unbox("-1", decoder: _decoder)}.to(throwError())
        }
        it("FailsDecodingText") {
            expect{_ = try T.unbox("five", decoder: _decoder)}.to(throwError())
        }
        it("FailsDecodingGreaterThanMax") {
            expect{_ = try T.unbox("\(type.max)1", decoder: _decoder)}.to(throwError())
        }
    }
    
    override func spec() {
        describe("XMLDecoder") {
            describe("DecodesSingleValueCorrectly") {
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
