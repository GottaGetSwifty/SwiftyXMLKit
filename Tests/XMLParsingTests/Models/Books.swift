//
//  Books.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/15/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation
import SwiftyXMLCoding

struct Catalog: Codable {
    var books: [Book]
    
    enum CodingKeys: String, CodingKey {
        case books = "book"
    }
}

struct BookDateCoder: CustomDateFormatterCoder {
    static var dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
    }()
    
}

struct Book: Codable, Equatable {
    @XMLAttributeProperty
    var id: String
    let order: Int
    let author: String
    let title: String
    let genre: Genre
    let price: Double
    @CustomCoding<DateCoders.Custom<BookDateCoder>>
    var publishDate: Date
    
    @CustomCoding<XMLCDataCoder>
    var description: String
    
    enum CodingKeys: String, CodingKey {
        case id, order, author, title, genre, price, description
        case publishDate = "publish_date"
    }
}

enum Genre: String, Codable {
    case computer = "Computer"
    case fantasy = "Fantasy"
    case romance = "Romance"
    case horror = "Horror"
    case sciFi = "Science Fiction"
}
