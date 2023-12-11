import UIKit
import CoreData
import TFSChatTransport

protocol ConversationDataStore: AnyObject {
    func messagesRequest(for channelID: String) -> NSFetchRequest<DBMessage>
    func saveMessages(channelID: String, messages: [Message])
    func saveMessage(channelID: String, message: Message)
}

final class ConversationDataStoreImpl: ConversationDataStore, ChannelExistance {
    
    private let coreDataService: CoreDataService
    
    private let logger: Logger
    
    init(coreDataService: CoreDataService, logger: Logger) {
        self.coreDataService = coreDataService
        self.logger = logger
    }
    
    func messagesRequest(for channelID: String) -> NSFetchRequest<DBMessage> {
        let fetchRequest = DBMessage.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "channel.id == %@", channelID as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return fetchRequest
    }
    
    func saveMessages(channelID: String, messages: [Message]) {
        coreDataService.save { [weak self] context in
            guard let self = self else { return }
            if let channel = self.isChannelExist(channelID: channelID, context: context) {
                for message in messages {
                    guard self.isMessageUnique(id: message.id, context: context) else { return }
                    let dbMessage = DBMessage(context: context)
                    dbMessage.text = message.text
                    dbMessage.date = message.date
                    dbMessage.userID = message.userID
                    dbMessage.userName = message.userName
                    dbMessage.channel = channel
                    dbMessage.id = message.id
                    dbMessage.channel?.lastMessage = message.text
                    dbMessage.channel?.lastActivity = message.date
                }
            }
        }
    }
    
    func saveMessage(channelID: String, message: Message) {
        coreDataService.save { [weak self] context in
            guard let self = self else { return }
            
            if let channel = self.isChannelExist(channelID: channelID, context: context) {
                guard self.isMessageUnique(id: message.id, context: context) else { return }
                let dbMessage = DBMessage(context: context)
                dbMessage.text = message.text
                dbMessage.date = message.date
                dbMessage.userID = message.userID
                dbMessage.userName = message.userName
                dbMessage.channel = channel
                dbMessage.id = message.id
                dbMessage.channel?.lastMessage = message.text
                dbMessage.channel?.lastActivity = message.date
            }
        }
    }
    
    private func isMessageUnique(id: String, context: NSManagedObjectContext) -> Bool {
        let fetchRequest = NSFetchRequest<DBMessage>(entityName: "DBMessage")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let messages = try context.fetch(fetchRequest)
            return messages.isEmpty
        } catch {
            logger.debug("Failed to check for uniqueness: \(error.localizedDescription)")
            return false
        }
    }
    
}
