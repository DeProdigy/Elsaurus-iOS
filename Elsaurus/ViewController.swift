//
//  ViewController.swift
//  Elsaurus
//
//  Created by Alex Hint on 11/15/14.
//  Copyright (c) 2014 Alex Hint. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: 
    //MARK: Properties
    //let ipAddress = "http://192.168.1.94:3000/translation"
    let ipAddress = "https://elsaurus.herokuapp.com/translation"
    
    @IBOutlet weak var translatedText: UITextView!
    @IBOutlet weak var userInputTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    //MARK:
    //MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userInputTextField.delegate = self
        view.tintColor = UIColor.whiteColor()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "didTap:")
        view.addGestureRecognizer(tapGesture)
    }
    
    //MARK:
    //MARK: IBAction
    @IBAction func translationSubmit(sender: UIButton) {
        translateTextFieldText()
    }
    
    //MARK:
    //MARK: Helper Methods
    func translateTextFieldText() {
        if Reachability.isConnectedToNetwork() {
            callTransalteTextAPI()
        } else {
            showAlert()
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func didTap(recognizer:UITapGestureRecognizer) {
        if userInputTextField.isFirstResponder() {
            userInputTextField.resignFirstResponder()
        }
    }

    
    func showAlert() {
        let alert = UIAlertView()
        alert.title = "Yo!"
        alert.message = "Seems like you ain't got no internet..."
        alert.addButtonWithTitle("Thank you")
        alert.show()
    }
    
  
    
    //MARK:
    //MARK: Networking
    
    func callTransalteTextAPI() {
        var request = NSMutableURLRequest(URL: NSURL(string: ipAddress)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        var params = ["text":"\(userInputTextField.text)"] as Dictionary
        var err: NSError?
        
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if(err != nil) {
                println(err!.localizedDescription)
            } else {
                println("Response: \(response)")
                var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Body: \(strData)\n\n")
                var err: NSError?
                var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as NSDictionary
                var success = json["response"] as? String
                println("Succes: \(success)")
                
                if json["response"] as NSString == "Success" {
                    println("Login Successfull")
                }
                
                let responseMsg = json["translation"] as String
                dispatch_async(dispatch_get_main_queue(), {
                    self.translatedText.text = responseMsg
                })
            }
        })
        // Hide the keyboard
        userInputTextField.resignFirstResponder()
        task.resume()
    }
}


//MARK:
//MARK: UITextFieldDelegate Methods
extension ViewController: UITextFieldDelegate {
    
    func changeButtonToRandom() {
        submitButton.setTitle("Random Quote", forState: .Normal)
    }
    
    func changeButtonToTranslate() {
        submitButton.setTitle("Elify", forState: .Normal)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    
        // Don't let the user put in space as first chacter
        if string == " " && range.location == 0 {
            // Keep button at "Random" mode/
            changeButtonToRandom()
            return false
        }
        
        // When the user backspaces to an empty textfield
        if (textField.text as NSString).length ==  1 && string == "" {
            // Keep button at "Random" mode
            changeButtonToRandom()
        } else {
            changeButtonToTranslate()
        }
        
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        changeButtonToRandom()
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        translateTextFieldText()
        return true
    }
    
}
