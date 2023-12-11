//
//  DBMessage+CoreDataProperties.swift
//  Messenger
//
//  Created by Артем Ковальчук on 11.04.2023.
//
//

import Foundation
import CoreData

extension DBMessage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBMessage> {
        return NSFetchRequest<DBMessage>(entityName: "DBMessage")
    }
    @NSManaged public var id: String?
    @NSManaged public var text: String?
    @NSManaged public var userID: String?
    @NSManaged public var userName: String?
    @NSManaged public var date: Date?
    @NSManaged public var channel: DBChannel?

}

extension DBMessage: Identifiable {

}
