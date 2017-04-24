//
//  Message.swift
//  casuaLink
//
//  Created by Agustin Barbeito on 3/16/17.
//  Copyright © 2017 Agustin Barbeito. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Message: NSObject {
    
    var fromId: String?
    var toId: String?
    var text: String?
    var timestamp: NSNumber?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    var imageUrl: String?
    
    init(dictionary: [String: AnyObject]) {
        
        super.init()
        
        fromId = dictionary["fromId"] as? String
        
        text = dictionary["text"] as? String
        
        timestamp = dictionary["timestamp"] as? NSNumber
        
        toId = dictionary["toId"] as? String
        
        imageUrl = dictionary["imageUrl"] as? String
        
        imageWidth = dictionary["imageWidth"] as? NSNumber
        
        imageHeight = dictionary["imageHeight"] as? NSNumber
}
    
    func chatPartnerId() -> String? {
        
        if fromId == FIRAuth.auth()?.currentUser?.uid
            
        {
            return toId
            
        } else {
            
            return fromId
        }
    }
}