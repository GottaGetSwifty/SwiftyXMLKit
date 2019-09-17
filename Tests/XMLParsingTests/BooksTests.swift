//
//  BooksTests.swift
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

class BooksTests: QuickSpec {
    
    let encoder: XMLEncoder = {
        let encoder = XMLEncoder()
        encoder.dateEncodingStrategy = .formatted(formatter)
        return encoder
    }()
    let decoder: XMLDecoder = {
        let decoder = XMLDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }()
    
    func compareCatalog(_ expected: Catalog, _ result: Catalog) {
        expect(expected.books.count) == result.books.count
        expected.books.enumerated().map{($0.element, result.books[$0.offset])}.forEach(compareBooks)
    }
    
    func compareBooks(items: (expected: Book, result: Book)) {
        let left = items.expected
        let right = items.result
        expect(left.id) == right.id
        expect(left.author) == right.author
        expect(left.title) == right.title
        expect(left.genre) == right.genre
        expect(left.price) ≈ right.price
        expect(left.order) == right.order
        expect(left.publishDate) == right.publishDate
        expect(left.description) == right.description
    }
    
    override func spec() {
        describe("Books Parsing") {
            describe("Coding") {
                it("Encodes") {
                    let data = try! self.encoder.encode(catalogResult, withRootKey: "catalog", header: XMLHeader(version: 1.0))
                    let xmlString = String(data: data, encoding: .utf8)!
                    expect(xmlString).to(haveEqualLines(to: booksXML))
                }
                it("Decodes") {
                    let data = booksXML.data(using: .utf8)!
                    expect{_ = try self.decoder.decode(Catalog.self, from: data)}.toNot(throwError())
                    let catalog: Catalog? = try? self.decoder.decode(from: data)
                    expect(catalog).toNot(beNil())
                    if let realCatalog = catalog {
                        self.compareCatalog(realCatalog, catalogResult)
                    }
                }
            }
        }
    }
}

private let book101 = Book(id: "bk101", order: 1, author: "Gambardella, Matthew", title: "XML Developer's Guide", genre: .computer, price: 44.95, publishDate: formatter.date(from: "2000-10-01")!, description: "An in-depth look & analysis of creating applications with XML.")
private let book102 = Book(id: "bk102", order: 2, author: "Ralls, Kim", title: "Midnight Rain", genre: .fantasy, price: 5.95, publishDate: formatter.date(from: "2000-12-16")!, description: "A former architect battles corporate zombies, an evil sorceress, and her own childhood to become queen of the world.")

private let catalogResult = Catalog(books: [book101, book102])

private let booksXML = """
<?xml version="1.0"?>
<catalog>
    <book id="bk101">
        <author>Gambardella, Matthew</author>
        <description><![CDATA[An in-depth look & analysis of creating applications with XML.]]></description>
        <genre>Computer</genre>
        <order>1</order>
        <price>44.95</price>
        <publish_date>2000-10-01</publish_date>
        <title>XML Developer&apos;s Guide</title>
    </book>
    <book id="bk102">
        <author>Ralls, Kim</author>
        <description><![CDATA[A former architect battles corporate zombies, an evil sorceress, and her own childhood to become queen of the world.]]></description>
        <genre>Fantasy</genre>
        <order>2</order>
        <price>5.95</price>
        <publish_date>2000-12-16</publish_date>
        <title>Midnight Rain</title>
    </book>
</catalog>
"""
