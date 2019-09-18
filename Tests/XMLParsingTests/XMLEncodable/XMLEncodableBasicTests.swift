//
//  XMLEncodableBasicTests.swift
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

class XMLEncodableBasicTests: QuickSpec {
    
    override func spec() {
        describe("XMLEncodable") {
            describe("EnodesSingleValueCorrectly") {
                context("WhenItemIs") {
                    describe("Bool") {
                        let _encoder = mockEncoder(options: mockOptions)
                        describe("WithText") {
                            it("Encodes'true'") {
                                expect { _ = try true.encodeAsAny(encoder: _encoder) }.toNot(throwError())
                                let value = try? true.encodeAsAny(encoder: _encoder)
                                expect(value).to(beAKindOf(String.self))
                                if let stringValue = value as? String {
                                    expect(stringValue) == "true"
                                }
                            }
                            it("Decodes'false'") {
                                expect { _ = try false.encodeAsAny(encoder: _encoder) }.toNot(throwError())
                                let value = try? false.encodeAsAny(encoder: _encoder)
                                expect(value).to(beAKindOf(String.self))
                                if let stringValue = value as? String {
                                    expect(stringValue) == "false"
                                }
                            }
                        }
                    }
                    describe("String") {
                        let _encoder = mockEncoder(options: mockOptions)
                        it("Encodes'hi'") {
                            expect { _ = try "hi".encodeAsAny(encoder: _encoder) }.toNot(throwError())
                            let value = try? "hi".encodeAsAny(encoder: _encoder)
                            expect(value).to(beAKindOf(String.self))
                            if let stringValue = value as? String {
                                expect(stringValue) == "hi"
                            }
                        }
                        it("Encodes''") {
                            expect { _ = try "".encodeAsAny(encoder: _encoder) }.toNot(throwError())
                            let value = try? "".encodeAsAny(encoder: _encoder)
                            expect(value).to(beAKindOf(String.self))
                            if let stringValue = value as? String {
                                expect(stringValue) == ""
                            }
                        }
                    }
//                    describe("CData") {
//                        let _encoder = mockEncoder(options: mockOptions)
//                        it("Encodes'hi'") {
//                            expect { _ = try XMLCDataProperty(wrappedValue: "hi").encodeAsAny(encoder: _encoder) }.toNot(throwError())
//                            let value = try? XMLCDataProperty(wrappedValue: "hi").encodeAsAny(encoder: _encoder)
//                            expect(value).to(beAKindOf(String.self))
//                            if let stringValue = value as? String {
//                                expect(stringValue) == "<![CDATA[hi]]>"
//                            }
//                        }
//                        it("Encodes''") {
//                            expect { _ = try XMLCDataProperty(wrappedValue: "").encodeAsAny(encoder: _encoder) }.toNot(throwError())
//                            let value = try? XMLCDataProperty(wrappedValue: "").encodeAsAny(encoder: _encoder)
//                            expect(value).to(beAKindOf(String.self))
//                            if let stringValue = value as? String {
//                                expect(stringValue) == "<![CDATA[]]>"
//                            }
//                        }
//                    }
                    describe("URL") {
                        let _encoder = mockEncoder(options: mockOptions)
                        it("Encodes'https://duckduckgo.com'") {
                            expect { _ = try URL(string: "https://duckduckgo.com")?.encodeAsAny(encoder: _encoder) }.toNot(throwError())
                            let value = try? URL(string: "https://duckduckgo.com")?.encodeAsAny(encoder: _encoder)
                            expect(value).to(beAKindOf(String.self))
                            if let stringValue = value as? String {
                                expect(stringValue) == "https://duckduckgo.com"
                            }
                        }
                    }
                    describe("NSURL") {
                        let _encoder = mockEncoder(options: mockOptions)
                        it("Encodes'https://duckduckgo.com'") {
                            expect { _ = try NSURL(string: "https://duckduckgo.com")?.encodeAsAny(encoder: _encoder) }.toNot(throwError())
                            let value = try? NSURL(string: "https://duckduckgo.com")?.encodeAsAny(encoder: _encoder)
                            expect(value).to(beAKindOf(String.self))
                            if let stringValue = value as? String {
                                expect(stringValue) == "https://duckduckgo.com"
                            }
                        }
                    }
                    describe("XMLAttributedProperty<Int>") {
                        let _encoder = mockEncoder(options: mockOptions)
                        it("Encodes'5'") {
                            expect { _ = try XMLAttributeProperty<Int>(wrappedValue: 5).encodeAsAny(encoder: _encoder) }.toNot(throwError())
                            let value = try? XMLAttributeProperty<Int>(wrappedValue: 5).encodeAsAny(encoder: _encoder)
                            expect(value).to(beAKindOf(String.self))
                            if let stringValue = value as? String {
                                expect(stringValue) == "5"
                            }
                        }
                    }
                }
            }
        }
    }
}
