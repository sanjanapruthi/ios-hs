//
//  ViewController.swift
//  Shopping Calculator
//
//  Created by Sanjana Pruthi on 10/27/17.
//  Copyright © 2017 Sanjana Pruthi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var currentCategory = "Initial Amount"
    
    var initialAmountNum = "0"
    var taxAmount = "0"
    var saleAmount = "0"
    var budgetAmount = "0"
    var finalAmount = "0"
    var finalBudgetAmount = 0.0
    
    var currentlyTyping = false;
    
    @IBOutlet weak var initialAmountDisplay: UILabel!
    
    @IBOutlet weak var taxDisplay: UILabel!
    
    @IBOutlet weak var saleDisplay: UILabel!
    
    @IBOutlet weak var budgetDisplay: UILabel!
    
    @IBOutlet weak var budgetAmountDisplay: UILabel!
    
    @IBOutlet weak var finalAmountDisplay: UILabel!
    
    @IBOutlet weak var overUnderDisplay: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func NumberClicked(_ sender: UIButton) {
     
        if (currentCategory=="Initial Amount"){
            if (currentlyTyping){
                if ((initialAmountDisplay.text!.range(of:".") == nil)){//if no decimal, do whatever
                    initialAmountNum=initialAmountNum+sender.titleLabel!.text!
                }else if (sender.titleLabel!.text! != "."){//if there is a decimal, no more decimals
                    if (initialAmountNum.distance(from: initialAmountNum.startIndex, to:initialAmountNum.index(of: ".")!)+3>initialAmountNum.distance(from: initialAmountNum.startIndex, to:initialAmountNum.endIndex)){
                        initialAmountNum=initialAmountNum+sender.titleLabel!.text!
                    }//must be less than 2 decimal places
                }
            }else {
                initialAmountNum=sender.titleLabel!.text!
            }
            initialAmountDisplay.text="$"+initialAmountNum
        }else if (currentCategory=="Tax"){
            if (currentlyTyping){
                if ((taxDisplay.text!.range(of:".") == nil)||(sender.titleLabel!.text! != ".")){
                    taxAmount=taxAmount+sender.titleLabel!.text!
                }
            }else {
                taxAmount=sender.titleLabel!.text!
            }
            taxDisplay.text=taxAmount+"%"
        }else if (currentCategory=="Sale"){
            if (currentlyTyping){
                if ((saleDisplay.text!.range(of:".") == nil)||(sender.titleLabel!.text! != ".")){
                    saleAmount=saleAmount+sender.titleLabel!.text!
                }
            }else {
                saleAmount=sender.titleLabel!.text!
            }
            saleDisplay.text=saleAmount+"%"
        }else if (currentCategory=="Budget"){
            if (currentlyTyping){
                if ((budgetDisplay.text!.range(of:".") == nil)){//if no decimal, do whatever
                    budgetAmount=budgetAmount+sender.titleLabel!.text!
                }else if (sender.titleLabel!.text! != "."){//if there is a decimal, no more decimals
                    if (budgetAmount.distance(from: budgetAmount.startIndex, to:budgetAmount.index(of: ".")!)+3>budgetAmount.distance(from: budgetAmount.startIndex, to:budgetAmount.endIndex)){
                        budgetAmount=budgetAmount+sender.titleLabel!.text!
                    }//must be less than 2 decimal places
                }
            }else {
                budgetAmount=sender.titleLabel!.text!
            }
            budgetDisplay.text="$"+budgetAmount
        }
        
        if (sender.titleLabel!.text! != "0"){
            currentlyTyping = true
        }
        
        if (sender.titleLabel!.text != "."){
            
            finalAmount = String(format: "%.2f",(Double(initialAmountNum)!-((Double(saleAmount)!)/100)*Double(initialAmountNum)!)*(1+((Double(taxAmount)!)/100)))
            
            finalBudgetAmount = Double(budgetAmount)! - Double(finalAmount)!
            if (finalBudgetAmount<0){
                finalBudgetAmount = finalBudgetAmount * -1
                budgetAmountDisplay.text="$"+String(format: "%.2f",finalBudgetAmount)
                overUnderDisplay.text="over"
            }else{
                budgetAmountDisplay.text="$"+String(format: "%.2f",finalBudgetAmount)
                overUnderDisplay.text="under"
            }
            
            finalAmountDisplay.text="$"+finalAmount
            
        }
        
        
        
    }
    
    @IBAction func EnterCategory(_ sender: UIButton) {
        //print("pressed")
        currentlyTyping = false
        currentCategory = sender.currentTitle!
        if currentCategory == sender.currentTitle!{
            print(currentCategory)
        }
    }
    
    @IBAction func Reset(_ sender: UIButton) {
        currentCategory = "Initial Amount"
        budgetAmount="0"
        saleAmount="0"
        taxAmount="0"
        initialAmountNum="0"
        budgetDisplay.text="$"+budgetAmount
        saleDisplay.text=saleAmount+"%"
        taxDisplay.text=taxAmount+"%"
        initialAmountDisplay.text="$"+initialAmountNum
        currentlyTyping = false;
        finalAmountDisplay.text="$0"
        budgetAmountDisplay.text="$0"
    }
    


}

