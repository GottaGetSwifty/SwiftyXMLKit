//
//  XMLDecodableDataTests.swift
//  
//
//  Created by PJ Fechner on 9/5/19.
//  Copyright © 2019 PJ Fechner. All rights reserved.
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

private func mockDecoder(dataStrategy: XMLDecoder.DataDecodingStrategy) -> _XMLDecoder {
    let localDecoder = decoder
    localDecoder.dataDecodingStrategy = dataStrategy
    return mockDecoder(options: decoder.options)
}

private func mockDecoder(options: XMLDecoder._Options) -> _XMLDecoder {
    _XMLDecoder(referencing: "", options: options)
}

private let mockOptions = XMLDecoder().options

class XMLDecodableDataTests: QuickSpec {
    
    override func spec() {
        describe("XMLDecodable") {
            describe("DecodesSingleValueCorrectly") {
                context("WhenItemIs") {
                    context("DataWithStrategy") {
                        context("deferredToData") {
                            let _decoder = mockDecoder(dataStrategy: .deferredToData)
                            it("Decodes'Oh, Hi Mark!'") {
                                let data = ["79", "104", "44", "32", "72", "105", "32", "77", "97", "114", "107", "33"]
                                expect { _ = try Data.unbox(data, decoder: _decoder) }.toNot(throwError())
                                    if let value = try? Data.unbox(data, decoder: _decoder), let stringValue = String(data: value, encoding: .utf8) {
                                    expect(stringValue) == "Oh, Hi Mark!"
                                }
                            }
                        }
                        context("Custom(via Data)") {
                            let _decoder = mockDecoder(dataStrategy: .custom({try Data(from:$0)}))
                            it("Decodes'Oh, Hi Mark!'") {
                                let data = ["79", "104", "44", "32", "72", "105", "32", "77", "97", "114", "107", "33"]
                                expect { _ = try Data.unbox(data, decoder: _decoder) }.toNot(throwError())
                                    if let value = try? Data.unbox(data, decoder: _decoder), let stringValue = String(data: value, encoding: .utf8) {
                                    expect(stringValue) == "Oh, Hi Mark!"
                                }
                            }
                        }
                        context("Base64String") {
                            let _decoder = mockDecoder(dataStrategy: .base64)
                            it("Decodes'Oh, Hi Mark!'") {
                                expect { _ = try Data.unbox("T2gsIEhpIE1hcmsh", decoder: _decoder) }.toNot(throwError())
                                    if let value = try? Data.unbox("T2gsIEhpIE1hcmsh", decoder: _decoder), let stringValue = String(data: value, encoding: .utf8) {
                                    expect(stringValue) == "Oh, Hi Mark!"
                                }
                            }
                            it("FailsDecoding'5'") {
                                expect { _ = try Data.unbox(5, decoder: _decoder) }.to(throwError())
                            }
                            it("FailsDecoding'2o8&@O87n3n98N'") {
                                expect { _ = try Data.unbox("2o8&@O87n3n98N", decoder: _decoder) }.to(throwError())
                            }
                        }
                    }
                    context("NSDataWithStrategy") {
                        context("deferredToData") {
                            let _decoder = mockDecoder(dataStrategy: .deferredToData)
                            it("Decodes'Oh, Hi Mark!'") {
                                let data = ["79", "104", "44", "32", "72", "105", "32", "77", "97", "114", "107", "33"]
                                expect { _ = try NSData.unbox(data, decoder: _decoder) }.toNot(throwError())
                                    if let value = try? NSData.unbox(data, decoder: _decoder), let stringValue = String(data: value as Data, encoding: .utf8) {
                                    expect(stringValue) == "Oh, Hi Mark!"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
