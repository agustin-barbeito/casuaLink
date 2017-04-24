//
//  ChatController.swift
//  casuaLink
//
//  Created by Agustin Barbeito on 3/14/17.
//  Copyright © 2017 Agustin Barbeito. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var messages = [Message]()
    
    let cellId = "cellId"
    
    var user: User? {
        
        didSet {
            
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var inputTextField: UITextField!
    
    @IBOutlet weak var fieldImageView: UIImageView!
    
    @IBAction func sendMessage(sender: AnyObject) {
        
        let properties = ["text": inputTextField.text!]
        
        sendMessageWithProperties(properties)
    }
    
    private func sendMessageWithProperties(properties: [String: AnyObject]) {
        
        let ref = FIRDatabase.database().reference().child("Messages")
        
        let childRef = ref.childByAutoId()
        
        let toId = user!.id!
        
        let fromId = FIRAuth.auth()!.currentUser!.uid
        
        let timestamp: NSNumber = Int(NSDate().timeIntervalSince1970)
        
        var values: [String: AnyObject] = ["toId": toId, "fromId": fromId, "timestamp": timestamp]
        
        properties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            
            if error != nil {
                
                print(error)
                return
            }
            
            self.inputTextField.text = nil
            
            let userMessagesRef = FIRDatabase.database().reference().child("UserMessages").child(fromId).child(toId)
            
            let messageId = childRef.key
            
        userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = FIRDatabase.database().reference().child("UserMessages").child(toId).child(fromId)
            
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        }
    }

    override func viewDidLoad () {
        
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        collectionView.registerClass(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImageToSend))
        
        fieldImageView.addGestureRecognizer(tapGestureRecognizer)
        
        fieldImageView.userInteractionEnabled = true
        
        fieldImageView.image = UIImage(named: "photo.png")

    }
    
    func observeMessages(){
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid, toId = user?.id else {
            
            return
        }
        
        let userMessagesRef = FIRDatabase.database().reference().child("UserMessages").child(uid).child(toId)
        
        userMessagesRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            let messageId = snapshot.key
            
            let messagesRef = FIRDatabase.database().reference().child("Messages").child(messageId)
            
            messagesRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else
                {
                    
                    return
                }
                
                self.messages.append(Message(dictionary: dictionary))
                
                dispatch_async(dispatch_get_main_queue(), {
                
                self.collectionView.reloadData()
                    
                    let indexPath = NSIndexPath(forItem: self.messages.count - 1, inSection: 0)
                    
                    self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
                })
                
                }, withCancelBlock: nil)
            
            }, withCancelBlock: nil)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        
        cell.textView.text = message.text
        
        configureCell(cell, message: message)
        
        if let text = message.text {
            
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text).width + 32
            
            cell.textView.hidden = false
        
        } else if message.imageUrl != nil {
            
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.hidden = true
            
        }
        
        return cell
    }
    
    private func configureCell(cell: ChatMessageCell, message: Message){
        
        if let profileImageUrl = self.user?.profileImgUrl {
            
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        if let messageImageUrl = message.imageUrl {
            
            cell.messageImageView.loadImageUsingCacheWithUrlString(messageImageUrl)
            
            cell.messageImageView.hidden = false
            
            cell.bubbleView.layer.backgroundColor = UIColor.clearColor().CGColor
            
        } else {
            
            cell.messageImageView.hidden = true
        }
        
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            
            cell.bubbleView.backgroundColor = color1
            cell.textView.textColor = UIColor.blackColor()
            
            cell.profileImageView.hidden = true
            
            cell.bubbleRightAnchor?.active = true
            cell.bubbleLeftAnchor?.active = false
            
        } else {
            
            cell.bubbleView.backgroundColor = UIColor.blackColor()
            
            cell.textView.textColor = color1
            
            cell.profileImageView.hidden = false
            
            cell.bubbleRightAnchor?.active = false
            
            cell.bubbleLeftAnchor?.active = true
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
            
            if let text = message.text {
            
            height = estimateFrameForText(text).height + 28
                
            } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue
            
            {
                height = CGFloat(imageHeight / imageWidth * 200)
                
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        
        let options = NSStringDrawingOptions.UsesFontLeading.union(.UsesLineFragmentOrigin)
        
        return NSString(string: text).boundingRectWithSize(size, options: options, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(16)], context: nil)
    }
    
    func selectImageToSend(){
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        self.imageSelectedForInfo(info)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imageSelectedForInfo(info: [String: AnyObject]) {
        
        var selectedImage: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            selectedImage = editedImage
            
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            selectedImage = originalImage
        }
        
        if let image = selectedImage {
            
        uploadImageToFirebaseStorage(image, completion: { (imageUrl) in
                
                self.sendMessageWithImageUrl(imageUrl, image: selectedImage!)
            })
        }
    }
    
    func uploadImageToFirebaseStorage(image: UIImage, completion: (imageUrl: String) -> ()) {
        
        let imageName = NSUUID().UUIDString
        
        let ref = FIRStorage.storage().reference().child("MessageImages").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    
                    print(error)
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    
              completion(imageUrl: imageUrl)
                
                }
            })
        }
    }
    
    func sendMessageWithImageUrl(imageUrl: String, image: UIImage){
        
        let ref = FIRDatabase.database().reference().child("Messages")
        
        let toId = user!.id!
        
        let fromId = FIRAuth.auth()!.currentUser!.uid
        
        let timestamp: NSNumber = Int(NSDate().timeIntervalSince1970)
        
        let values = ["toId": toId, "fromId": fromId, "timestamp": timestamp, "imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height]
        
        let childRef = ref.childByAutoId()
        
        childRef.updateChildValues(values)
        { (error, ref) in
            
            if error != nil {
                
                print(error)
                
                return
            }
            
            self.inputTextField.text = nil
            
            let userMessagesRef = FIRDatabase.database().reference().child("UserMessages").child(fromId).child(toId)
            
            let messageId = childRef.key
            
        userMessagesRef.updateChildValues([messageId:1])
            
            let recipientUserMessagesRef = FIRDatabase.database().reference().child("UserMessages").child(toId).child(fromId)
            
            recipientUserMessagesRef.updateChildValues([messageId:1])
    }
}
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        dismissViewControllerAnimated(true, completion: nil)
    
    }
}