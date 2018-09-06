//
//  Art+CoreDataProperties.swift
//  Assignment 2
//
//  Created by Adam Hawkins on 30/11/2017.
//  Copyright © 2017 Adam Hawkins. All rights reserved.
//
//

import Foundation
import CoreData


extension Art {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Art> {
        return NSFetchRequest<Art>(entityName: "Art")
    }

    @NSManaged public var artist: String?
    @NSManaged public var fileName: String?
    @NSManaged public var id: String?
    @NSManaged public var information: String?
    @NSManaged public var lastModified: String?
    @NSManaged public var lat: String?
    @NSManaged public var location: String?
    @NSManaged public var locationNotes: String?
    @NSManaged public var long: String?
    @NSManaged public var title: String?
    @NSManaged public var yearOfWork: String?
}
