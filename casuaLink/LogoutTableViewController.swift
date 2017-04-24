//
//  LogoutTableViewController.swift
//  casuaLink
//
//  Created by Agustin Barbeito on 3/2/17.
//  Copyright © 2017 Agustin Barbeito. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class LogoutTableViewController: UITableViewController {
    
    let cellId = "cellId"
    
    var messages = [Message]()
    
    var messagesDictionary = [String: Message]()
    
    var timer: NSTimer?
    
    
    @IBOutlet weak var logoutBtn: UIBarButtonItem!
    
    @IBAction func logoutBtnTapped() {
        
        do {
            
            try FIRAuth.auth()?.signOut()
        
        } catch let logoutError {
            
            print(logoutError)
        }
        
        let loginController = LoginController()
       
        self.navigationController?.pushViewController(loginController, animated: true)
    }
    
    
    @IBOutlet weak var composeBtn: UIBarButtonItem!
    
    @IBAction func compose(sender: AnyObject)
    
    {
        
        let newMessageController = NewMessageController()
        
        newMessageController.logoutTableViewController = self
        
        let navigationController = UINavigationController(rootViewController: newMessageController)
        
        presentViewController(navigationController, animated: true, completion: nil)
    
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    self.tableView.registerClass(userCell.self, forCellReuseIdentifier: cellId)
        
        checkIfUserIsLoggedIn()
        observeUserMessages()
}
    
    func checkIfUserIsLoggedIn() {
        
        if FIRAuth.auth()?.currentUser?.uid == nil
            
        {
            
            logoutBtnTapped()
            
        } else {
            
            let uid = FIRAuth.auth()?.currentUser?.uid
            
            FIRDatabase.database().reference().child("Users").child(uid!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String : AnyObject] {
                    
                    self.navigationItem.title = dictionary["name"] as? String
                }
                
                }, withCancelBlock: nil)
        }
    }
    
    func observeUserMessages(){
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid
            
            else {
                
                return
        }
        
        let ref = FIRDatabase.database().reference().child("UserMessages").child(uid)
        
        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            let userId = snapshot.key
            FIRDatabase.database().reference().child("UserMessages").child(uid).child(userId).observeEventType(.ChildAdded, withBlock: { (snapshot) in
                
                let messageId = snapshot.key
                
                self.fetchMessageWithMessageId(messageId)
                
                }, withCancelBlock: nil)
            
        })
        
    }
    
    private func fetchMessageWithMessageId(messageId: String){
        
        let messagesReference = FIRDatabase.database().reference().child("Messages").child(messageId)
        
        messagesReference.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]
            {
                
                let message = Message(dictionary: dictionary)
                
                if let chatPartnerId = message.chatPartnerId() {
                    
                    self.messagesDictionary[chatPartnerId] = message
                }
                
                self.attemptReloadOfTable()
            }
            
            }, withCancelBlock: nil)
        
    }
    
    private func attemptReloadOfTable(){
        
        self.timer?.invalidate()
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.reloadTable), userInfo: nil, repeats: false)
        
    }
    
    func reloadTable(){
        
        self.messages = Array(self.messagesDictionary.values)
        
        self.messages.sortInPlace({ (message1, message2) -> Bool in
            
            return message1.timestamp?.intValue > message2.timestamp?.intValue
            
        })
        
        dispatch_async(dispatch_get_main_queue(), {
            
            self.tableView.reloadData()
            
        })
        
    }
    
     override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(logoutBtnTapped))
        
        let rightBarButtonImage = UIImage(named: "write.png")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: rightBarButtonImage, style: .Plain, target: self, action: #selector(compose))
                
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! userCell
        
        let message = messages[indexPath.row]
        
        cell.message = message
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 72
}
    
   override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    let message = self.messages[indexPath.row]
    
    guard let chatPartnerId = message.chatPartnerId() else {
        
        return
    }
    
    let ref = FIRDatabase.database().reference().child("Users").child(chatPartnerId)
    
    ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
        
        guard let dictionary = snapshot.value as? [String: AnyObject] else {
            
            return
        }
        
        let user = User()
        
        user.id = chatPartnerId
        
    user.setValuesForKeysWithDictionary(dictionary)
        
        self.showChatControllerForUser(user)
        
        }, withCancelBlock: nil)
}
    
    func showChatControllerForUser(user: User){
     
        let chatController = ChatController()
        
        chatController.user = user
        
        navigationController?.pushViewController(chatController, animated: true)
        }
    
}