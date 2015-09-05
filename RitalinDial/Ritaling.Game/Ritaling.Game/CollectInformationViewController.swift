//
//  CollectInformationViewController.swift
//  Ritaling.Game
//
//  Created by Yair Levi on 5/2/15.
//  Copyright (c) 2015 ItayYairGuy. All rights reserved.
//

import UIKit
import Parse


class CollectingInformation: UIViewController {
    
    @IBOutlet weak var labelAgeValue: UILabel!
    @IBOutlet weak var textFieldFirstName: UITextField!
    @IBOutlet weak var textFieldLastName: UITextField!
    @IBOutlet weak var segmentTypeOfDisorder: UISegmentedControl!
    @IBOutlet weak var segmentGender: UISegmentedControl!
    @IBOutlet weak var sliderAge: UISlider!
    @IBOutlet weak var segmentTypeOfMedicine: UISegmentedControl!
    
    var userName = ""
    var firstShow = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func validateAndMoveToGameView(sender: AnyObject) {
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
    
    @IBAction func AgeChanged(sender: UISlider) {
        labelAgeValue.text = Int(sender.value).description;
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "MoveToGame"){
            var controller:GameViewController = segue.destinationViewController as! GameViewController
            createNewUser()
            controller.PlayerFirstName = textFieldFirstName.text
            controller.PlayerLastName = textFieldLastName.text
            controller.UserName = userName
        }
    }
    
    @IBAction func touchMainView(sender: AnyObject) {
        textFieldFirstName.resignFirstResponder()
        textFieldLastName.resignFirstResponder()
    }
    
    func validateUserNameAndPerformSegue(userName: String){
        var query = PFQuery(className:"Users")
        query.whereKey("UserName", equalTo:userName)
        self.view.userInteractionEnabled = false
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                if objects!.count > 0 {
                    let alert = UIAlertView(title: "User alerady exist", message: "Are you sure it's your first time?", delegate: self, cancelButtonTitle: "Ok")
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
    
    func createNewUser(){
        var parseObject = PFObject(className:"Users")
        parseObject["FirstName"] = textFieldFirstName.text
        parseObject["LastName"] = textFieldLastName.text
        parseObject["Age"] = Int(sliderAge.value)
        parseObject["UserName"] = userName
        parseObject["Condition"] = segmentTypeOfDisorder.titleForSegmentAtIndex(segmentTypeOfDisorder.selectedSegmentIndex)
        parseObject["Medicine"] = segmentTypeOfMedicine.titleForSegmentAtIndex(segmentTypeOfMedicine.selectedSegmentIndex)
        parseObject["IsMale"] = segmentGender.selectedSegmentIndex == 0
        
        parseObject.saveEventually()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // to handle if comming back from the scene game
        if firstShow == true{
            firstShow = false
        }else{
            self.navigationController?.popViewControllerAnimated(true);
        }
    }
    
}