//
//  XMLKey.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/21/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

protocol AnyXMLAttributeProperty {
}

@propertyWrapper
public struct XMLAttributeProperty<T: Codable>: Codable, AnyXMLAttributeProperty {
    public var wrappedValue: T
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        let value = try T(from: decoder)
        self.init(wrappedValue: value)
    }
    
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}
extension XMLAttributeProperty: Equatable where T: Equatable { }

@propertyWrapper
public struct XMLCDataProperty: Codable, Equatable {
    public var wrappedValue: String
    public init(wrappedValue: String) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        let value = try String(from: decoder)
        self.init(wrappedValue: value)
    }
    
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}

//===----------------------------------------------------------------------===//
// Shared Key Types
//===----------------------------------------------------------------------===//

internal struct _XMLKey : CodingKey {
    public var stringValue: String
    public var intValue: Int?

    public init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    public init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
    
    public init(stringValue: String, intValue: Int?) {
        self.stringValue = stringValue
        self.intValue = intValue
    }

    internal init(index: Int) {
        self.stringValue = "Index \(index)"
        self.intValue = index
    }

    internal static let `super` = _XMLKey(stringValue: "super")!
}


