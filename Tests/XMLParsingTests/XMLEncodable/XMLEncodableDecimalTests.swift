//
//  XMLEncodableDecimalTests.swift
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

class XMLEncodableDecimalTests: QuickSpec {
    
    override func spec() {
        describe("XMLEncodable") {
            describe("EncodesSingleValueCorrectly") {
                context("WhenItemIs") {
                    describe("Float") {
                        context("DefaultEncoder") {
                            let _encoder = mockEncoder(options: mockOptions)
                            it("Decodes'24.24'") {
                                expect { _ = try Float(24.24).encodeAsAny(encoder: _encoder)}.toNot(throwError())
                                let value = try? Float(24.24).encodeAsAny(encoder: _encoder)
                                expect(value).to(beAKindOf(String.self))
                                if let stringValue = value as? String {
                                    expect(stringValue) == "24.24"
                                }
                            }
                            it("Decodes'-24.24'") {
                                expect { _ = try Float(-24.24).encodeAsAny(encoder: _encoder)}.toNot(throwError())
                                let value = try? Float(-24.24).encodeAsAny(encoder: _encoder)
                                expect(value).to(beAKindOf(String.self))
                                if let stringValue = value as? String {
                                    expect(stringValue) == "-24.24"
                                }
                            }
                        }
//                        context("ConvertFromStringStrategy") {
//                            let encoder = XMLEncoder()
//                            encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "10", negativeInfinity: "-10", nan: "-1")
//                            let _encoder = mockEncoder(options: encoder.options)
//                            it("Decodes'24.24'") {
//                                expect { _ = try Float(24.24).encodeAsAny(encoder: _encoder)}.toNot(throwError())
//                                let value = try? Float(24.24).encodeAsAny(encoder: _encoder)
//                                expect(value).to(beAKindOf(String.self))
//                                if let stringValue = value as? String {
//                                    expect(stringValue) == "24.24"
//                                }
//                            }
//                            it("Decodes'-24.24'") {
//                                expect { _ = try Float(-24.24).encodeAsAny(encoder: _encoder)}.toNot(throwError())
//                                let value = try? Float(-24.24).encodeAsAny(encoder: _encoder)
//                                expect(value).to(beAKindOf(String.self))
//                                if let stringValue = value as? String {
//                                    expect(stringValue) == "-24.24"
//                                }
//                            }
//                            it("Decodes'infinity'") {
//                                expect { _ = try Float.infinity.encodeAsAny(encoder: _encoder)}.toNot(throwError())
//                                let value = try? Float.infinity.encodeAsAny(encoder: _encoder)
//                                expect(value).to(beAKindOf(String.self))
//                                if let stringValue = value as? String {
//                                    expect(stringValue) == "10"
//                                }
//                            }
//                            it("Decodes'-infinity'") {
//                                expect { _ = try (-Float.infinity).encodeAsAny(encoder: _encoder)}.toNot(throwError())
//                                let value = try? (-Float.infinity).encodeAsAny(encoder: _encoder)
//                                expect(value).to(beAKindOf(String.self))
//                                if let stringValue = value as? String {
//                                    expect(stringValue) == "-10"
//                                }
//                            }
//                            it("Decodes'nan'") {
//
//                                expect { _ = try (Float.nan).encodeAsAny(encoder: _encoder)}.toNot(throwError())
//                                let value = try? (Float.nan).encodeAsAny(encoder: _encoder)
//                                expect(value).to(beAKindOf(String.self))
//                                if let stringValue = value as? String {
//                                    expect(stringValue) == "-1"
//                                }
//                            }
//                        }
                    }
                    describe("Double") {
                        context("DefaultEncoder") {
                            let _encoder = mockEncoder(options: mockOptions)
                            it("Decodes'24.24'") {
                                expect { _ = try Double(24.24).encodeAsAny(encoder: _encoder)}.toNot(throwError())
                                let value = try? Double(24.24).encodeAsAny(encoder: _encoder)
                                expect(value).to(beAKindOf(String.self))
                                if let stringValue = value as? String {
                                    expect(stringValue) == "24.24"
                                }
                            }
                            it("Decodes'-24.24'") {
                                expect { _ = try Double(-24.24).encodeAsAny(encoder: _encoder)}.toNot(throwError())
                                let value = try? Double(-24.24).encodeAsAny(encoder: _encoder)
                                expect(value).to(beAKindOf(String.self))
                                if let stringValue = value as? String {
                                    expect(stringValue) == "-24.24"
                                }
                            }
                        }
//                        context("ConvertFromStringStrategy") {
//                            let encoder = XMLEncoder()
//                            encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "10", negativeInfinity: "-10", nan: "-1")
//                            let _encoder = mockEncoder(options: encoder.options)
//                            print(_encoder.options)
//                            it("Decodes'24.24'") {
//                                expect { _ = try Double(24.24).encodeAsAny(encoder: _encoder)}.toNot(throwError())
//                                let value = try? Double(24.24).encodeAsAny(encoder: _encoder)
//                                expect(value).to(beAKindOf(String.self))
//                                if let stringValue = value as? String {
//                                    expect(stringValue) == "24.24"
//                                }
//                            }
//                            it("Decodes'-24.24'") {
//                                expect { _ = try Double(-24.24).encodeAsAny(encoder: _encoder)}.toNot(throwError())
//                                let value = try? Double(-24.24).encodeAsAny(encoder: _encoder)
//                                expect(value).to(beAKindOf(String.self))
//                                if let stringValue = value as? String {
//                                    expect(stringValue) == "-24.24"
//                                }
//                            }
//                            it("Decodes'infinity'") {
//                                expect { _ = try Double.infinity.encodeAsAny(encoder: _encoder)}.toNot(throwError())
//                                let value = try? Double.infinity.encodeAsAny(encoder: _encoder)
//                                expect(value).to(beAKindOf(String.self))
//                                if let stringValue = value as? String {
//                                    expect(stringValue) == "10"
//                                }
//                            }
//                            it("Decodes'-infinity'") {
//                                expect { _ = try (-Double.infinity).encodeAsAny(encoder: _encoder)}.toNot(throwError())
//                                let value = try? (-Double.infinity).encodeAsAny(encoder: _encoder)
//                                expect(value).to(beAKindOf(String.self))
//                                if let stringValue = value as? String {
//                                    expect(stringValue) == "-10"
//                                }
//                            }
//                            it("Decodes'nan'") {
//
//                                expect { _ = try (Double.nan).encodeAsAny(encoder: _encoder)}.toNot(throwError())
//                                let value = try? (Double.nan).encodeAsAny(encoder: _encoder)
//                                expect(value).to(beAKindOf(String.self))
//                                if let stringValue = value as? String {
//                                    expect(stringValue) == "-1"
//                                }
//                            }
//                        }
                        describe("Decimal") {
                            context("DefaultDecoder") {
                                let _encoder = mockEncoder(options: mockOptions)
                                it("Decodes'24.24'") {
                                    expect { _ = try Decimal(24.24).encodeAsAny(encoder: _encoder)}.toNot(throwError())
                                    let value = try? Decimal(24.24).encodeAsAny(encoder: _encoder)
                                    expect(value).to(beAKindOf(NSDecimalNumber.self))
                                    if let decimalNumberValue = value as? NSDecimalNumber {
                                        expect(decimalNumberValue) == NSDecimalNumber(24.24)
                                    }
                                }
                                it("Decodes'-24.24'") {
                                    expect { _ = try Decimal(-24.24).encodeAsAny(encoder: _encoder)}.toNot(throwError())
                                    let value = try? Decimal(-24.24).encodeAsAny(encoder: _encoder)
                                    expect(value).to(beAKindOf(NSDecimalNumber.self))
                                    if let decimalNumberValue = value as? NSDecimalNumber {
                                        expect(decimalNumberValue) == NSDecimalNumber(-24.24)
                                    }
                                }
                            }
                        }
                        describe("NSDecimalNumber") {
                            context("DefaultDecoder") {
                                let _encoder = mockEncoder(options: mockOptions)
                                it("Decodes'24.24'") {
                                    expect { _ = try NSDecimalNumber(24.24).encodeAsAny(encoder: _encoder)}.toNot(throwError())
                                    let value = try? NSDecimalNumber(24.24).encodeAsAny(encoder: _encoder)
                                    expect(value).to(beAKindOf(NSDecimalNumber.self))
                                    if let decimalNumberValue = value as? NSDecimalNumber {
                                        expect(decimalNumberValue) == NSDecimalNumber(24.24)
                                    }
                                }
                                it("Decodes'-24.24'") {
                                    expect { _ = try NSDecimalNumber(-24.24).encodeAsAny(encoder: _encoder)}.toNot(throwError())
                                    let value = try? NSDecimalNumber(-24.24).encodeAsAny(encoder: _encoder)
                                    expect(value).to(beAKindOf(NSDecimalNumber.self))
                                    if let decimalNumberValue = value as? NSDecimalNumber {
                                        expect(decimalNumberValue) == NSDecimalNumber(-24.24)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
