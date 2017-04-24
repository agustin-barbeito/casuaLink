//
//  LoginController.swift
//  casuaLink
//
//  Created by Agustin Barbeito on 2/23/17.
//  Copyright © 2017 Agustin Barbeito. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class LoginController: UIViewController {
    
    let logoutController = LogoutTableViewController()
   
    @IBOutlet weak var loginBtn: UIButton!
    
    
    @IBAction func login(sender: UIButton)
    
    {
      
        guard let email = loginEmailField.text, password = loginPasswordField.text else {
            
            return
        }
        
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
            
            if error != nil {
                
                print(error)
                
                return
            }
            
        self.navigationController?.pushViewController(self.logoutController, animated: true)
            
        })
    }
    
    @IBOutlet weak var loginEmailField: UITextField!
    
    @IBOutlet weak var loginPasswordField: UITextField!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func register(sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 1 {
        
            let registerController = RegisterController()
            
            self.navigationController?.pushViewController(registerController, animated: false)
        
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
        
        self.loginBtn.layer.cornerRadius = 8
}
}