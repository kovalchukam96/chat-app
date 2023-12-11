import Foundation
@testable import Messenger

final class JSONEncoderMock: JSONEncoderType {

    var invokedEncode = false
    var invokedEncodeCount = 0
    var invokedEncodeParameters: (value: Any, Void)?
    var invokedEncodeParametersList = [(value: Any, Void)]()
    var stubbedEncodeError: Error?
    var stubbedEncodeResult: Data!

    func encode<T>(_ value: T) throws -> Data where T: Encodable {
        invokedEncode = true
        invokedEncodeCount += 1
        invokedEncodeParameters = (value, ())
        invokedEncodeParametersList.append((value, ()))
        if let error = stubbedEncodeError {
            throw error
        }
        return stubbedEncodeResult
    }
}
