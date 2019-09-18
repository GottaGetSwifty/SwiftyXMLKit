//
//  XMLAttributePropertyIntegrationTests.swift
//  
//
//  Created by PJ Fechner on 9/5/19.
//  Copyright © 2019 PJ Fechner. All rights reserved.
//

@testable import SwiftyXMLCoding
import Foundation
import Quick
import Nimble

private let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()

class XMLAttributePropertyIntegrationTests: QuickSpec {

    let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
//        encoder.dateEncodingStrategy = .formatted(formatter)
        return encoder
    }()
    let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }()
    
    override func spec() {
        describe("XMLAttributeProperty") {
            describe("WorksWithJSON") {
                
                it("encodes") {
                    expect{ _ = try self.encoder.encode(bookResult)}.toNot(throwError())
                    let data = try? self.encoder.encode(bookResult)
                    expect(data).toNot(beNil())
                    expect(data.map { String(data: $0, encoding: .utf8)}).toNot(beNil())
                    if let jsonData = data, let json = String(data: jsonData, encoding: .utf8) {
                        expect(json).to(haveEqualLines(to: bookJSON))
                    }
                }
                it("decodes") {
                    let data = bookJSON.data(using: .utf8)!
                    expect{ _ = try self.decoder.decode(Book.self, from: data)}.toNot(throwError())
                    if let book = try? self.decoder.decode(Book.self, from: data) {
                        expect(book) == bookResult
                    }
                }
            }
        }
    }
}

private let bookResult = Book(id: "bk101", order: 1, author: "Gambardella, Matthew", title: "XML Developer's Guide", genre: .computer, price: 44.95, publishDate: formatter.date(from: "2000-10-01")!, description: "An in-depth look at creating applications with XML.")
private let bookJSON = """
{"author":"Gambardella, Matthew","id":"bk101","order":1,"title":"XML Developer's Guide","price":44.950000000000003,"publish_date":"2000-10-01","description":"An in-depth look at creating applications with XML.","genre":"Computer"}
"""
