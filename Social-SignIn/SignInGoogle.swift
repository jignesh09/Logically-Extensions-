//
//  SignInGoogle.swift
//  Sample
//
//  Created by Krishna on 21/12/17.
//  Copyright © 2017 Krishna. All rights reserved.
//

import UIKit
import Google
import GoogleSignIn


class SignInVC: UIViewController,GIDSignInUIDelegate,GIDSignInDelegate
{
    
    @IBOutlet weak var btnGoogle: UIButton!
    
    
    // MARK: - view Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        
        btnGoogle.layer.cornerRadius = btnGoogle.frame.size.height/2
        btnGoogle.layer.masksToBounds = true
        

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    // MARK: - UDF
    func googleLogin()
    {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    // MARK: - Button Actions
    @IBAction func btnGoogleTap(_ sender: Any)
    {
        self.googleLogin()
    }
    
    
    
    
    // MARK: - Google SignIn Delegates
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        //        myActivityIndicator.stopAnimating()
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!)
    {
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!)
    {
        
        self.dismiss(animated: true, completion: nil)
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!)
    {
        if user != nil
        {
            print(user.profile.email)
            print(user.profile.imageURL(withDimension: 400))
            print(user.profile.givenName)
            print(user.profile.name)
            print(user.userID)
            
        }
        else
        {
            print(error.localizedDescription)
        }
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
