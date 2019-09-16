//
//  XMLDecodableDateTests.swift
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

private func mockDecoder(dateStrategy: XMLDecoder.DateDecodingStrategy) -> _XMLDecoder {
    let localDecoder = decoder
    localDecoder.dateDecodingStrategy = dateStrategy
    return mockDecoder(options: decoder.options)
}

private func mockDecoder(options: XMLDecoder._Options) -> _XMLDecoder {
    _XMLDecoder(referencing: "", options: options)
}

private let mockOptions = XMLDecoder().options

class XMLDecodableDateTests: QuickSpec {
    
    override func spec() {
        describe("XMLDecodable") {
            describe("DecodesSingleValueCorrectly") {
                context("WhenItemIs") {
                    context("DateWithStrategy") {
                        context("defferedToDate(timeIntervalSinceReferenceDate)") {
                            let _decoder = mockDecoder(dateStrategy: .deferredToDate)
                            it("Decodes'590277534'") {
                                expect { _ = try Date.unbox("590277534", decoder: _decoder) }.toNot(throwError())
                                if let value = try? Date.unbox("590277534", decoder: _decoder) {
                                    expect(value) == Date(timeIntervalSinceReferenceDate: 590277534)
                                }
                            }
                        }
                        context("secondsSince1970") {
                            let _decoder = mockDecoder(dateStrategy: .secondsSince1970)
                            it("Decodes'590277534'") {
                                expect { _ = try Date.unbox("590277534", decoder: _decoder) }.toNot(throwError())
                                if let value = try? Date.unbox("590277534", decoder: _decoder) {
                                    expect(value) == Date(timeIntervalSince1970: 590277534)
                                }
                            }
                        }
                        context("secondsSince1970") {
                            let _decoder = mockDecoder(dateStrategy: .millisecondsSince1970)
                            it("Decodes'590277534'") {
                                expect { _ = try Date.unbox("590277534", decoder: _decoder) }.toNot(throwError())
                                if let value = try? Date.unbox("590277534", decoder: _decoder) {
                                    expect(value) == Date(timeIntervalSince1970: 590277.534)
                                }
                            }
                        }
                        if #available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                            context("iso8601") {
                                let _decoder = mockDecoder(dateStrategy: .iso8601)
                                
                                it("Decodes'2008-09-15T15:53:00+05:00'") {
                                    expect { _ = try Date.unbox("2008-09-15T15:53:00+05:00", decoder: _decoder) }.toNot(throwError())
                                    if let value = try? Date.unbox("2008-09-15T15:53:00+05:00", decoder: _decoder) {
                                        print(value.timeIntervalSince1970)
                                        expect(value) == Date(timeIntervalSince1970: 1221475980)
                                    }
                                }
                                it("FailsDecoding'123456'") {
                                    expect { _ = try Date.unbox("123456", decoder: _decoder) }.to(throwError())
                                }
                            }
                        }
                        context("formatted") {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "MM/dd/yy H:mm:ss zzz"
                            let _decoder = mockDecoder(dateStrategy: .formatted(formatter))
                            it("Decodes'06/10/11 15:24:16 +00:00'") {
                                expect { _ = try Date.unbox("06/10/11 15:24:16 +00:00", decoder: _decoder) }.toNot(throwError())
                                if let value = try? Date.unbox("06/10/11 15:24:16 +00:00", decoder: _decoder) {
                                    expect(value) == formatter.date(from: "06/10/11 15:24:16 +00:00")
                                }
                            }
                            it("FailsDecoding'590277534'") {
                                expect { _ = try Date.unbox("590277534", decoder: _decoder) }.to(throwError())
                            }
                        }
                        context("custom") {
                            let customDecoder = { (decoder: Decoder) throws -> Date in
                                try Date(from: decoder)
                            }
                            let _decoder = mockDecoder(dateStrategy: .custom(customDecoder))
                            it("Decodes'590277534'") {
                                expect { _ = try Date.unbox("590277534", decoder: _decoder) }.toNot(throwError())
                                if let value = try? Date.unbox("590277534", decoder: _decoder) {
                                    expect(value) == Date(timeIntervalSinceReferenceDate: 590277534)
                                }
                            }
                        }
                    }
                    context("NSDateWithStrategy") {
                        context("defferedToDate(timeIntervalSinceReferenceDate)") {
                            let _decoder = mockDecoder(dateStrategy: .deferredToDate)
                            it("Decodes'590277534'") {
                                expect { _ = try NSDate.unbox("590277534", decoder: _decoder) }.toNot(throwError())
                                if let value = try? NSDate.unbox("590277534", decoder: _decoder) {
                                    expect(value) == NSDate(timeIntervalSinceReferenceDate: 590277534)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
