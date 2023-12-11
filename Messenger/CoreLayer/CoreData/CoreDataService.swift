import UIKit
import CoreData
import TFSChatTransport

protocol CoreDataService: AnyObject {
    var persistentContainer: NSPersistentContainer { get }
    var viewContext: NSManagedObjectContext { get }
    func save(block: @escaping (NSManagedObjectContext) throws -> Void)
}

final class CoreDataServiceImpl: CoreDataService {
    
    lazy var persistentContainer: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: modelName)
        persistentContainer.loadPersistentStores { _, error in
            guard let error else { return }
            print(error)
        }
        persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return persistentContainer
    }()
    
    private let logger: Logger
    
    private let modelName: String
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    init(logger: Logger, modelName: String) {
        self.logger = logger
        self.modelName = modelName
    }
  
    func save(block: @escaping (NSManagedObjectContext) throws -> Void) {
        
        let backgroundContext = persistentContainer.newBackgroundContext()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleContextDidSave(notification:)),
            name: .NSManagedObjectContextDidSave,
            object: backgroundContext
        )
        backgroundContext.perform { [weak self] in
            do {
                try block(backgroundContext)
                if backgroundContext.hasChanges {
                    try backgroundContext.save()
                }
            } catch {
                self?.logger.error("Can not save context with error: \(error.localizedDescription)")
            }
        }
    }
        
    @objc private func handleContextDidSave(notification: Notification) {
        viewContext.perform { [weak self] in
            self?.viewContext.mergeChanges(fromContextDidSave: notification)
        }
    }
    
}
