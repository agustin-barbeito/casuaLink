//
//  Extensions.swift
//  casuaLink
//
//  Created by Agustin Barbeito on 3/14/17.
//  Copyright © 2017 Agustin Barbeito. All rights reserved.
//

import Foundation
import UIKit

let imageCache = NSCache()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(urlString: String)
    
    {
        
        self.image = nil
        
        if let cachedImage = imageCache.objectForKey(urlString) as? UIImage {
            
            self.image = cachedImage
            
            return
        }
        
        let url = NSURL(string: urlString)
     
        NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
            
            if error != nil {
                
                print(error)
                
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if let downloadedImage = UIImage(data: data!) {
                    
                    imageCache.setObject(downloadedImage, forKey: urlString)
                    
                    self.image = downloadedImage
                }
            })
            
        }).resume()
    }
}