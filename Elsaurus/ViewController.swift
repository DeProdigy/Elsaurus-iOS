//
//  ViewController.swift
//  Elsaurus
//
//  Created by Alex Hint on 11/15/14.
//  Copyright (c) 2014 Alex Hint. All rights reserved.
//

import UIKit
import SystemConfiguration

public class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue()
        }
        
        var flags: SCNetworkReachabilityFlags = 0
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == 0 {
            return false
        }
        
        let isReachable = (flags & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection) ? true : false
    }
    
}

class ViewController: UIViewController, UITextFieldDelegate {
    
    let ipAddress = "http://192.168.1.94:3000/translation"
    //    let ipAddress = "https://elsaurus.herokuapp.com/translation"
    
    @IBOutlet weak var translatedText: UITextView!
    @IBOutlet weak var userInputTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userInputTextField.delegate = self
        view.tintColor = UIColor.whiteColor()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    
    @IBAction func translationSubmit(sender: UIButton) {
        translateTextFieldText()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        translateTextFieldText()
        return true
    }
    
    func showAlert() {
        let alert = UIAlertView()
        alert.title = "Yo!"
        alert.message = "Seems like you ain't got no internet..."
        alert.addButtonWithTitle("Thank you")
        alert.show()
    }
    
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
                    
                    // self.loginStatusLB.text=self.responseMsg
                    
                })
            }
            
        })
        
        // Hide the keyboard
        userInputTextField.resignFirstResponder()
        
        task.resume()
    }
    
    func translateTextFieldText() {

        if Reachability.isConnectedToNetwork() {
            
            callTransalteTextAPI()
            
        } else {
            
            showAlert()
            
        }

    }

}

