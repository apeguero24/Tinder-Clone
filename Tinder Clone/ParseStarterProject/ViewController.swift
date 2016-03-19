/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

import FBSDKCoreKit
import FBSDKLoginKit
import ParseFacebookUtilsV4

class ViewController: UIViewController {

    @IBAction func login(sender: AnyObject) {
        
        let permissions = ["public_profile", "email"]

        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) { (user, error) -> Void in
            
            if user != nil {
                
                if user!["interestedInMen"] != nil {
                    
                     self.performSegueWithIdentifier("showLogInScreen", sender: self)
                    
                } else {
                
                     self.performSegueWithIdentifier("showSignInScreen", sender: self)
                    
                }
                
            } else {
                
                print("Uh oh. The user cancelled the Facebook login.")
                
            }

        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser()?.username != nil {
            
            if PFUser.currentUser()?["interestedInMen"] != nil {
                
                performSegueWithIdentifier("showLogInScreen", sender: self)
            
            } else {
                
                performSegueWithIdentifier("showSignInScreen", sender: self)
            
            }
        
        
        } 
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
