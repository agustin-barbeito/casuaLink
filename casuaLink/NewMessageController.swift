//
//  NewMessageController.swift
//  casuaLink
//
//  Created by Agustin Barbeito on 3/7/17.
//  Copyright © 2017 Agustin Barbeito. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class NewMessageController: UIViewController, UITableViewDelegate, UITableViewDataSource

{
    
    let cellId = "cellId"
    
    var users = [User]()
    
    var logoutTableViewController: LogoutTableViewController?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(cancel))
        
    tableView.registerClass(userCell.self, forCellReuseIdentifier: cellId)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchUser()
    }
    
    func cancel(){
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! userCell
       
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        if let profileImgUrl = user.profileImgUrl {
            
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImgUrl)
            
        }
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        dismissViewControllerAnimated(true) {
            
            let user = self.users[indexPath.row]
           
            self.logoutTableViewController?.showChatControllerForUser(user)
        }
}
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 72
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return users.count
    }
    
    func fetchUser() {
        
        FIRDatabase.database().reference().child("Users").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]
            {
                
                let user = User()
                
                user.id = snapshot.key
                
                user.name = dictionary["name"] as? String
                
                user.email = dictionary["email"] as? String
                
                self.users.append(user)
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                self.tableView.reloadData()})
            }
            
            }, withCancelBlock: nil)
    }
}