import Combine
import UIKit

final class DataStoreImpl: DataStore {
    
    private let fileManager = FileManager.default
    
    private let queue = DispatchQueue(label: "DataStoreQueue", qos: .userInitiated)
    
    private func fileURL(path: String) throws -> URL {
        try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        .appendingPathComponent(path)
    }
    
    func get(path: String) -> AnyPublisher<Data?, Error> {
        Deferred {
            Future { [weak self] promise in
                do {
                    let fileName = try self?.fileURL(path: path)
                    guard let fileName = fileName else { return }
                    let data = try? Data(contentsOf: fileName)
                    promise(.success(data))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .subscribe(on: queue)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func save(data: Data, path: String, cancel: CancelWrapper) -> AnyPublisher<Void, Error> {
        Deferred {
            Future { [weak self] promise in
                
                do {
                    guard let self = self else { return }
                    let copyPath = "\(path)_copy"
                    let copyFilePath = try self.fileURL(path: copyPath)
                    let originalFilePath = try self.fileURL(path: path)
                    try data.write(to: copyFilePath)
                    if cancel.isCancelled == false {
                        _ = try self.fileManager.replaceItemAt(originalFilePath, withItemAt: copyFilePath)
                    }
                    promise(.success(()))
                    
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .subscribe(on: queue)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

final class CancelWrapper {
    var isCancelled: Bool = false
}
