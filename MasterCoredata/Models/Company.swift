//
//  Company.swift
//  MasterCoredata
//
//  Created by Hosamane, Vinay K N on 19/05/21.
//

import Foundation
import CoreData

class Company: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var location: String
    
}
