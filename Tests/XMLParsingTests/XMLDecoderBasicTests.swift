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

class XMLDecoderBasicTests: QuickSpec {
    
    override func spec() {
        describe("XMLDecoder") {
            describe("DecodesSingleValueCorrectly") {
                context("WhenItemIs") {
                    describe("Bool") {
                        let _decoder = mockDecoder(options: mockOptions)
                        describe("WithText") {
                            it("Decodes'true'") {
                                expect { _ = try Bool.unbox("true", decoder: _decoder) }.toNot(throwError())
                                let value = try! Bool.unbox("true", decoder: _decoder)
                                expect(value) == true
                                
                            }
                            it("FailsDecoding'TRUE'") {
                                expect{ try Bool.unbox("TRUE", decoder: _decoder) }.to(throwError())
                            }
                            it("FailsDecoding'True'") {
                                expect{ try Bool.unbox("True", decoder: _decoder) }.to(throwError())
                            }
                            it("Decodes'false'") {
                                expect { _ = try Bool.unbox("false", decoder: _decoder) }.toNot(throwError())
                                let value = try! Bool.unbox("false", decoder: _decoder)
                                expect(value) == false
                            }
                            it("FailsDecoding'FALSE'") {
                                expect{ try Bool.unbox("FALSE", decoder: _decoder) }.to(throwError())
                            }
                            it("FailsDecoding'False'") {
                                expect{ try Bool.unbox("False", decoder: _decoder) }.to(throwError())
                            }
                        }
                        describe("WithNumber") {
                            it("Decodes'1'") {
                                expect { _ = try Bool.unbox("1", decoder: _decoder) }.toNot(throwError())
                                let value = try! Bool.unbox("1", decoder: _decoder)
                                expect(value) == true
                            }
                            it("Decodes'0'") {
                                expect { _ = try Bool.unbox("0", decoder: _decoder) }.toNot(throwError())
                                let value = try! Bool.unbox("0", decoder: _decoder)
                                expect(value) == false
                            }
                            
                            it("FailsDecoding'2'") {
                                expect{ try Bool.unbox("2", decoder: _decoder) }.to(throwError())
                            }
                            it("FailsDecoding'-1'") {
                                expect{ try Bool.unbox("-1", decoder: _decoder) }.to(throwError())
                            }
                        }
                    }
                    describe("String") {
                        let _decoder = mockDecoder(options: mockOptions)
                        it("Decodes`hi`") {
                            expect { _ = try String.unbox("hi", decoder: _decoder) }.toNot(throwError())
                            let value = try! String.unbox("hi", decoder: _decoder)
                            expect(value) == "hi"
                        }
                        it("Decodes``") {
                            expect { _ = try String.unbox("", decoder: _decoder) }.toNot(throwError())
                            let value = try! String.unbox("", decoder: _decoder)
                            expect(value) == ""
                        }
                    }
                    //TODO: Tests for (NS)Date. Maybe in own file?
                    //TODO: Tests For (NS)Data
                    //TODO: Tests For (NS)URL
                    //TODO: Test for XMLAttributeProperty
                }
            }
        }
    }
}
