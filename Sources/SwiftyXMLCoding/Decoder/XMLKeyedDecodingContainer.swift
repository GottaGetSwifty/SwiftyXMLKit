//
//  XMLKeyedDecodingContainer.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/21/17.
//  Largely re-written by PJ Fechner 09/2019
//  Copyright © 2019 PJ Fechner. All rights reserved.
//

import Foundation

// MARK: Decoding Containers

internal struct _XMLKeyedDecodingContainer<K : CodingKey> : KeyedDecodingContainerProtocol {
    typealias Key = K
    
    // MARK: Properties
    
    /// A reference to the decoder we're reading from.
    private let decoder: _XMLDecoder
    
    /// A reference to the container we're reading from.
    private let container: [String : Any]
    
    /// The path of coding keys taken to get to this point in decoding.
    private(set) public var codingPath: [CodingKey]
    
    // MARK: - Initialization
    
    /// Initializes `self` by referencing the given decoder and container.
    internal init(referencing decoder: _XMLDecoder, wrapping container: [String : Any]) {
        self.decoder = decoder
        switch decoder.options.keyDecodingStrategy {
        case .useDefaultKeys:
            self.container = container
        case .convertFromSnakeCase:
            // Convert the snake case keys in the container to camel case.
            // If we hit a duplicate key after conversion, then we'll use the first one we saw. Effectively an undefined behavior with dictionaries.
            self.container = Dictionary(container.map {
                key, value in (XMLDecoder.KeyDecodingStrategy._convertFromSnakeCase(key), value)
            }, uniquingKeysWith: { (first, _) in first })
        case .custom(let converter):
            self.container = Dictionary(container.map {
                key, value in (converter(decoder.codingPath + [_XMLKey(stringValue: key, intValue: nil)]).stringValue, value)
            }, uniquingKeysWith: { (first, _) in first })
        }
        self.codingPath = decoder.codingPath
    }
    
    // MARK: - KeyedDecodingContainerProtocol Methods
    
    public var allKeys: [Key] {
        return self.container.keys.compactMap { Key(stringValue: $0) }
    }
    
    public func contains(_ key: Key) -> Bool {
        return self.container[key.stringValue] != nil
    }
    
    private func _errorDescription(of key: CodingKey) -> String {
        switch decoder.options.keyDecodingStrategy {
        case .convertFromSnakeCase:
            // In this case we can attempt to recover the original value by reversing the transform
            let original = key.stringValue
            let converted = XMLEncoder.KeyEncodingStrategy._convertToSnakeCase(original)
            if converted == original {
                return "\(key) (\"\(original)\")"
            } else {
                return "\(key) (\"\(original)\"), converted to \(converted)"
            }
        default:
            // Otherwise, just report the converted string
            return "\(key) (\"\(key.stringValue)\")"
        }
    }
    
    private func _decode<T: Decodable>(forKey key: Key) throws -> T {
        guard let entry = container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }
        
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        let value: T = try decoder.unbox(entry)
        
        return value
    }
    
    public func decodeNil(forKey key: Key) throws -> Bool {
        if let entry = self.container[key.stringValue] {
            return entry is NSNull
        } else {
            return true
        }
    }
    
    public func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool { try _decode(forKey: key) }
    public func decode(_ type: Int.Type, forKey key: Key) throws -> Int { try _decode(forKey: key) }
    public func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 { try _decode(forKey: key) }
    public func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 { try _decode(forKey: key) }
    public func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 { try _decode(forKey: key) }
    public func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 { try _decode(forKey: key) }
    public func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt { try _decode(forKey: key) }
    public func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 { try _decode(forKey: key) }
    public func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 { try _decode(forKey: key) }
    public func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 { try _decode(forKey: key) }
    public func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 { try _decode(forKey: key) }
    public func decode(_ type: Float.Type, forKey key: Key) throws -> Float { try _decode(forKey: key) }
    public func decode(_ type: Double.Type, forKey key: Key) throws -> Double { try _decode(forKey: key) }
    public func decode(_ type: String.Type, forKey key: Key) throws -> String { try _decode(forKey: key) }
    public func decode<T : Decodable>(_ type: T.Type, forKey key: Key) throws -> T { try _decode(forKey: key) }
    
    public func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        
        guard let value = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key,
                                            DecodingError.Context(codingPath: self.codingPath,
                                                                  debugDescription: "Cannot get \(KeyedDecodingContainer<NestedKey>.self) -- no value found for key \"\(key.stringValue)\""))
        }
        
        guard let dictionary = value as? [String : Any] else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: [String : Any].self, reality: value)
        }
        
        let container = _XMLKeyedDecodingContainer<NestedKey>(referencing: self.decoder, wrapping: dictionary)
        return KeyedDecodingContainer(container)
    }
    
    public func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        
        guard let value = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key,
                                            DecodingError.Context(codingPath: self.codingPath,
                                                                  debugDescription: "Cannot get UnkeyedDecodingContainer -- no value found for key \"\(key.stringValue)\""))
        }
        
        guard let array = value as? [Any] else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: [Any].self, reality: value)
        }
        
        return _XMLUnkeyedDecodingContainer(referencing: decoder, wrapping: array)
    }
    
    private func _superDecoder(forKey key: CodingKey) throws -> Decoder {
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        
        let value: Any = self.container[key.stringValue] ?? NSNull()
        return _XMLDecoder(referencing: value, at: self.decoder.codingPath, options: self.decoder.options)
    }
    
    public func superDecoder() throws -> Decoder {
        return try _superDecoder(forKey: _XMLKey.super)
    }
    
    public func superDecoder(forKey key: Key) throws -> Decoder {
        return try _superDecoder(forKey: key)
    }
}
