//
//  XMLDecodableBasicTests.swift
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
private func mockDecoder(options: XMLDecoder._Options) -> _XMLDecoder {
    _XMLDecoder(referencing: "", options: options)
}

private let mockOptions = XMLDecoder().options

class XMLDecodableBasicTests: QuickSpec {
    
    override func spec() {
        describe("XMLDecodable") {
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
                        it("Decodes'hi'") {
                            expect { _ = try String.unbox("hi", decoder: _decoder) }.toNot(throwError())
                            let value = try! String.unbox("hi", decoder: _decoder)
                            expect(value) == "hi"
                        }
                        it("Decodes''") {
                            expect { _ = try String.unbox("", decoder: _decoder) }.toNot(throwError())
                            let value = try! String.unbox("", decoder: _decoder)
                            expect(value) == ""
                        }
                    }
                    describe("URL") {
                        let _decoder = mockDecoder(options: mockOptions)
                        it("Decodes'https://duckduckgo.com'") {
                            expect { _ = try URL.unbox("https://duckduckgo.com", decoder: _decoder)}.toNot(throwError())
                            if let value = try? URL.unbox("https://duckduckgo.com", decoder: _decoder) {
                                expect(value) == URL(string: "https://duckduckgo.com")
                            }
                        }
                        it("FailsDecoding'Oh Hi Mark!'") {
                            expect { _ = try URL.unbox("Oh Hi Mark!", decoder: _decoder)}.to(throwError())
                        }
                    }
                    describe("NSURL") {
                        let _decoder = mockDecoder(options: mockOptions)
                        it("Decodes'https://duckduckgo.com'") {
                            expect { _ = try NSURL.unbox("https://duckduckgo.com", decoder: _decoder)}.toNot(throwError())
                            if let value = try? NSURL.unbox("https://duckduckgo.com", decoder: _decoder) {
                                expect(value) == NSURL(string: "https://duckduckgo.com")
                            }
                        }
                        it("FailsDecoding'Oh Hi Mark!'") {
                            expect { _ = try NSURL.unbox("Oh Hi Mark!", decoder: _decoder)}.to(throwError())
                        }
                    }
                    describe("XMLAttributedProperty<Int>") {
                        let _decoder = mockDecoder(options: mockOptions)
                        it("Decodes'5'") {
                            expect { _ = try XMLAttributeProperty<Int>.unbox("5", decoder: _decoder)}.toNot(throwError())
                            if let value = try? XMLAttributeProperty<Int>.unbox("5", decoder: _decoder) {
                                expect(value.wrappedValue) == 5
                            }
                        }
                        it("FailsDecoding'Oh Hi Mark!'") {
                            expect { _ = try NSURL.unbox("Oh Hi Mark!", decoder: _decoder)}.to(throwError())
                        }
                    }
                }
            }
        }
    }
}
