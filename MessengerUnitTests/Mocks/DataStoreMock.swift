import Foundation
import Combine
@testable import Messenger

final class DataStoreMock: DataStore {

    var invokedGet = false
    var invokedGetCount = 0
    var invokedGetParameters: (path: String, Void)?
    var invokedGetParametersList = [(path: String, Void)]()
    var stubbedGetResult: AnyPublisher<Data?, Error>!

    func get(path: String) -> AnyPublisher<Data?, Error> {
        invokedGet = true
        invokedGetCount += 1
        invokedGetParameters = (path, ())
        invokedGetParametersList.append((path, ()))
        return stubbedGetResult
    }

    var invokedSave = false
    var invokedSaveCount = 0
    var invokedSaveParameters: (data: Data, path: String, cancel: CancelWrapper)?
    var invokedSaveParametersList = [(data: Data, path: String, cancel: CancelWrapper)]()
    var stubbedSaveResult: AnyPublisher<Void, Error>!

    func save(data: Data, path: String, cancel: CancelWrapper) -> AnyPublisher<Void, Error> {
        invokedSave = true
        invokedSaveCount += 1
        invokedSaveParameters = (data, path, cancel)
        invokedSaveParametersList.append((data, path, cancel))
        return stubbedSaveResult
    }
}
