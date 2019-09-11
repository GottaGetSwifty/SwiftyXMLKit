//
//  XMLDecoder.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/20/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation
import SWXMLHash
//===----------------------------------------------------------------------===//
// XML Decoder
//===----------------------------------------------------------------------===//

/// `XMLDecoder` facilitates the decoding of XML into semantic `Decodable` types.
open class XMLDecoder {
    // MARK: Options
    /// The strategy to use for decoding `Date` values.
    public enum DateDecodingStrategy {
        /// Defer to `Date` for decoding. This is the default strategy.
        case deferredToDate
        
        /// Decode the `Date` as a UNIX timestamp from a XML number. This is the default strategy.
        case secondsSince1970
        
        /// Decode the `Date` as UNIX millisecond timestamp from a XML number.
        case millisecondsSince1970
        
        /// Decode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
        @available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
        case iso8601
        
        /// Decode the `Date` as a string parsed by the given formatter.
        case formatted(DateFormatter)
        
        /// Decode the `Date` as a custom value decoded by the given closure.
        case custom((_ decoder: Decoder) throws -> Date)
        
        /// Decode the `Date` as a string parsed by the given formatter for the give key.
        static func keyFormatted(_ formatterForKey: @escaping (CodingKey) throws -> DateFormatter?) -> XMLDecoder.DateDecodingStrategy {
            return .custom({ (decoder) -> Date in
                guard let codingKey = decoder.codingPath.last else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No Coding Path Found"))
                }
                
                guard let container = try? decoder.singleValueContainer(),
                    let text = try? container.decode(String.self) else {
                        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not decode date text"))
                }
                
                guard let dateFormatter = try formatterForKey(codingKey) else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "No date formatter for date text")
                }
                
                if let date = dateFormatter.date(from: text) {
                    return date
                } else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(text)")
                }
            })
        }
    }
    
    /// The strategy to use for decoding `Data` values.
    public enum DataDecodingStrategy {
        /// Defer to `Data` for decoding.
        case deferredToData
        
        /// Decode the `Data` from a Base64-encoded string. This is the default strategy.
        case base64
        
        /// Decode the `Data` as a custom value decoded by the given closure.
        case custom((_ decoder: Decoder) throws -> Data)
        
        /// Decode the `Data` as a custom value by the given closure for the give key.
        static func keyFormatted(_ formatterForKey: @escaping (CodingKey) throws -> Data?) -> XMLDecoder.DataDecodingStrategy {
            return .custom({ (decoder) -> Data in
                guard let codingKey = decoder.codingPath.last else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No Coding Path Found"))
                }
                
                guard let container = try? decoder.singleValueContainer(),
                    let text = try? container.decode(String.self) else {
                        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not decode date text"))
                }
                
                guard let data = try formatterForKey(codingKey) else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode data string \(text)")
                }
                
                return data
            })
        }
    }
    
    /// The strategy to use for non-XML-conforming floating-point values (IEEE 754 infinity and NaN).
    public enum NonConformingFloatDecodingStrategy {
        /// Throw upon encountering non-conforming values. This is the default strategy.
        case `throw`
        
        /// Decode the values from the given representation strings.
        case convertFromString(positiveInfinity: String, negativeInfinity: String, nan: String)
    }
    
    /// The strategy to use for automatically changing the value of keys before decoding.
    public enum KeyDecodingStrategy {
        /// Use the keys specified by each type. This is the default strategy.
        case useDefaultKeys
        
        /// Convert from "snake_case_keys" to "camelCaseKeys" before attempting to match a key with the one specified by each type.
        ///
        /// The conversion to upper case uses `Locale.system`, also known as the ICU "root" locale. This means the result is consistent regardless of the current user's locale and language preferences.
        ///
        /// Converting from snake case to camel case:
        /// 1. Capitalizes the word starting after each `_`
        /// 2. Removes all `_`
        /// 3. Preserves starting and ending `_` (as these are often used to indicate private variables or other metadata).
        /// For example, `one_two_three` becomes `oneTwoThree`. `_one_two_three_` becomes `_oneTwoThree_`.
        ///
        /// - Note: Using a key decoding strategy has a nominal performance cost, as each string key has to be inspected for the `_` character.
        case convertFromSnakeCase
        
        /// Provide a custom conversion from the key in the encoded JSON to the keys specified by the decoded types.
        /// The full path to the current decoding position is provided for context (in case you need to locate this key within the payload). The returned key is used in place of the last component in the coding path before decoding.
        /// If the result of the conversion is a duplicate key, then only one value will be present in the container for the type to decode from.
        case custom((_ codingPath: [CodingKey]) -> CodingKey)
        
        internal static func _convertFromSnakeCase(_ stringKey: String) -> String {
            guard !stringKey.isEmpty else { return stringKey }
            
            // Find the first non-underscore character
            guard let firstNonUnderscore = stringKey.index(where: { $0 != "_" }) else {
                // Reached the end without finding an _
                return stringKey
            }
            
            // Find the last non-underscore character
            var lastNonUnderscore = stringKey.index(before: stringKey.endIndex)
            while lastNonUnderscore > firstNonUnderscore && stringKey[lastNonUnderscore] == "_" {
                stringKey.formIndex(before: &lastNonUnderscore)
            }
            
            let keyRange = firstNonUnderscore...lastNonUnderscore
            let leadingUnderscoreRange = stringKey.startIndex..<firstNonUnderscore
            let trailingUnderscoreRange = stringKey.index(after: lastNonUnderscore)..<stringKey.endIndex
            
            let components = stringKey[keyRange].split(separator: "_")
            let joinedString : String
            if components.count == 1 {
                // No underscores in key, leave the word as is - maybe already camel cased
                joinedString = String(stringKey[keyRange])
            } else {
                joinedString = ([components[0].lowercased()] + components[1...].map { $0.capitalized }).joined()
            }
            
            // Do a cheap isEmpty check before creating and appending potentially empty strings
            let result : String
            if (leadingUnderscoreRange.isEmpty && trailingUnderscoreRange.isEmpty) {
                result = joinedString
            } else if (!leadingUnderscoreRange.isEmpty && !trailingUnderscoreRange.isEmpty) {
                // Both leading and trailing underscores
                result = String(stringKey[leadingUnderscoreRange]) + joinedString + String(stringKey[trailingUnderscoreRange])
            } else if (!leadingUnderscoreRange.isEmpty) {
                // Just leading
                result = String(stringKey[leadingUnderscoreRange]) + joinedString
            } else {
                // Just trailing
                result = joinedString + String(stringKey[trailingUnderscoreRange])
            }
            return result
        }
    }
    
    /// The strategy to use in decoding dates. Defaults to `.secondsSince1970`.
    open var dateDecodingStrategy: DateDecodingStrategy = .secondsSince1970
    
    /// The strategy to use in decoding binary data. Defaults to `.base64`.
    open var dataDecodingStrategy: DataDecodingStrategy = .base64
    
    /// The strategy to use in decoding non-conforming numbers. Defaults to `.throw`.
    open var nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy = .throw
    
    /// The strategy to use for decoding keys. Defaults to `.useDefaultKeys`.
    open var keyDecodingStrategy: KeyDecodingStrategy = .useDefaultKeys
    
    /// Contextual user-provided information for use during decoding.
    open var userInfo: [CodingUserInfoKey : Any] = [:]
    
    /// Options set on the top-level encoder to pass down the decoding hierarchy.
    internal struct _Options {
        let dateDecodingStrategy: DateDecodingStrategy
        let dataDecodingStrategy: DataDecodingStrategy
        let nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy
        let keyDecodingStrategy: KeyDecodingStrategy
        let userInfo: [CodingUserInfoKey : Any]
    }
    
    /// The options set on the top-level decoder.
    internal var options: _Options {
        return _Options(dateDecodingStrategy: dateDecodingStrategy,
                        dataDecodingStrategy: dataDecodingStrategy,
                        nonConformingFloatDecodingStrategy: nonConformingFloatDecodingStrategy,
                        keyDecodingStrategy: keyDecodingStrategy,
                        userInfo: userInfo)
    }
    
    // MARK: - Constructing a XML Decoder
    /// Initializes `self` with default strategies.
    public init() {}
    
    // MARK: - Decoding Values
    /// Decodes a top-level value of the given type from the given XML representation.
    ///
    /// - parameter type: The type of the value to decode.
    /// - parameter data: The data to decode from.
    /// - returns: A value of the requested type.
    /// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid XML.
    /// - throws: An error if any value throws an error during decoding.
    open func decode<T : Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let topLevel: [String: Any]
        do {
            topLevel = try _XMLStackParser.parse(with: data)
        } catch {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid XML.", underlyingError: error))
        }
        
        let decoder = _XMLDecoder(referencing: topLevel, options: self.options)
        
        guard let value: T = try decoder._unbox(topLevel) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: [], debugDescription: "The given data did not contain a top-level value."))
        }
        
        return value
    }
    
    // MARK: - Decoding Values
    /// Decodes a top-level value of the given type from the given XML representation.
    ///
    /// - parameter type: The type of the value to decode.
    /// - parameter data: The data to decode from.
    /// - returns: A value of the requested type.
    /// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid XML.
    /// - throws: An error if any value throws an error during decoding.
    open func decodeNew<T : Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let parser = _XMLParser(data: data)
        
        let xml = parser.indexer.children[0]
//        print(xml)
        
        let topLevel: [String: Any]
        do {
            topLevel = try _XMLStackParser.parse(with: data)
        } catch {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid XML.", underlyingError: error))
        }
        
        let decoder = _XMLDecoder(referencing: topLevel, options: self.options)
        
        guard let value: T = try decoder._unbox(topLevel) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: [], debugDescription: "The given data did not contain a top-level value."))
        }
        
        return value
    }
}

// MARK: - _XMLDecoder

internal class _XMLDecoder : Decoder {
    // MARK: Properties
    
    /// The decoder's storage.
    internal var storage: _XMLDecodingStorage
    
    /// Options set on the top-level decoder.
    internal let options: XMLDecoder._Options
    
    /// The path to the current point in encoding.
    internal(set) public var codingPath: [CodingKey]
    
    /// Contextual user-provided information for use during encoding.
    public var userInfo: [CodingUserInfoKey : Any] {
        return self.options.userInfo
    }
    
    // MARK: - Initialization
    
    /// Initializes `self` with the given top-level container and options.
    internal init(referencing container: Any, at codingPath: [CodingKey] = [], options: XMLDecoder._Options) {
        self.storage = _XMLDecodingStorage()
        self.storage.push(container: container)
        self.codingPath = codingPath
        self.options = options
    }
    
    // MARK: - Decoder Methods
    
    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        guard !(self.storage.topContainer is NSNull) else {
            throw DecodingError.valueNotFound(KeyedDecodingContainer<Key>.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get keyed decoding container -- found null value instead."))
        }
        
        guard let topContainer = self.storage.topContainer as? [String : Any] else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: [String : Any].self, reality: self.storage.topContainer)
        }
        
        let container = _XMLKeyedDecodingContainer<Key>(referencing: self, wrapping: topContainer)
        return KeyedDecodingContainer(container)
    }
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard !(self.storage.topContainer is NSNull) else {
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get unkeyed decoding container -- found null value instead."))
        }
        
        let topContainer: [Any]
        
        if let container = self.storage.topContainer as? [Any] {
            topContainer = container
        } else if let container = self.storage.topContainer as? [AnyHashable: Any]  {
            topContainer = [container]
        } else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: [Any].self, reality: self.storage.topContainer)
        }
        
        return _XMLUnkeyedDecodingContainer(referencing: self, wrapping: topContainer)
    }
    
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        return self
    }
}

// MARK: SingleValueDecodingContainer
extension _XMLDecoder : SingleValueDecodingContainer {
    
    
    public func decodeNil() -> Bool {
        return self.storage.topContainer is NSNull
    }
    internal func _decode<T: XMLDecodable>() throws -> T {
        try self.unbox(self.storage.topContainer)
    }
    
    public func decode(_ type: Bool.Type) throws -> Bool { try _decode() }
    public func decode(_ type: Int.Type) throws -> Int { try _decode() }
    public func decode(_ type: Int8.Type) throws -> Int8 { try _decode() }
    public func decode(_ type: Int16.Type) throws -> Int16 { try _decode() }
    public func decode(_ type: Int32.Type) throws -> Int32 { try _decode() }
    public func decode(_ type: Int64.Type) throws -> Int64 { try _decode() }
    public func decode(_ type: UInt.Type) throws -> UInt { try _decode() }
    public func decode(_ type: UInt8.Type) throws -> UInt8 { try _decode() }
    public func decode(_ type: UInt16.Type) throws -> UInt16 { try _decode() }
    public func decode(_ type: UInt32.Type) throws -> UInt32 { try _decode() }
    public func decode(_ type: UInt64.Type) throws -> UInt64 { try _decode() }
    public func decode(_ type: Float.Type) throws -> Float { try _decode() }
    public func decode(_ type: Double.Type) throws -> Double { try _decode() }
    public func decode(_ type: String.Type) throws -> String { try _decode() }
    public func decode<T : Decodable>(_ type: T.Type) throws -> T { try self._unbox(self.storage.topContainer)! }
}

// MARK: - Concrete Value Representations

extension _XMLDecoder {
    
    private func expectNonNull<T>(_ type: T.Type) throws {
        guard !self.decodeNil() else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected \(type) but found null value instead."))
        }
    }
    
    internal func unbox<T: XMLDecodable>(_ value: Any) throws -> T {
        try expectNonNull(T.self)
        return try T.unbox(value, decoder: self)
    }
    
    internal func unbox<T: XMLDecodable>(_ value: Any, type: T.Type) throws -> T {
        return try unbox(value)
    }
    
    func unboxAttribute<T: XMLDecodable>(_ value: Any, type: T.Type) throws -> XMLAttributeProperty<T> {
        return XMLAttributeProperty<T>(wrappedValue: try unbox(value))
    }
    internal func _unbox<T : Decodable>(_ value: Any) throws -> T? {
        try expectNonNull(T.self)
        
        //checking whether it's already a property to avoid running the full switch everytime
        if T.self is AnyXMLAttributeProperty.Type {
            
            switch T.self {
            case is XMLAttributeProperty<Bool>.Type: return try unboxAttribute(value, type: Bool.self) as? T
            case is XMLAttributeProperty<Int>.Type: return try unboxAttribute(value, type: Int.self) as? T
            case is XMLAttributeProperty<Int8>.Type: return try unboxAttribute(value, type: Int8.self) as? T
            case is XMLAttributeProperty<Int16>.Type: return try unboxAttribute(value, type: Int16.self) as? T
            case is XMLAttributeProperty<Int32>.Type: return try unboxAttribute(value, type: Int32.self) as? T
            case is XMLAttributeProperty<Int64>.Type: return try unboxAttribute(value, type: Int64.self) as? T
            case is XMLAttributeProperty<UInt>.Type: return try unboxAttribute(value, type: UInt.self) as? T
            case is XMLAttributeProperty<UInt8>.Type: return try unboxAttribute(value, type: UInt8.self) as? T
            case is XMLAttributeProperty<UInt16>.Type: return try unboxAttribute(value, type: UInt16.self) as? T
            case is XMLAttributeProperty<UInt32>.Type: return try unboxAttribute(value, type: UInt32.self) as? T
            case is XMLAttributeProperty<UInt64>.Type: return try unboxAttribute(value, type: UInt64.self) as? T
            case is XMLAttributeProperty<Float>.Type: return try unboxAttribute(value, type: Float.self) as? T
            case is XMLAttributeProperty<Double>.Type: return try unboxAttribute(value, type: Double.self) as? T
            case is XMLAttributeProperty<String>.Type: return try unboxAttribute(value, type: String.self) as? T
            case is XMLAttributeProperty<Date>.Type: return try unboxAttribute(value, type: Date.self) as? T
            case is XMLAttributeProperty<Data>.Type: return try unboxAttribute(value, type: Data.self) as? T
            case is XMLAttributeProperty<URL>.Type: return try unboxAttribute(value, type: URL.self) as? T
            default: return nil
            }
        }
        
        switch T.self {
        case is Date.Type, is NSDate.Type: return try unbox(value, type: Date.self) as? T
        case is Data.Type, is NSData.Type: return try unbox(value, type: Data.self) as? T
        case is URL.Type, is NSURL.Type: return try unbox(value, type: URL.self) as? T
        case is Decimal.Type, is NSDecimalNumber.Type: return try unbox(value, type: Decimal.self) as? T
        default:
            self.storage.push(container: value)
            defer { self.storage.popContainer() }
            return try T.init(from: self)
        }
    }
}

internal protocol XMLDecodable {
    static func unbox(_ value: Any, decoder: _XMLDecoder) throws -> Self
}

extension XMLDecodable {
    static func unwrapToString<T>(_ value: Any, codingPath: [CodingKey], type: T.Type) throws -> String {
        
        guard let stringValue = value as? String else {
            throw DecodingError.valueNotFound(type,  DecodingError.Context(codingPath: codingPath,
                                                                           debugDescription: "Expected \(type) but could not convert \(value) to String"))
        }
        return stringValue
    }
    
    static func doNumberSetup<T>(_ stringValue: String, codingPath: [CodingKey], type: T.Type) throws -> NSNumber {
        guard let floatValue = Double(stringValue) else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: T.self, reality: stringValue)
        }
        
        let number = NSNumber(value: floatValue)
        
        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: T.self, reality: number)
        }
        return number
    }
}

extension Bool: XMLDecodable {
    static func unbox(_ value: Any, decoder: _XMLDecoder) throws -> Bool {
        let string = try unwrapToString(value, codingPath: decoder.codingPath, type: Bool.self)
        switch string {
        case "true", "1": return true
        case "false", "0": return false
        default:
            throw DecodingError._typeMismatch(at: decoder.codingPath, expectation: Bool.self, reality: value)
        }
    }
}

extension Int: XMLDecodable {
    static func unbox(_ value: Any, decoder: _XMLDecoder) throws -> Int {
        let string = try unwrapToString(value, codingPath: decoder.codingPath, type: Int.self)
        let number = try doNumberSetup(string, codingPath: decoder.codingPath, type: Int.self)
        
        let int = number.intValue
        guard NSNumber(value: int) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(Int.self)."))
        }
        
        return int
    }
}

extension Int8: XMLDecodable {
    static func unbox(_ value: Any, decoder: _XMLDecoder) throws -> Int8 {
        let string = try unwrapToString(value, codingPath: decoder.codingPath, type: Int8.self)
        let number = try doNumberSetup(string, codingPath: decoder.codingPath, type: Int8.self)
        
        let int8 = number.int8Value
        guard NSNumber(value: int8) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(Int8.self)."))
        }
        
        return int8
    }
}

extension Int16: XMLDecodable {
    static func unbox(_ value: Any, decoder: _XMLDecoder) throws -> Int16 {
        let string = try unwrapToString(value, codingPath: decoder.codingPath, type: Int16.self)
        let number = try doNumberSetup(string, codingPath: decoder.codingPath, type: Int16.self)
    
        let int16 = number.int16Value
        guard NSNumber(value: int16) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(Int16.self)."))
        }
        
        return int16
    }
}

extension Int32: XMLDecodable {
    static func unbox(_ value: Any, decoder: _XMLDecoder) throws -> Int32 {
        let string = try unwrapToString(value, codingPath: decoder.codingPath, type: Int32.self)
        let number = try doNumberSetup(string, codingPath: decoder.codingPath, type: Int32.self)
    
        let int32 = number.int32Value
        guard NSNumber(value: int32) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(Int32.self)."))
        }
        
        return int32
    }
}

extension Int64: XMLDecodable {
    static func unbox(_ value: Any, decoder: _XMLDecoder) throws -> Int64 {
        let string = try unwrapToString(value, codingPath: decoder.codingPath, type: Int64.self)
        let number = try doNumberSetup(string, codingPath: decoder.codingPath, type: Int64.self)
    
        let int64 = number.int64Value
        guard NSNumber(value: int64) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(Int64.self)."))
        }
        
        return int64
    }
}

extension UInt: XMLDecodable {
    static func unbox(_ value: Any, decoder: _XMLDecoder) throws -> UInt {
        let string = try unwrapToString(value, codingPath: decoder.codingPath, type: UInt.self)
        let number = try doNumberSetup(string, codingPath: decoder.codingPath, type: UInt.self)
        
        let uint = number.uintValue
        guard NSNumber(value: uint) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(UInt.self)."))
        }
        
        return uint
    }
}

extension UInt8: XMLDecodable {
    static func unbox(_ value: Any, decoder: _XMLDecoder) throws -> UInt8 {
        let string = try unwrapToString(value, codingPath: decoder.codingPath, type: UInt8.self)
        let number = try doNumberSetup(string, codingPath: decoder.codingPath, type: UInt8.self)
    
        let uint8 = number.uint8Value
        guard NSNumber(value: uint8) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(UInt8.self)."))
        }
        
        return uint8
    }
}

extension UInt16: XMLDecodable {
    static func unbox(_ value: Any, decoder: _XMLDecoder) throws -> UInt16 {
        let string = try unwrapToString(value, codingPath: decoder.codingPath, type: UInt16.self)
        let number = try doNumberSetup(string, codingPath: decoder.codingPath, type: UInt16.self)
    
        let uint16 = number.uint16Value
        guard NSNumber(value: uint16) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(UInt16.self)."))
        }
        
        return uint16
    }
}

extension UInt32: XMLDecodable {
    static func unbox(_ value: Any, decoder: _XMLDecoder) throws -> UInt32 {
        let string = try unwrapToString(value, codingPath: decoder.codingPath, type: UInt32.self)
        let number = try doNumberSetup(string, codingPath: decoder.codingPath, type: UInt32.self)
    
        let uint32 = number.uint32Value
        guard NSNumber(value: uint32) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(UInt32.self)."))
        }
        
        return uint32
    }
}

extension UInt64: XMLDecodable {
    static func unbox(_ value: Any, decoder: _XMLDecoder) throws -> UInt64 {
        let string = try unwrapToString(value, codingPath: decoder.codingPath, type: UInt64.self)
        let number = try doNumberSetup(string, codingPath: decoder.codingPath, type: UInt64.self)
    
        let uint64 = number.uint64Value
        guard NSNumber(value: uint64) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(UInt64.self)."))
        }
        
        return uint64
    }
}

extension Float: XMLDecodable {
    static func unbox(_ value: Any, decoder: _XMLDecoder) throws -> Float {
        let string = try unwrapToString(value, codingPath: decoder.codingPath, type: Float.self)
        
        switch decoder.options.nonConformingFloatDecodingStrategy {
        case .convertFromString(let posInfString, let negInfString, let nanString):
            switch string {
            case posInfString: return Float.infinity
            case negInfString: return -Float.infinity
            case nanString: return Float.nan
            default: throw DecodingError._typeMismatch(at: decoder.codingPath, expectation: Float.self, reality: value)
            }
        default:
            let number = try doNumberSetup(string, codingPath: decoder.codingPath, type: Int.self)
            let double = number.doubleValue
            guard abs(double) <= Double(Float.greatestFiniteMagnitude) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Parsed XML number \(number) does not fit in \(Float.self)."))
            }
            
            return Float(double)
        }
    }
}

extension Double: XMLDecodable {
    static func unbox(_ value: Any, decoder: _XMLDecoder) throws -> Double {
        let string = try unwrapToString(value, codingPath: decoder.codingPath, type: Double.self)
        
        switch decoder.options.nonConformingFloatDecodingStrategy {
        case .convertFromString(let posInfString, let negInfString, let nanString):
            switch string {
            case posInfString: return Double.infinity
            case negInfString: return -Double.infinity
            case nanString: return Double.nan
            default: throw DecodingError._typeMismatch(at: decoder.codingPath, expectation: Double.self, reality: value)
            }
        default:
            guard let number = Decimal(string: string) as NSDecimalNumber?,
                number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
                    throw DecodingError._typeMismatch(at: decoder.codingPath, expectation: Double.self, reality: value)
            }
            
            return number.doubleValue
        }
    }
}

extension String: XMLDecodable {
    static func unbox(_ value: Any, decoder: _XMLDecoder) throws -> String {
        let string = try unwrapToString(value, codingPath: decoder.codingPath, type: Double.self)
        
        return string
    }
}

extension Date: XMLDecodable {
    static func unbox(_ value: Any, decoder: _XMLDecoder) throws -> Date {
        
        switch decoder.options.dateDecodingStrategy {
        case .deferredToDate:
            decoder.storage.push(container: value)
            defer { decoder.storage.popContainer() }
            return try Date(from: decoder)

        case .secondsSince1970:
            let double: Double = try Double.unbox(value, decoder: decoder)
            return Date(timeIntervalSince1970: double)
            
        case .millisecondsSince1970:
            let double: Double = try Double.unbox(value, decoder: decoder)
            return Date(timeIntervalSince1970: double / 1000.0)
            
        case .iso8601:
            if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                let string: String = try String.unbox(value, decoder: decoder)
                guard let date = _iso8601Formatter.date(from: string) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected date string to be ISO8601-formatted."))
                }
                
                return date
            } else {
                fatalError("ISO8601DateFormatter is unavailable on this platform.")
            }
            
        case .formatted(let formatter):
            let string: String = try String.unbox(value, decoder: decoder)
            guard let date = formatter.date(from: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Date string does not match format expected by formatter."))
            }
            
            return date
            
        case .custom(let closure):
            decoder.storage.push(container: value)
            defer { decoder.storage.popContainer() }
            return try closure(decoder)
        }
    }
}

extension Data: XMLDecodable {
    static func unbox(_ value: Any, decoder: _XMLDecoder) throws -> Data {
        
        switch decoder.options.dataDecodingStrategy {
        case .deferredToData:
            decoder.storage.push(container: value)
            defer { decoder.storage.popContainer() }
            return try Data(from: decoder)
            
        case .base64:
            guard let string = value as? String else {
                throw DecodingError._typeMismatch(at: decoder.codingPath, expectation: Data.self, reality: value)
            }
            
            guard let data = Data(base64Encoded: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encountered Data is not valid Base64."))
            }
            
            return data
            
        case .custom(let closure):
            decoder.storage.push(container: value)
            defer { decoder.storage.popContainer() }
            return try closure(decoder)
        }
    }
}

extension Decimal: XMLDecodable {
    static func unbox(_ value: Any, decoder: _XMLDecoder) throws -> Decimal {
        
        // Attempt to bridge from NSDecimalNumber.
        let doubleValue: Double = try Double.unbox(value, decoder: decoder)
        return Decimal(doubleValue)
    }
}

extension URL: XMLDecodable {
    static func unbox(_ value: Any, decoder: _XMLDecoder) throws -> URL {
        let string = try unwrapToString(value, codingPath: decoder.codingPath, type: Double.self)
        guard let url = URL(string: string) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath,
                                                                    debugDescription: "Invalid URL string."))
        }
        return url
    }
}
