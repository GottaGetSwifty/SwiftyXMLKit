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

private let encoder: XMLEncoder = {
    let encoder = XMLEncoder()
    return encoder
}()

private struct SingleValue<T: Decodable>: Decodable {
    let value: T
}

private func mockEncoder(dateStrategy: XMLEncoder.DateEncodingStrategy) -> _XMLEncoder {
    let localEncoder = encoder
    localEncoder.dateEncodingStrategy = dateStrategy
    return mockEncoder(options: encoder.options)
}

private func mockEncoder(options: XMLEncoder._Options) -> _XMLEncoder {
    _XMLEncoder(options: options)
}

class XMLEncodableDateTests: QuickSpec {
    
    override func spec() {
        describe("XMLEncodable") {
            describe("DecodesSingleValueCorrectly") {
                context("WhenItemIs") {
                    context("DateWithStrategy") {
                        context("defferedToDate(timeIntervalSinceReferenceDate)") {
                            let _encoder = mockEncoder(dateStrategy: .deferredToDate)
                            it("Encodes'590277534'") {
                                expect { _ = try Date(timeIntervalSinceReferenceDate: 590277534).encodeAsAny(encoder: _encoder) }.toNot(throwError())
                                let value = try? Date(timeIntervalSinceReferenceDate: 590277534).encodeAsAny(encoder: _encoder)
                                expect(value).to(beAKindOf(String.self))
                                if let stringValue = value as? String {
                                    expect(stringValue) == "590277534.0"
                                }
                            }
                        }
                        context("secondsSince1970") {
                            let _encoder = mockEncoder(dateStrategy: .secondsSince1970)
                            it("Encodes'590277534'") {
                                expect { _ = try Date(timeIntervalSince1970: 590277534).encodeAsAny(encoder: _encoder) }.toNot(throwError())
                                let value = try? Date(timeIntervalSince1970: 590277534).encodeAsAny(encoder: _encoder)
                                expect(value).to(beAKindOf(String.self))
                                if let stringValue = value as? String {
                                    expect(stringValue) == "590277534.0"
                                }
                            }
                        }
                        context("secondsSince1970") {
                            let _encoder = mockEncoder(dateStrategy: .millisecondsSince1970)
                            it("Encodes'590277534'") {
                                expect { _ = try Date(timeIntervalSince1970: 590277.534).encodeAsAny(encoder: _encoder) }.toNot(throwError())
                                let value = try? Date(timeIntervalSince1970: 590277.534).encodeAsAny(encoder: _encoder)
                                expect(value).to(beAKindOf(String.self))
                                if let stringValue = value as? String, let doubleValue = Double(stringValue) {
                                    expect(doubleValue) ≈ 590277534.0
                                }
                            }
                        }
                        if #available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                            context("iso8601") {
                                let _encoder = mockEncoder(dateStrategy: .iso8601)
                                
                                it("Encodes'2008-09-15T10:53:00Z'") {
                                    expect { _ = try ISO8601DateFormatter().date(from: "2008-09-15T10:53:00Z")? .encodeAsAny(encoder: _encoder) }.toNot(throwError())
                                    let value = try? ISO8601DateFormatter().date(from: "2008-09-15T10:53:00Z")?.encodeAsAny(encoder: _encoder)
                                    expect(value).to(beAKindOf(String.self))
                                    if let stringValue = value as? String {
                                        expect(stringValue) == "2008-09-15T10:53:00Z"
                                    }
                                }
                            }
                        }
                        context("formatted") {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "MM/dd/yy H:mm:ss zzz"
                            let _encoder = mockEncoder(dateStrategy: .formatted(formatter))
                            
                            it("Encodes'06/10/11 15:24:16 +00:00'") {
                                expect { _ = try formatter.date(from: "06/10/11 15:24:16 +00:00")?.encodeAsAny(encoder: _encoder) }.toNot(throwError())
                                let value = try? formatter.date(from: "06/10/11 15:24:16 +00:00")?.encodeAsAny(encoder: _encoder)
                                expect(value).to(beAKindOf(String.self))
                                if let stringValue = value as? String, let date = formatter.date(from: stringValue) {
                                    expect(date) == formatter.date(from: "06/10/11 15:24:16 +00:00")
                                }
                            }
                        }
                        context("custom") {
                            let customEncoder = { (date: Date, encoder: Encoder) throws in
                                try date.encode(to: encoder)
                            }
                            let _encoder = mockEncoder(dateStrategy: .custom(customEncoder))
                            it("Encodes'590277534'") {
                                expect { _ = try Date(timeIntervalSinceReferenceDate: 590277534).encodeAsAny(encoder: _encoder) }.toNot(throwError())
                                let value = try? Date(timeIntervalSinceReferenceDate: 590277534).encodeAsAny(encoder: _encoder)
                                expect(value).to(beAKindOf(String.self))
                                if let stringValue = value as? String {
                                    expect(stringValue) == "590277534.0"
                                }
                            }
                        }
                    }
                    context("NSDateWithStrategy") {
                        context("defferedToDate(timeIntervalSinceReferenceDate)") {
                            let _encoder = mockEncoder(dateStrategy: .deferredToDate)
                            it("Encodes'590277534'") {
                                expect { _ = try NSDate(timeIntervalSinceReferenceDate: 590277534).encodeAsAny(encoder: _encoder) }.toNot(throwError())
                                let value = try? NSDate(timeIntervalSinceReferenceDate: 590277534).encodeAsAny(encoder: _encoder)
                                expect(value).to(beAKindOf(String.self))
                                if let stringValue = value as? String {
                                    expect(stringValue) == "590277534.0"
                                }
                            }                        }
                    }
                }
            }
        }
    }
}
