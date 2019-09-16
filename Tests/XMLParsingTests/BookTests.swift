//
//  BookTests.swift
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

class BookTests: QuickSpec {
    
    let encoder: XMLEncoder = {
        let encoder = XMLEncoder()
        encoder.dateEncodingStrategy = .formatted(formatter)
        encoder.stringEncodingStrategy = .deferredToString
        return encoder
    }()
    let decoder: XMLDecoder = {
        let decoder = XMLDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }()
    
    func compareBooks(_ left: Book, _ right: Book) {
        expect(left.id) == right.id
        expect(left.author) == right.author
        expect(left.title) == right.title
        expect(left.order) == right.order
        expect(left.genre) == right.genre
        expect(left.price) ≈ right.price
        expect(left.publishDate) == right.publishDate
        expect(left.description) == right.description
    }
    
    override func spec() {
        describe("Book Parsing") {
            describe("Coding") {
                it("Encodes") {
                    let data = try! self.encoder.encode(bookResult, withRootKey: "book", header: XMLHeader(version: 1.0))
                    let xmlString = String(data: data, encoding: .utf8)!
                    expect(xmlString).to(haveEqualLines(to: bookXML))
                }
                it("Decodes") {
                    let data = bookXML.data(using: .utf8)!
                    let book = try! self.decoder.decode(Book.self, from: data)
                    self.compareBooks(book, bookResult)

                }
            }
        }
    }
}

private let bookResult = Book(id: "bk101", order: 1, author: "Gambardella, Matthew", title: "XML Developer's Guide", genre: .computer, price: 44.95, publishDate: formatter.date(from: "2000-10-01")!, description: "An in-depth look at creating applications with XML.")
private let bookXML = """
<?xml version="1.0"?>
<book id="bk101">
    <author>Gambardella, Matthew</author>
    <description>An in-depth look at creating applications with XML.</description>
    <genre>Computer</genre>
    <order>1</order>
    <price>44.95</price>
    <publish_date>2000-10-01</publish_date>
    <title>XML Developer&apos;s Guide</title>
</book>
"""
