//
//  XMLUnkeyedDecodingContainer.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/21/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

internal struct _XMLUnkeyedDecodingContainer : UnkeyedDecodingContainer {
    // MARK: Properties
    
    /// A reference to the decoder we're reading from.
    private let decoder: _XMLDecoder
    
    /// A reference to the container we're reading from.
    private let container: [Any]
    
    /// The path of coding keys taken to get to this point in decoding.
    private(set) public var codingPath: [CodingKey]
    
    /// The index of the element we're about to decode.
    private(set) public var currentIndex: Int
    
    // MARK: - Initialization
    
    /// Initializes `self` by referencing the given decoder and container.
    internal init(referencing decoder: _XMLDecoder, wrapping container: [Any]) {
        self.decoder = decoder
        self.container = container
        self.codingPath = decoder.codingPath
        self.currentIndex = 0
    }
    
    // MARK: - UnkeyedDecodingContainer Methods
    
    public var count: Int? {
        return self.container.count
    }
    
    public var isAtEnd: Bool {
        return self.currentIndex >= self.count!
    }
    
    public mutating func decodeNil() throws -> Bool {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }
        
        if self.container[self.currentIndex] is NSNull {
            self.currentIndex += 1
            return true
        } else {
            return false
        }
    }
    
    /// - Parameter runWhenFinished: Used to allow mutating things to be passed in
    private func _decode<T>(_ getValue: (Any) throws -> T?, runWhenFinished: () -> ()) throws -> T {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(T.self, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }
        
        self.decoder.codingPath.append(_XMLKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }
        let value = self.container[self.currentIndex]
        guard let decoded: T = try getValue(value) else {
            throw DecodingError.valueNotFound(T.self, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Expected \(T.self) but found null instead."))
        }
        
        return decoded
    }
    
    public mutating func decode(_ type: Bool.Type) throws -> Bool {
        try self._decode({ try self.decoder.unbox($0) }) { self.currentIndex += 1 }
    }
    
    public mutating func decode(_ type: Int.Type) throws -> Int {
        try self._decode({ try self.decoder.unbox($0) }) { self.currentIndex += 1 }
    }
    
    public mutating func decode(_ type: Int8.Type) throws -> Int8 {
        try self._decode({ try self.decoder.unbox($0) }) { self.currentIndex += 1 }
    }
    
    public mutating func decode(_ type: Int16.Type) throws -> Int16 {
        try self._decode({ try self.decoder.unbox($0) }) { self.currentIndex += 1 }
    }
    
    public mutating func decode(_ type: Int32.Type) throws -> Int32 {
        try self._decode({ try self.decoder.unbox($0) }) { self.currentIndex += 1 }
    }
    
    public mutating func decode(_ type: Int64.Type) throws -> Int64 {
        try self._decode({ try self.decoder.unbox($0) }) { self.currentIndex += 1 }
    }
    
    public mutating func decode(_ type: UInt.Type) throws -> UInt {
        try self._decode({ try self.decoder.unbox($0) }) { self.currentIndex += 1 }
    }
    
    public mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        try self._decode({ try self.decoder.unbox($0) }) { self.currentIndex += 1 }
    }
    
    public mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        try self._decode({ try self.decoder.unbox($0) }) { self.currentIndex += 1 }
    }
    
    public mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        try self._decode({ try self.decoder.unbox($0) }) { self.currentIndex += 1 }
    }
    
    public mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        try self._decode({ try self.decoder.unbox($0) }) { self.currentIndex += 1 }
    }
    
    public mutating func decode(_ type: Float.Type) throws -> Float {
        try self._decode({ try self.decoder.unbox($0) }) { self.currentIndex += 1 }
    }
    
    public mutating func decode(_ type: Double.Type) throws -> Double {
        try self._decode({ try self.decoder.unbox($0) }) { self.currentIndex += 1 }
    }
    
    public mutating func decode(_ type: String.Type) throws -> String {
        try self._decode({ try self.decoder.unbox($0) }) { self.currentIndex += 1 }
    }
    
    public mutating func decode<T : Decodable>(_ type: T.Type) throws -> T {
        try self._decode({ try self.decoder._unbox($0) }) { self.currentIndex += 1 }
    }
    
    public mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
        self.decoder.codingPath.append(_XMLKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }
        
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."))
        }
        
        let value = self.container[self.currentIndex]
        guard !(value is NSNull) else {
            throw DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get keyed decoding container -- found null value instead."))
        }
        
        guard let dictionary = value as? [String : Any] else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: [String : Any].self, reality: value)
        }
        
        self.currentIndex += 1
        let container = _XMLKeyedDecodingContainer<NestedKey>(referencing: self.decoder, wrapping: dictionary)
        return KeyedDecodingContainer(container)
    }
    
    public mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        self.decoder.codingPath.append(_XMLKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }
        
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."))
        }
        
        let value = self.container[self.currentIndex]
        guard !(value is NSNull) else {
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get keyed decoding container -- found null value instead."))
        }
        
        guard let array = value as? [Any] else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: [Any].self, reality: value)
        }
        
        self.currentIndex += 1
        return _XMLUnkeyedDecodingContainer(referencing: self.decoder, wrapping: array)
    }
    
    public mutating func superDecoder() throws -> Decoder {
        self.decoder.codingPath.append(_XMLKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }
        
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(Decoder.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get superDecoder() -- unkeyed container is at end."))
        }
        
        let value = self.container[self.currentIndex]
        self.currentIndex += 1
        return _XMLDecoder(referencing: value, at: self.decoder.codingPath, options: self.decoder.options)
    }
}
