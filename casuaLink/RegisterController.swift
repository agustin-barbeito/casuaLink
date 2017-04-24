//
//  RegisterController.swift
//  casuaLink
//
//  Created by Agustin Barbeito on 2/20/17.
//  Copyright © 2017 Agustin Barbeito. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class RegisterController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate

{
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func loginTapped(sender: AnyObject) {
        
        if sender.selectedSegmentIndex == 0 {
            
            let loginController = LoginController()
            
            self.navigationController?.pushViewController(loginController, animated: false)
        }
    }
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var registerButton: UIButton!
    
    @IBAction func register(sender: AnyObject) {
        
        guard let email = emailField.text, password = passwordField.text, name = nameField.text else {
            
            return
        }
        
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
            
            if error != nil {
                
                print(error)
                
                return
            }
            
            guard let uid = user?.uid else
            
            {
                return
            }
            
            let imageName = NSUUID().UUIDString
            
            let storageRef = FIRStorage.storage().reference().child("Profile_images").child("\(imageName).png")
            
            if let pictureData = UIImagePNGRepresentation(self.imageView.image!) {
            
            storageRef.putData(pictureData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    
                    print(error)
                    
                    return
                }
                
            if let profileImgUrl = metadata?.downloadURL()?.absoluteString
                
            {
                
                let values = ["name": name, "email": email, "password": password, "profileImgUrl": profileImgUrl]
                
                self.registerUserToDbWithUID(uid, values: values)
                
                }
            })
                
            }
        })
        
    }
    
    private func registerUserToDbWithUID (uid: String, values: [String: AnyObject]) {
        
        let ref = FIRDatabase.database().reference()
        
        let usersRef = ref.child("Users").child(uid)
        
        usersRef.updateChildValues(values, withCompletionBlock: {
            (error, ref) in
            
            if error != nil {
                
                print(error)
                
                return
            }
            
            let logoutTableViewController = LogoutTableViewController()
          
            self.navigationController?.pushViewController(logoutTableViewController, animated: true)
            
        })
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
        
        self.registerButton.layer.cornerRadius = 8
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectProfileImage))
        
        imageView.userInteractionEnabled = true
        
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    func selectProfileImage() {
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        presentViewController(imagePicker, animated: true, completion: nil)
        }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        self.imageView.image = image
        
        self.imageView.layer.cornerRadius = 50
      
       self.imageView.clipsToBounds = true
        
        dismissViewControllerAnimated(true, completion:nil)
    }
}
