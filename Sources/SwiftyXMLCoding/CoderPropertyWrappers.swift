//
//  File.swift
//  
//
//  Created by Paul Fechner Jr on 9/17/19.
//


import Foundation

@propertyWrapper struct NonCodable<T: Codable>: Codable {
    public let wrappedValue: T?
    public init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        wrappedValue = nil
    }
    
    public func encode(to encoder: Encoder) throws {
        return
    }
}

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

@propertyWrapper
public struct CustomEncoding<CustomEncoder: StaticEnocoder>: Encodable {
    public let wrappedValue: CustomEncoder.EncodingType
    public init(wrappedValue: CustomEncoder.EncodingType) {
        self.wrappedValue = wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        try CustomEncoder.encode(value: wrappedValue, to: encoder)
    }
}

@propertyWrapper
public struct CustomDecoding<CustomDecoder: StaticDeocoder>: Decodable {
    public let wrappedValue: CustomDecoder.DecodingType
    public init(wrappedValue: CustomDecoder.DecodingType) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        self.init(wrappedValue: try CustomDecoder.decode(from: decoder))
    }
}
extension CustomCoding: Equatable where Coder.CodingType: Equatable {}

public protocol NonConformingFloatValueProvider {
    static var positiveInfinity: String { get }
    static var negativeInfinity: String { get }
    static var nan: String { get }
}

public struct CustomNonConformingFloatCoder<ValueProvider: NonConformingFloatValueProvider>: StaticCoder {
    public static func decode(from decoder: Decoder) throws -> Float {
        let stringValue = try String(from: decoder)
        switch stringValue {
        case ValueProvider.positiveInfinity: return Float.infinity
        case ValueProvider.negativeInfinity: return -Float.infinity
        case ValueProvider.nan: return Float.nan
        default:
            guard let value = Float(stringValue) else {
                throw DecodingError.valueNotFound(self,  DecodingError.Context(codingPath: decoder.codingPath,
                debugDescription: "Expected \(Float.self) but could not convert \(stringValue) to Float"))
            }
            return value
        }
    }
    
    public static func encode(value: Float, to encoder: Encoder) throws {
        
        switch value {
        case .infinity: return try ValueProvider.positiveInfinity.encode(to: encoder)
        case -.infinity: return try ValueProvider.negativeInfinity.encode(to: encoder)
        case .nan: return try ValueProvider.nan.encode(to: encoder)
        default: try String(value).encode(to: encoder)
        }
    }
}
public struct CustomNonConformingDoubleCoder<ValueProvider: NonConformingFloatValueProvider>: StaticCoder {
    public static func decode(from decoder: Decoder) throws -> Double {
        let stringValue = try String(from: decoder)
        switch stringValue {
        case ValueProvider.positiveInfinity: return Double.infinity
        case ValueProvider.negativeInfinity: return -Double.infinity
        case ValueProvider.nan: return Double.nan
        default:
            guard let value = Double(stringValue) else {
                throw DecodingError.valueNotFound(self,  DecodingError.Context(codingPath: decoder.codingPath,
                debugDescription: "Expected \(Double.self) but could not convert \(stringValue) to Float"))
            }
            return value
        }
    }
    
    public static func encode(value: Double, to encoder: Encoder) throws {
        
        switch value {
        case .infinity: return try ValueProvider.positiveInfinity.encode(to: encoder)
        case -.infinity: return try ValueProvider.negativeInfinity.encode(to: encoder)
        case .nan: return try ValueProvider.nan.encode(to: encoder)
        default: try String(value).encode(to: encoder)
        }
    }
}

public struct DataCoders {
    private init() { }
    public struct Base64: StaticCoder {
        private init() { }
        
        public static func decode(from decoder: Decoder) throws -> Data {
            let stringValue = try String(from: decoder)
            
            guard let value = Data.init(base64Encoded: stringValue) else {
                throw DecodingError.valueNotFound(self,  DecodingError.Context(codingPath: decoder.codingPath,
                                                                               debugDescription: "Expected \(Data.self) but could not convert \(stringValue) to Data"))
            }
            return value
        }
        public static func encode(value: Data, to encoder: Encoder) throws {
            try value.base64EncodedString().encode(to: encoder)
        }
    }
    
    public struct Custom<Coder: CustomDataStringCoder>: StaticCoder {
        private init() { }
        
        public static func decode(from decoder: Decoder) throws -> Data {
            let stringValue = try String(from: decoder)
            
            guard let value = try Coder.decode(stringValue) else {
                throw DecodingError.valueNotFound(self,  DecodingError.Context(codingPath: decoder.codingPath,
                                                                               debugDescription: "Expected \(Data.self) but could not convert \(stringValue) to Data"))
            }
            return value
        }
        public static func encode(value: Data, to encoder: Encoder) throws {
            try Coder.encode(value).encode(to: encoder)
        }
    }
}

public struct DateCoders {
    private init() { }
    
    public struct MillisecondsSince1970: StaticCoder {
        private init() { }
        
        public static func decode(from decoder: Decoder) throws -> Date {
            let stringValue = try String(from: decoder)
            guard let value = Double(stringValue) else {
                throw DecodingError.valueNotFound(self,  DecodingError.Context(codingPath: decoder.codingPath,
                                                                               debugDescription: "Expected \(Date.self) but could not convert \(stringValue) to Date"))
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
                                                                               debugDescription: "Expected \(Date.self) but could not convert \(stringValue) to Date"))
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

public protocol CustomValueDecoder {
    associatedtype DecodingType: Decodable
    associatedtype EncodedType
    static func decode(_ value: EncodedType) throws -> DecodingType?
}

public protocol CustomValueEncoder {
    associatedtype EncodingType: Encodable
    associatedtype DecodedType
    static func encode(_ date: DecodedType) throws -> EncodingType
}
public protocol CustomValueCoder: CustomValueDecoder & CustomValueEncoder where DecodingType == DecodedType, EncodedType == EncodingType {
    typealias CodingType = DecodingType
}

public protocol CustomDateDecoder: CustomValueDecoder where DecodingType == Date, EncodedType == String {
    static func decode(_ value: String) throws -> Date?
}

public protocol CustomDateEncoder: CustomValueEncoder where EncodingType == String, DecodedType == Date {
    static func encode(_ date: Date) throws -> String
}
public protocol CustomDateCoder: CustomValueCoder & CustomDateEncoder & CustomDateDecoder { }


public protocol CustomDataStringDecoder: CustomValueDecoder where DecodingType == Data, EncodedType == String {
    static func decode(_ value: String) throws -> Data?
}

public protocol CustomDataStringEncoder: CustomValueEncoder where EncodingType == String, DecodedType == Data {
    static func encode(_ date: Date) throws -> String
}
public protocol CustomDataStringCoder: CustomValueCoder & CustomDataStringEncoder & CustomDataStringDecoder { }

//public protocol CustomDataStringDecoder: CustomValueDecoder where DecodingType == Data, EncodedType == String {
//    static func decode(_ value: String) throws -> Data?
//}
//
//public protocol CustomDataStringEncoder: CustomValueEncoder where EncodingType == String, DecodedType == Data {
//    static func encode(_ date: Date) throws -> String
//}
//public protocol CustomDataStringCoder: CustomValueCoder & CustomDataStringEncoder & CustomDataStringDecoder { }





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

protocol AnyXMLAttributeProperty { }

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
