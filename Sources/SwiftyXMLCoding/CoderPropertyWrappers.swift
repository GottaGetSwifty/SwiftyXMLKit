//
//  File.swift
//  
//
//  Created by Paul Fechner Jr on 9/17/19.
//


import Foundation

public protocol StaticDeocoder {
    associatedtype DecodingType: Decodable
    static func decode(from decoder: Decoder) throws -> DecodingType
}

public protocol StaticEnocoder {
    associatedtype EncodingType: Encodable
    static func encode(value: EncodingType, to encoder: Encoder) throws
}

public protocol StaticCoder: StaticDeocoder & StaticEnocoder where DecodingType == EncodingType {
    typealias CodingType = DecodingType
}

@propertyWrapper
public struct CustomCoding<Coder: StaticCoder>: Codable {
    public let wrappedValue: Coder.CodingType
    public init(wrappedValue: Coder.CodingType) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        self.init(wrappedValue: try Coder.decode(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try Coder.encode(value: wrappedValue, to: encoder)
    }
}
extension CustomCoding: Equatable where Coder.CodingType: Equatable {}


public protocol DateCoder {
    
    static func decodeDate(from decoder: Decoder) throws -> Date
    static func encode(date: Date, to encoder: Encoder) throws
}

public struct DateCoders {
    
    private init() { }
    public struct MillisecondsSince1970: StaticCoder {
        private init() { }
        
        public static func decode(from decoder: Decoder) throws -> Date {
            let stringValue = try String(from: decoder)
            guard let value = Double(stringValue) else {
                throw DecodingError.valueNotFound(self,  DecodingError.Context(codingPath: decoder.codingPath,
                                                                               debugDescription: "Expected \(Date.self) but could not convert \(stringValue) to Double"))
            }
            let valueDate = Date(timeIntervalSince1970: value / 1000)
            return valueDate
        }
        public static func encode(value: Date, to encoder: Encoder) throws {
            try "\((value.timeIntervalSince1970 * 1000.0).rounded())".encode(to: encoder)
        }
    }
    
    public struct SecondsSince1970: StaticCoder {
        private init() { }
        
        public static func decode(from decoder: Decoder) throws -> Date {
            let stringValue = try String(from: decoder)
            guard let value = Double(stringValue) else {
                throw DecodingError.valueNotFound(self,  DecodingError.Context(codingPath: decoder.codingPath,
                                                                               debugDescription: "Expected \(Date.self) but could not convert \(stringValue) to Double"))
            }
            let valueDate = Date(timeIntervalSince1970: value)
            return valueDate
        }
        public static func encode(value: Date, to encoder: Encoder) throws {
            try "\(value.timeIntervalSince1970)".encode(to: encoder)
        }
    }
    
    @available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    public struct Iso8601: StaticCoder {
        private init() { }
        
        public static func decode(from decoder: Decoder) throws -> Date {
            let stringValue = try String(from: decoder)
            guard let date = _iso8601Formatter.date(from: stringValue) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected date string to be ISO8601-formatted."))
            }
            
            return date
        }
        public static func encode(value: Date, to encoder: Encoder) throws {
            try _iso8601Formatter.string(from: value).encode(to: encoder)
        }
    }
    
    public struct Custom<DateCoder: CustomDateCoder>: StaticCoder {
        private init() { }
        
        public static func decode(from decoder: Decoder) throws -> Date {
            let stringValue = try String(from: decoder)
            guard let date = try DateCoder.decode(stringValue) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Date custom date but does not match format expected by formatter.: \(DateCoder.self)"))
            }
            return date
        }
        public static func encode(value: Date, to encoder: Encoder) throws {
            try DateCoder.encode(value).encode(to: encoder)
        }
    }
}

public protocol CustomDateEncoder {
    static func encode(_ date: Date) throws -> String
}

public protocol CustomDateDecoder {
    static func decode(_ value: String) throws -> Date?
}

public protocol CustomDateCoder: CustomDateEncoder & CustomDateDecoder{
    
}

public protocol CustomDateFormatterCoder: CustomDateCoder {
    static var dateFormatter: DateFormatter { get }
}

extension CustomDateFormatterCoder {
    public static func encode(_ date: Date) throws -> String {
        dateFormatter.string(from: date)
    }
    
    public static func decode(_ value: String) throws -> Date? {
        dateFormatter.date(from: value)
    }
}

protocol AnyXMLAttributeProperty {
    
}

public struct XMLCDataCoder: StaticCoder {
    public static func decode(from decoder: Decoder) throws -> String {
        try String(from: decoder)
    }
    
    public static func encode(value: String, to encoder: Encoder) throws {
        if encoder is _XMLEncoder {
            try "<![CDATA[\(value)]]>".encode(to: encoder)
        }
        else {
            try value.encode(to: encoder)
        }
    }
}

@propertyWrapper
public struct XMLAttributeProperty<T: Codable>: Codable, AnyXMLAttributeProperty {
    public let wrappedValue: T
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
