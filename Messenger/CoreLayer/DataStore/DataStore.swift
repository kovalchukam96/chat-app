import Combine
import UIKit

protocol DataStore {
    func get(path: String) -> AnyPublisher<Data?, Error>
    func save(data: Data, path: String, cancel: CancelWrapper) -> AnyPublisher<Void, Error>
}
