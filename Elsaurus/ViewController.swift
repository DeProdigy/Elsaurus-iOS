//
//  ViewController.swift
//  Elsaurus
//
//  Created by Alex Hint on 11/15/14.
//  Copyright (c) 2014 Alex Hint. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var translatedText: UITextView!
    @IBOutlet weak var userInputTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userInputTextField.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func translationSubmit(sender: UIButton) {
        translateTextFieldText()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        translateTextFieldText()
        return true
    }
    
    func translateTextFieldText() {
        
        //        "http://192.168.1.134:3000/translation"
        
        var request = NSMutableURLRequest(URL: NSURL(string: "https://elsaurus.herokuapp.com/translation")!)
        
        var session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "POST"
        
        
        var params = ["text":"\(userInputTextField.text)"] as Dictionary
        
        
        var err: NSError?
        
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            // json = {"response":"Success","msg":"User login successfully."}
           
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
                
                
                if json["response"] as NSString == "Success"
                    
                {
                    
                    println("Login Successfull")
                    
                }
                
                let responseMsg = json["translation"] as String
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.translatedText.text = responseMsg
                    
//                  self.loginStatusLB.text=self.responseMsg
                    
                })
                
                
                
            }
            
        })
        
        task.resume()

        
//        translatedText.text = userInputTextField.text
        
    }

}

