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
        translatedText.hidden = false
        translatedText.text = userInputTextField.text
        
        
    }

}

