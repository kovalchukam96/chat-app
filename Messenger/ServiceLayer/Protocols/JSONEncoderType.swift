import Foundation

protocol JSONEncoderType {
    func encode<T>(_ value: T) throws -> Data where T: Encodable
}

extension JSONEncoder: JSONEncoderType {}
