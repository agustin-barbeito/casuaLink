//
//  userCell.swift
//  casuaLink
//
//  Created by Agustin Barbeito on 3/17/17.
//  Copyright © 2017 Agustin Barbeito. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class userCell: UITableViewCell {
    
    var message: Message? {
        
        didSet {
            
            setupNameAndProfileImg()
            
            self.detailTextLabel?.text = message?.text
            
            if let seconds = message?.timestamp?.doubleValue {
                
                let timestampDate = NSDate(timeIntervalSince1970: seconds)
                
                let dateFormatter = NSDateFormatter()
                
                dateFormatter.dateFormat = "hh:mm a"
                
                timeLabel.text = dateFormatter.stringFromDate(timestampDate)
            }
        }
    }
    
    private func setupNameAndProfileImg() {

        if let id = message?.chatPartnerId()
        
        {
            
            let ref = FIRDatabase.database().reference().child("Users").child(id)
            
            ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    self.textLabel?.text = dictionary["name"] as? String
                    
                    if let profileImgUrl = dictionary["profileImgUrl"] as? String {
                        
                    self.profileImageView.loadImageUsingCacheWithUrlString(profileImgUrl)
                    }
                }
            })
        }
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        textLabel?.frame = CGRectMake(64, textLabel!.frame.origin.y - 2, textLabel!.frame.width, textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRectMake(64, detailTextLabel!.frame.origin.y + 2, detailTextLabel!.frame.width, detailTextLabel!.frame.height)
    }
    
    let profileImageView: UIImageView = {
        
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.layer.cornerRadius = 15
        
        imageView.layer.masksToBounds = true
        
        imageView.contentMode = .ScaleAspectFill
        
        return imageView
    }()
    
    let timeLabel: UILabel = {
        
        let label = UILabel()
        
        label.font = UIFont.systemFontOfSize(13)
        
        label.textColor = UIColor.lightGrayColor()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
        
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        // Constraints
        
        profileImageView.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 8).active = true
        
        profileImageView.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
        
        profileImageView.widthAnchor.constraintEqualToConstant(40).active = true
        
        profileImageView.heightAnchor.constraintEqualToConstant(40).active = true
        
        timeLabel.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true

        timeLabel.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 27).active = true

        timeLabel.widthAnchor.constraintEqualToConstant(100).active = true

        timeLabel.heightAnchor.constraintEqualToAnchor(textLabel?.heightAnchor).active = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
