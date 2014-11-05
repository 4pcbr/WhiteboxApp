//
//  CaptureData.swift
//  Whitebox
//
//  Created by Olegs on 06/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

import Foundation
import CoreData

class CaptureData: NSManagedObject {

    @NSManaged var provider: String
    @NSManaged var status: NSNumber
    @NSManaged var meta: String
    @NSManaged var capture: Capture

}
