import UIKit
import CoreData

protocol ChannelExistance: AnyObject {
    func isChannelExist(channelID: String, context: NSManagedObjectContext) -> DBChannel?
}

extension ChannelExistance {
    func isChannelExist(channelID: String, context: NSManagedObjectContext) -> DBChannel? {
        let channelFetchRequest = NSFetchRequest<DBChannel>(entityName: "DBChannel")
        let channelPredicate = NSPredicate(format: "id == %@", channelID as CVarArg)
        let logger = Logger()
        channelFetchRequest.predicate = channelPredicate
        guard let channels = try? context.fetch(channelFetchRequest) else {
            logger.debug("Can not fetch channels for id: \(channelID)")
            return nil
        }
        return channels.first
    }
}
