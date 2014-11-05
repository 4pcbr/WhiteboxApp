//
//  Capture.swift
//  Whitebox
//
//  Created by Olegs on 06/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

import Foundation
import CoreData

class Capture: NSManagedObject {

    @NSManaged var created_at: NSDate
    @NSManaged var type: NSNumber
    @NSManaged var capture_data: NSSet

}
