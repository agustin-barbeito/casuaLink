//
//  ChatMessageCell.swift
//  casuaLink
//
//  Created by Agustin Barbeito on 3/22/17.
//  Copyright © 2017 Agustin Barbeito. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class ChatMessageCell: UICollectionViewCell {
    
    let chatController = ChatController()
    
     var bubbleWidthAnchor: NSLayoutConstraint?
    
    var bubbleRightAnchor: NSLayoutConstraint?
    
    var bubbleLeftAnchor: NSLayoutConstraint?
    
    let textView: UITextView = {
        
        let tv = UITextView()
        tv.font = UIFont.systemFontOfSize(16)
        tv.backgroundColor = UIColor.clearColor()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.editable = false
        return tv
        
    }()

    let bubbleView: UIView = {
        
        let view = UIView()
        
        view.backgroundColor = color1
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.userInteractionEnabled = true
        
        view.layer.cornerRadius = 16
        
        view.layer.masksToBounds = true
        
        return view
        
    }()
    
    let profileImageView: UIImageView = {
    
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.layer.cornerRadius = 16
        
        imageView.layer.masksToBounds = true
        
        imageView.contentMode = .ScaleAspectFill
        
        return imageView

    }()
    
    lazy var messageImageView: UIImageView =
        
        {
    
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.userInteractionEnabled = true
        
        imageView.layer.cornerRadius = 16
        
        imageView.layer.masksToBounds = true
        
        imageView.contentMode = .ScaleAspectFill
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageZoomIn)))
        
        return imageView
        
    }()
    
    func imageZoomIn(sender: UITapGestureRecognizer){
        
        print("ff")
        
    }
    
  override init(frame: CGRect) {
    
    super.init(frame: frame)
    
    addSubview(bubbleView)
    addSubview(textView)
    addSubview(profileImageView)
    
    bubbleView.addSubview(messageImageView)
    
    // Constraints
    
    messageImageView.leftAnchor.constraintEqualToAnchor(bubbleView.leftAnchor).active = true
    
    messageImageView.topAnchor.constraintEqualToAnchor(bubbleView.topAnchor).active = true
    
    messageImageView.widthAnchor.constraintEqualToAnchor(bubbleView.widthAnchor).active = true
    
    messageImageView.heightAnchor.constraintEqualToAnchor(bubbleView.heightAnchor).active = true

    
    profileImageView.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 8).active = true
    
    profileImageView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
    
    profileImageView.widthAnchor.constraintEqualToConstant(32).active = true
    
    profileImageView.heightAnchor.constraintEqualToConstant(32).active = true
    
  
    textView.leftAnchor.constraintEqualToAnchor(bubbleView.leftAnchor).active = true
    
    textView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
    
    textView.rightAnchor.constraintEqualToAnchor(bubbleView.rightAnchor).active = true
    
    textView.heightAnchor.constraintEqualToAnchor(self.heightAnchor).active = true
    
    bubbleRightAnchor = bubbleView.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: -8)
    
    bubbleRightAnchor?.active = true
    
    bubbleLeftAnchor = bubbleView.leftAnchor.constraintEqualToAnchor(profileImageView.rightAnchor, constant: 8)
    
    bubbleView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
    
    bubbleWidthAnchor = bubbleView.widthAnchor.constraintEqualToConstant(200)
    
    bubbleWidthAnchor!.active = true
    
    bubbleView.heightAnchor.constraintEqualToAnchor(self.heightAnchor).active = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
