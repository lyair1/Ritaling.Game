//
//  SignInViewController.swift
//  Ritaling.Game
//
//  Created by Yair Levi on 5/22/15.
//  Copyright (c) 2015 ItayYairGuy. All rights reserved.
//

import UIKit
import SpriteKit
import Parse

class SignInViewController : UIViewController {
    @IBOutlet weak var textFieldFirstName: UITextField!
    @IBOutlet weak var textFieldLastName: UITextField!
    
    var userName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "MoveToGame"){
            var controller:GameViewController = segue.destinationViewController as! GameViewController
            controller.PlayerFirstName = textFieldFirstName.text
            controller.PlayerLastName = textFieldLastName.text
            controller.UserName = userName
        }
    }
    
    @IBAction func validateUserExistAndSegueToGame(sender: AnyObject) {
        if textFieldFirstName.text.isEmpty {
            let alert = UIAlertView(title: "Information Missing", message: "Pleas fill out your first name.", delegate: self, cancelButtonTitle: "Ok")
            alert.show()
            textFieldFirstName.becomeFirstResponder()
            
            return
        }
        
        if textFieldLastName.text.isEmpty {
            let alert = UIAlertView(title: "Information Missing", message: "Pleas fill out your last name.", delegate: self, cancelButtonTitle: "Ok")
            alert.show()
            textFieldLastName.becomeFirstResponder()
            
            return
        }

        userName = textFieldFirstName.text.lowercaseString + "_" + textFieldLastName.text.lowercaseString
        
        validateUserNameAndPerformSegue(userName)
    }
    
    func validateUserNameAndPerformSegue(userName: String){
        var query = PFQuery(className:"Users")
        query.whereKey("UserName", equalTo:userName)
        
        self.view.userInteractionEnabled = false
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                if objects!.count == 0 {
                    let alert = UIAlertView(title: "User not exist", message: "Are you sure it's not your first time?", delegate: self, cancelButtonTitle: "Ok")
                    alert.show()
                }else{
                    self.performSegueWithIdentifier("MoveToGame", sender: nil)
                }
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
            self.view.userInteractionEnabled = true
        }
    }
    
    @IBAction func viewTouched(sender: AnyObject) {
        textFieldLastName.resignFirstResponder()
        textFieldFirstName.resignFirstResponder()
    }
}
