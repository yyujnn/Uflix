//
//  FavoriteMovie+CoreDataProperties.swift
//  Uflix
//
//  Created by 정유진 on 5/19/25.
//
//

import Foundation
import CoreData


extension FavoriteMovie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteMovie> {
        return NSFetchRequest<FavoriteMovie>(entityName: "FavoriteMovie")
    }

    @NSManaged public var posterPath: String?
    @NSManaged public var savedDate: Date?
    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var overview: String?

}

extension FavoriteMovie : Identifiable {

}
