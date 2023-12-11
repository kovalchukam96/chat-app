import UIKit
import CoreData
import TFSChatTransport

protocol ConversationsListDataStore: AnyObject {
    func channelsRequest() -> NSFetchRequest<DBChannel>
    func saveOrUpdate(newChannel: Channel)
    func saveOrUpdate(channels: [Channel])
    func deleteChannel(id: String)
}

final class ConversationsListDataStoreImpl: ConversationsListDataStore, ChannelExistance {
    
    private let coreDataService: CoreDataService
    
    init(coreDataService: CoreDataService) {
        self.coreDataService = coreDataService
    }
    
    func channelsRequest() -> NSFetchRequest<DBChannel> {
        let fetchRequest = DBChannel.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return fetchRequest
    }
    
    func saveOrUpdate(newChannel: Channel) {
        coreDataService.save { [weak self] context in
            guard let self = self else { return }
            if let dbChannel = self.isChannelExist(channelID: newChannel.id, context: context) {
                dbChannel.lastMessage = newChannel.lastMessage
                dbChannel.name = newChannel.name
                dbChannel.lastActivity = newChannel.lastActivity
            } else {
                let dbChannel = DBChannel(context: context)
                dbChannel.name = newChannel.name
                dbChannel.id = newChannel.id
                dbChannel.lastActivity = newChannel.lastActivity
                dbChannel.logoURL = newChannel.logoURL
                dbChannel.messages = NSOrderedSet()
                dbChannel.lastMessage = newChannel.lastMessage
            }
        }
    }
    
    func saveOrUpdate(channels: [Channel]) {
        let channelFetchRequest = NSFetchRequest<DBChannel>(entityName: "DBChannel")
        let backgroundContext = coreDataService.persistentContainer.newBackgroundContext()
        if let dbChannels = try? backgroundContext.fetch(channelFetchRequest) {
            for channel in dbChannels where !channels.contains(where: { $0.id == channel.id }) {
                guard let channelID = channel.id else { return }
                deleteChannel(id: channelID)
            }
        }
        
        coreDataService.save { [weak self] context in
            guard let self = self else { return }
            for newChannel in channels {
                if let dbChannel = self.isChannelExist(channelID: newChannel.id, context: context) {
                    dbChannel.lastMessage = newChannel.lastMessage
                    dbChannel.name = newChannel.name
                    dbChannel.lastActivity = newChannel.lastActivity
                } else {
                    let dbChannel = DBChannel(context: context)
                    dbChannel.name = newChannel.name
                    dbChannel.id = newChannel.id
                    dbChannel.lastActivity = newChannel.lastActivity
                    dbChannel.logoURL = newChannel.logoURL
                    dbChannel.messages = NSOrderedSet()
                    dbChannel.lastMessage = newChannel.lastMessage
                }
            }
        }
    }
    
    func deleteChannel(id: String) {
        coreDataService.save { [weak self] context in
            guard let channel = self?.isChannelExist(channelID: id, context: context) else { return }
            context.delete(channel)
        }
    }

}
