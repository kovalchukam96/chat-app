import Foundation
@testable import Messenger

final class JSONDecoderMock: JSONDecoderType {

    var invokedDecode = false
    var invokedDecodeCount = 0
    var invokedDecodeParameters: (type: Any, data: Data)?
    var invokedDecodeParametersList = [(type: Any, data: Data)]()
    var stubbedDecodeError: Error?
    var stubbedDecodeResult: Any!

    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        invokedDecode = true
        invokedDecodeCount += 1
        invokedDecodeParameters = (type, data)
        invokedDecodeParametersList.append((type, data))
        if let error = stubbedDecodeError {
            throw error
        }
        // swiftlint:disable:next force_cast
        return stubbedDecodeResult as! T
    }
}
