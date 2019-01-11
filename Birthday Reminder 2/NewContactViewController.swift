//
//  NewContactViewController.swift
//  Birthday Reminder 2
//
//  Created by Sanjana Pruthi on 1/24/18.
//  Copyright © 2018 Sanjana Pruthi. All rights reserved.
//

import UIKit
import os.log

class NewContactViewController: UIViewController {

    @IBOutlet weak var firstNameEditText: UITextField!
    
    @IBOutlet weak var lastNameEditText: UITextField!
    
    @IBOutlet weak var birthdayPicker: UIDatePicker!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBAction func cancelButton(_ sender: Any) {
        
        let isPresentingInAddContactMode = presentingViewController is UINavigationController
        if isPresentingInAddContactMode {
            dismiss(animated: true, completion: nil)
        }else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }else {
            fatalError("The MealViewController is not inside a navigation controller.")
        }
        
       // dismiss(animated: true, completion: nil)
    }
    
    
    var firstNameToReturn = ""
    var lastNameToReturn = ""
    var monthToReturn = ""
    var dateToReturn = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameEditText.text = "first"
        lastNameEditText.text = "last"
        // Do any additional setup after loading the view.
        
        if (firstNameToReturn != "") {
            self.title = "Edit Contact"
            
            firstNameEditText.text = firstNameToReturn
            lastNameEditText.text = lastNameToReturn
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat =  "MMMM d yyyy"
            var str = ""
            str = str + monthToReturn
            str = str + String(dateToReturn)
            str = str + " 2018"

            let date = dateFormatter.date(from: str)
            
            birthdayPicker.date = date!
            
            
        }
        
      

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation
     
     
     
     
     
     

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        //super.prepare(for: <#T##UIStoryboardSegue#>, sender: <#T##Any?#>)
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        firstNameToReturn = firstNameEditText.text!
        lastNameToReturn = lastNameEditText.text!
        let date = birthdayPicker.date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM "
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "dd"
        formatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        formatter2.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        let stringDate1 = formatter.string(from: date)
        let stringDate2 = formatter2.string(from: date)
        monthToReturn = stringDate1
        dateToReturn = Int(stringDate2)!
        
        
    }
    

}
