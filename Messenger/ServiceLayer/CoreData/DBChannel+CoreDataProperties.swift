//
//  DBChannel+CoreDataProperties.swift
//  Messenger
//
//  Created by Артем Ковальчук on 11.04.2023.
//
//

import Foundation
import CoreData

extension DBChannel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBChannel> {
        return NSFetchRequest<DBChannel>(entityName: "DBChannel")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var logoURL: String?
    @NSManaged public var lastMessage: String?
    @NSManaged public var lastActivity: Date?
    @NSManaged public var messages: NSOrderedSet?

}

extension DBChannel {

    @objc(insertObject:inMessagesAtIndex:)
    @NSManaged public func insertIntoMessages(_ value: DBMessage, at idx: Int)

    @objc(removeObjectFromMessagesAtIndex:)
    @NSManaged public func removeFromMessages(at idx: Int)

    @objc(insertMessages:atIndexes:)
    @NSManaged public func insertIntoMessages(_ values: [DBMessage], at indexes: NSIndexSet)

    @objc(removeMessagesAtIndexes:)
    @NSManaged public func removeFromMessages(at indexes: NSIndexSet)

    @objc(replaceObjectInMessagesAtIndex:withObject:)
    @NSManaged public func replaceMessages(at idx: Int, with value: DBMessage)

    @objc(replaceMessagesAtIndexes:withMessages:)
    @NSManaged public func replaceMessages(at indexes: NSIndexSet, with values: [DBMessage])

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: DBMessage)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: DBMessage)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSOrderedSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSOrderedSet)

}

extension DBChannel: Identifiable {

}
