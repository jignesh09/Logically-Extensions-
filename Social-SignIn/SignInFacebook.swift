//
//  SignInFacebook.swift
//  Sample
//
//  Created by Krishna on 21/12/17.
//  Copyright © 2017 Krishna. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit


class SignInVC: UIViewController
{
    
    @IBOutlet weak var btnFacebook: UIButton!
    
    
    // MARK: - view Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        btnFacebook.layer.cornerRadius = btnFacebook.frame.size.height/2
        btnFacebook.layer.masksToBounds = true
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    // MARK: - UDF
    func facebookLogin()
    {
        
        let facebookReadPermissions = ["public_profile","email", "user_birthday"]
        FBSDKLoginManager().logIn(withReadPermissions: facebookReadPermissions, from: self, handler: { (result, error) in
            if error != nil
            {
                FBSDKLoginManager().logOut()
            }
            else if result!.isCancelled
            {
                FBSDKLoginManager().logOut()
            }
            else
            {
                let param = ["fields": "id, first_name, last_name, email,picture.width(512),name"]
                let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: param)
                graphRequest!.start { _, result, error in
                    if error != nil
                    {
                        print(error.debugDescription)
                        return
                    }
                    let userData = result as? Dictionary<String, AnyObject>
                    _ = FBSDKAccessToken.current().tokenString
                    
                    let profileData = userData?["picture"] as? Dictionary<String, AnyObject>
                    print(profileData!)
                    
                    var profileImageURL : String = ""
                    var socialID : String = ""
                    var emailID : String = ""
                    var firstName : String = ""
                    var lastName : String = ""
                    var userName : String = ""
                    
                    profileImageURL = profileData?["data"]?["url"] as! String
                    socialID = userData?["id"] as! String
                    firstName = userData?["first_name"] as! String
                    lastName = userData?["last_name"] as! String
                    userName = userData?["name"] as! String
                    
                    
                }
            }
        })
        
        
        
    }
    
    
    // MARK: - Button Actions
    
    @IBAction func btnFacebookTap(_ sender: Any)
    {
        self.facebookLogin()
    }
    
    
    
    
    
    //MARK: - Hide StatusBar
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
