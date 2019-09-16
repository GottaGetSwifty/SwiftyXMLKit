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

class XMLDecodableDecimalTests: QuickSpec {
    
    override func spec() {
        describe("XMLDecodable") {
            describe("DecodesSingleValueCorrectly") {
                context("WhenItemIs") {
                    describe("Float") {
                        context("DefaultDecoder") {
                            let _decoder = mockDecoder(options: mockOptions)
                            it("Decodes'24.24'") {
                                expect { _ = try Float.unbox("24.24", decoder: _decoder) }.toNot(throwError())
                                let value = try! Float.unbox("24.24", decoder: _decoder)
                                expect(value) ≈ 24.24
                            }
                            it("Decodes'-24.24'") {
                                expect { _ = try Float.unbox("-24.24", decoder: _decoder) }.toNot(throwError())
                                let value = try! Float.unbox("-24.24", decoder: _decoder)
                                expect(value) ≈ -24.24
                            }
                            it("FailsDecodingGreaterThanMax") {
                                expect { _ = try Float.unbox("1\(Float.greatestFiniteMagnitude)", decoder: _decoder) }.to(throwError())
                            }
                            it("FailsDecodingLessThanMin") {
                                expect { _ = try Float.unbox("-1\(Float.greatestFiniteMagnitude)", decoder: _decoder) }.to(throwError())
                            }
                        }
                        context("ConvertFromStringStrategy") {
                            let decoder = XMLDecoder()
                            decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "10", negativeInfinity: "-10", nan: "-1")
                            let _decoder = mockDecoder(options: decoder.options)
                            it("Decodes'24.24'") {
                                expect { _ = try Float.unbox("24.24", decoder: _decoder) }.toNot(throwError())
                                let value = try! Float.unbox("24.24", decoder: _decoder)
                                expect(value) ≈ 24.24
                            }
                            it("Decodes'-24.24'") {
                                expect { _ = try Float.unbox("-24.24", decoder: _decoder) }.toNot(throwError())
                                let value = try! Float.unbox("-24.24", decoder: _decoder)
                                expect(value) ≈ -24.24
                            }
                            it("Decodes'infinity'") {
                                expect { _ = try Float.unbox("10", decoder: _decoder) }.toNot(throwError())
                                let value = try! Float.unbox("10", decoder: _decoder)
                                expect(value) == Float.infinity
                            }
                            it("Decodes'-infinity'") {
                                expect { _ = try Float.unbox("-10", decoder: _decoder) }.toNot(throwError())
                                let value = try! Float.unbox("-10", decoder: _decoder)
                                expect(value) == -Float.infinity
                            }
                            it("Decodes'nan'") {
                                expect { _ = try Float.unbox("-1", decoder: _decoder) }.toNot(throwError())
                                let value = try! Float.unbox("-1", decoder: _decoder)
                                expect(value).to(be(Float.nan))
                            }
                            it("FailsDecodingGreaterThanMax") {
                                expect { _ = try Float.unbox("1\(Float.greatestFiniteMagnitude)", decoder: _decoder) }.to(throwError())
                            }
                            it("FailsDecodingLessThanMin") {
                                expect { _ = try Float.unbox("-1\(Float.greatestFiniteMagnitude)", decoder: _decoder) }.to(throwError())
                            }
                        }
                    }
                    describe("Double") {
                        context("DefaultDecoder") {
                            let _decoder = mockDecoder(options: mockOptions)
                            it("Decodes'24.24'") {
                                expect { _ = try Double.unbox("24.24", decoder: _decoder) }.toNot(throwError())
                                let value = try! Double.unbox("24.24", decoder: _decoder)
                                expect(value) ≈ 24.24
                            }
                            it("Decodes'-24.24'") {
                                expect { _ = try Double.unbox("-24.24", decoder: _decoder) }.toNot(throwError())
                                let value = try! Double.unbox("-24.24", decoder: _decoder)
                                expect(value) ≈ -24.24
                            }
                            it("FailsDecodingGreaterThanMax") {
                                expect { _ = try Double.unbox("1\(Double.greatestFiniteMagnitude)", decoder: _decoder) }.to(throwError())
                            }
                            it("FailsDecodingLessThanMin") {
                                expect { _ = try Double.unbox("-1\(Double.greatestFiniteMagnitude)", decoder: _decoder) }.to(throwError())
                            }
                        }
                        context("ConvertFromStringStrategy") {
                            let decoder = XMLDecoder()
                            decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "10", negativeInfinity: "-10", nan: "-1")
                            let _decoder = mockDecoder(options: decoder.options)
                            it("Decodes'24.24'") {
                                expect { _ = try Double.unbox("24.24", decoder: _decoder) }.toNot(throwError())
                                let value = try! Double.unbox("24.24", decoder: _decoder)
                                expect(value) ≈ 24.24
                            }
                            it("Decodes'-24.24'") {
                                expect { _ = try Double.unbox("-24.24", decoder: _decoder) }.toNot(throwError())
                                let value = try! Double.unbox("-24.24", decoder: _decoder)
                                expect(value) ≈ -24.24
                            }
                            it("Decodes'infinity'") {
                                expect { _ = try Double.unbox("10", decoder: _decoder) }.toNot(throwError())
                                let value = try! Double.unbox("10", decoder: _decoder)
                                expect(value) == Double.infinity
                            }
                            it("Decodes'-infinity'") {
                                expect { _ = try Double.unbox("-10", decoder: _decoder) }.toNot(throwError())
                                let value = try! Double.unbox("-10", decoder: _decoder)
                                expect(value) == -Double.infinity
                            }
                            it("Decodes'nan'") {
                                expect { _ = try Double.unbox("-1", decoder: _decoder) }.toNot(throwError())
                                let value = try! Double.unbox("-1", decoder: _decoder)
                                expect(value).to(be(Double.nan))
                            }
                            it("FailsDecodingGreaterThanMax") {
                                expect { _ = try Double.unbox("1\(Double.greatestFiniteMagnitude)", decoder: _decoder) }.to(throwError())
                            }
                            it("FailsDecodingLessThanMin") {
                                expect { _ = try Double.unbox("-1\(Double.greatestFiniteMagnitude)", decoder: _decoder) }.to(throwError())
                            }
                        }
                        describe("Decimal") {
                            context("DefaultDecoder") {
                                let _decoder = mockDecoder(options: mockOptions)
                                it("Decodes'24.24'") {
                                    expect { _ = try Decimal.unbox("24.24", decoder: _decoder) }.toNot(throwError())
                                    let value = try! Decimal.unbox("24.24", decoder: _decoder)
                                    expect(Double(truncating: value as NSNumber)) ≈ Double(truncating: Decimal(24.24) as NSNumber)
                                }
                                it("Decodes'-24.24'") {
                                    expect { _ = try Decimal.unbox("-24.24", decoder: _decoder) }.toNot(throwError())
                                    let value = try! Decimal.unbox("-24.24", decoder: _decoder)
                                    expect(Double(truncating: value as NSNumber)) ≈ Double(truncating: Decimal(-24.24) as NSNumber)
                                }
                                it("FailsDecodingGreaterThanMax") {
                                    expect { _ = try Decimal.unbox("1\(Double.greatestFiniteMagnitude)", decoder: _decoder) }.to(throwError())
                                }
                                it("FailsDecodingLessThanMin") {
                                    expect { _ = try Decimal.unbox("-1\(Double.greatestFiniteMagnitude)", decoder: _decoder) }.to(throwError())
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
