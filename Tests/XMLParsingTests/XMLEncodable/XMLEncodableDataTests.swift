//
//  XMLEncodableDataTests.swift
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

private func mockEncoder() -> _XMLEncoder {
    let localEncoder = encoder
//    localEncoder.dataEncodingStrategy = dataStrategy
    return mockEncoder(options: localEncoder.options)
}

private func mockEncoder(options: XMLEncoder._Options) -> _XMLEncoder {
    _XMLEncoder(options: options)
}

class XMLEncodableDataTests: QuickSpec {
    
    override func spec() {
        describe("XMLEncodable") {
            describe("EncodesSingleValueCorrectly") {
                context("WhenItemIs") {
//                    context("DataWithStrategy") {
//                        context("deferredToData") {
//                            let _encoder = mockEncoder(dataStrategy: .deferredToData)
//                            it("Encodes'Oh, Hi Mark!'") {
//                                let data = ["79", "104", "44", "32", "72", "105", "32", "77", "97", "114", "107", "33"]
//                                expect { _ = try "Oh, Hi Mark!".data(using: .utf8)?.encodeAsAny(encoder: _encoder) }.toNot(throwError())
//                                let value = try? "Oh, Hi Mark!".data(using: .utf8)?.encodeAsAny(encoder: _encoder)
//                                expect(value).to(beAKindOf([String].self))
//                                if let stringValue = value as? [String] {
//                                    expect(stringValue) == data
//                                }
//                            }
//                        }
//                        context("Custom(via Data)") {
//                            let _encoder = mockEncoder(dataStrategy: .custom({try $0.encode(to: $1) }) )
//                            it("Encodes'Oh, Hi Mark!'") {
//                                let data = ["79", "104", "44", "32", "72", "105", "32", "77", "97", "114", "107", "33"]
//                                expect { _ = try "Oh, Hi Mark!".data(using: .utf8)?.encodeAsAny(encoder: _encoder) }.toNot(throwError())
//                                let value = try? "Oh, Hi Mark!".data(using: .utf8)?.encodeAsAny(encoder: _encoder)
//                                expect(value).to(beAKindOf([String].self))
//                                if let stringValue = value as? [String] {
//                                    expect(stringValue) == data
//                                }
//                            }
//                        }
//                        context("Base64String") {
//                            let _encoder = mockEncoder(dataStrategy: .base64)
//                            it("Encodes'Oh, Hi Mark!'") {
//                                expect { _ = try "Oh, Hi Mark!".data(using: .utf8)?.encodeAsAny(encoder: _encoder) }.toNot(throwError())
//                                let value = try? "Oh, Hi Mark!".data(using: .utf8)?.encodeAsAny(encoder: _encoder)
//                                expect(value).to(beAKindOf(String.self))
//                                if let stringValue = value as? String {
//                                    expect(stringValue) == "T2gsIEhpIE1hcmsh"
//                                }
//                            }
//                        }
//                    }
//                    context("NSDataWithStrategy") {
//                        context("deferredToData") {
//                            let _encoder = mockEncoder(dataStrategy: .deferredToData)
//                            it("Encodes'Oh, Hi Mark!'") {
//                                let data = ["79", "104", "44", "32", "72", "105", "32", "77", "97", "114", "107", "33"]
//                                expect { _ = try ("Oh, Hi Mark!".data(using: .utf8) as NSData?)?.encodeAsAny(encoder: _encoder) }.toNot(throwError())
//                                let value = try? ("Oh, Hi Mark!".data(using: .utf8) as NSData?)?.encodeAsAny(encoder: _encoder)
//                                expect(value).to(beAKindOf([String].self))
//                                if let stringValue = value as? [String] {
//                                    expect(stringValue) == data
//                                }
//                            }
//                        }
//                    }
                }
            }
        }
    }
}
