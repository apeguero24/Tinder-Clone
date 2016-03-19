//
//  SwipingViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Andres Peguero on 12/4/15.
//  Copyright © 2015 Parse. All rights reserved.
//


import UIKit
import Parse

import FBSDKCoreKit
import FBSDKLoginKit
import ParseFacebookUtilsV4

class SwipingViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var result: UILabel!
    
    var displayUserId = ""
    
    func wasDragged(gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translationInView(self.view)
        
        let label = gesture.view!
        label.center = CGPoint(x: self.view.bounds.width/2 + translation.x, y: self.view.bounds.height/2 + translation.y)
        
        let xFromCenter = label.center.x - self.view.bounds.width/2
        
        let scale = min(100/abs(xFromCenter),1)
        
        var rotation = CGAffineTransformMakeRotation(xFromCenter/200)
        
        var stretch = CGAffineTransformScale(rotation, scale, scale)
        
        label.transform = stretch
        
        if gesture.state == UIGestureRecognizerState.Ended {
            
            var rejectedOrAccepted = ""
            
            if label.center.x < 100 {
                
                rejectedOrAccepted = "rejected"
                
            } else if label.center.x > self.view.bounds.width - 100 {
                
                rejectedOrAccepted = "accepted"
                
            }
            
            if rejectedOrAccepted != "" {
                
                PFUser.currentUser()?.addUniqueObjectsFromArray([displayUserId], forKey: rejectedOrAccepted)
                
                
                do {
                    try PFUser.currentUser()?.save()
                } catch {
                    
                    print("unable to save reject or accepted user")
                
                }
            
            
            }
            
            rotation = CGAffineTransformMakeRotation(0)
            
            stretch = CGAffineTransformScale(rotation, 1, 1)
            
            label.transform = stretch
            
            label.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
            
            updateUsers()
            
            
        }
        
    }

    
    func updateUsers() {
    
        let query = PFUser.query()
        
        
        if let latitude = PFUser.currentUser()?["location"]?.latitude {
            
            if let longitude = PFUser.currentUser()?["location"]?.longitude {
            
                query?.whereKey("location", withinGeoBoxFromSouthwest: PFGeoPoint(latitude: latitude - 1, longitude: longitude - 1), toNortheast: PFGeoPoint(latitude: latitude + 1, longitude: longitude + 1))
                
            }
        
        
        }
        
        
        var interestedIn = "male"
        
        if PFUser.currentUser()!["interestedInMen"]! as! Bool == false {
            
            interestedIn = "female"
            
        }
        
        var isMale = false
        
        if PFUser.currentUser()!["gender"]! as! String == "male" {
            
            isMale = true
            
        }
        
        query?.whereKey("interestedInMen", equalTo: isMale)
        query?.whereKey("gender", equalTo: interestedIn)
        
        var ignoredUsers = [""]
        
        if let rejected = PFUser.currentUser()?["rejected"] {
            
            ignoredUsers += rejected as! Array
        
        }
        
        if let accepted = PFUser.currentUser()?["accepted"] {
        
            ignoredUsers += accepted as! Array
        
        }
        
        print(ignoredUsers)
        
        query?.whereKey("objectId", notContainedIn: ignoredUsers)
 
        query?.limit = 1
        
        query?.findObjectsInBackgroundWithBlock({ (object, error) -> Void in
            
            if error != nil {
                
                print(error)
                
            } else  {
                
                if object?.count > 0 {
                
                    for user in object! {
                        
                        self.displayUserId = user.objectId!
                        
                        let imageFile = user["image"] as! PFFile
                        
                        imageFile.getDataInBackgroundWithBlock {
                            (imageData: NSData?, error: NSError?) -> Void in
                            
                            if error != nil {
                                
                                print(error)
                                
                                
                            } else {
                                
                                if let data = imageData {
                                    
                                    self.userImage.image = UIImage(data: data)
                                    
                                }
                                
                                
                            }
                            
                            
                        }
                        
                        
                    }
                }
            
            }
            
            
        })
    
    
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint, error) -> Void in
            
            if geoPoint != nil {
                
                PFUser.currentUser()?["location"] = geoPoint
                
                do {
                    
                    try PFUser.currentUser()?.save()
                    
                } catch {}
            
            }
            
        }
        
        
        let gesture = UIPanGestureRecognizer(target: self, action: "wasDragged:")
        userImage.addGestureRecognizer(gesture)
        
        userImage.userInteractionEnabled = true
        
        updateUsers()

        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "logOut" {
           
            PFUser.logOut()
        
        
        }
    }


}
