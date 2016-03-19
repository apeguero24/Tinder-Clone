//
//  SignUpViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Andres Peguero on 12/2/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

import FBSDKCoreKit
import FBSDKLoginKit
import ParseFacebookUtilsV4


class SignUpViewController: UIViewController {

    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var interestedInMen: UISwitch!
    
    @IBAction func signUpButtonPressed(sender: AnyObject) {
        
        PFUser.currentUser()?["interestedInMen"] = interestedInMen.on
        
        do {
            try PFUser.currentUser()?.save()
        } catch {
            print("unable to save interestedInMen boolean")
        }
        
        self.performSegueWithIdentifier("goBackSignUp", sender: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
        
        let facebookGraph = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, name, gender, email"])
        
        facebookGraph.startWithCompletionHandler { (connection, result, error) -> Void in
            
            if error != nil {
                
                print(error)
            
            } else if let result = result {
            
                PFUser.currentUser()?["gender"] = result["gender"]
                PFUser.currentUser()?["name"] = result["name"]
                PFUser.currentUser()?["email"] = result["email"]
                
                do {
                  try   PFUser.currentUser()?.save()
                } catch {
                    print("unable to save data to Parse Users class")
                }
                
                let userId = result["id"] as! String
                
                print(userId)
                
                let facebookProfilePictureUrl = "https://graph.facebook.com/" + userId + "/picture?type=large"
                
                if let fbPicUrl = NSURL(string: facebookProfilePictureUrl) {
                    
                    if let data = NSData(contentsOfURL: fbPicUrl) {
                    
                        self.imageProfile.image = UIImage(data: data)
                        
                        let image: PFFile = PFFile(data: data)!
                        
                        PFUser.currentUser()?["image"] = image
                        
                        do {
                            try PFUser.currentUser()?.save()
                        } catch {
                            print("unable to save image to Parse")
                        }
                    
                    }
                
                
                }
                
            }
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
