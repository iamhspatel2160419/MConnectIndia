//
//  Album+CoreDataProperties.swift
//  MConnectIndia
//
//  Created by Apple on 20/12/20.
//
//

import Foundation
import CoreData


extension Album {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Album> {
        return NSFetchRequest<Album>(entityName: "Album")
    }

    @NSManaged public var image_id: String?
    @NSManaged public var imagePath: String?
    @NSManaged public var date: String?
    @NSManaged public var isSaved: String?
}

extension Album : Identifiable {

}
