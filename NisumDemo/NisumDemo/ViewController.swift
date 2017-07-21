//
//  ViewController.swift
//  NisumDemo
//
//  Created by Khurram Iqbal on 18/07/2017.
//  Copyright © 2017 Nisum. All rights reserved.
//

import UIKit
enum containerHiddenType : Int{
    case ContainerView2 = 0
    case ContainerView1 = 1
}

enum toggleButtonType : Int{
    case PreviousTextField = 0
    case NextTextField = 1
}
enum DenominationValueType : String {
    case C = "1c"
    case FIVE_C = "5c"
    case TEN_C  = "10c"
    case TWETYFIVE_C = "25c"
    case FIFTY_C = "50c"
    case HUNDRED_C = "$1 COIN"
    case PENNIES = "PENNIES"
    case NICKEL  = "NICKELS"
    case DIMES = "DIMES"
    case QUARTERS  = "QUARTERS"
    case Dollar1 = "$1"
    case Dollar2 = "$2"
    case Dollar5 = "$5"
    case Dollar10 = "$10"
    case Dollar20 = "$20"
    case Dollar50 = "$50"
    case Dollar100 = "$100"
    case ACTUAL_AMOUNT = "ACTUAL AMOUNT"
}

extension Double{
    var C:Double {return self/100}
    var FIVE_C : Double {return self * 5/100}
    var TEN_C : Double {return self * 10/100}
    var TWETYFIVE_C:Double{return self * 25/100}
    var FIFTY_C:Double{return self * 50/100}
    var HUNDRED_C:Double{return self}
    var PENNIES:Double{return self *  50/100}
    var NICKEL : Double{ return self * 2}
    var DIMES : Double{return self * 5}
    var QUARTERS : Double{return self * 10}
    var Dollar1:Double{return self}
    var Dollar2:Double{return self * 2}
    var Dollar5:Double{return self * 5}
    var Dollar10:Double{return self * 10}
    var Dollar20:Double{return self * 20}
    var Dollar50:Double{return self * 50}
    var Dollar100:Double{return self * 100}
    var ACTUAL_AMOUNT:Double{return self}
}

class ViewController: UIViewController {
    weak var selectedTextfield : UITextField?
    @IBOutlet weak var KeyboardViewHeight: NSLayoutConstraint!
    @IBOutlet weak var textfield:UITextField!
    @IBOutlet weak var customKeyboard:UIView!
    @IBOutlet weak var containerViewA: UIView!
    @IBOutlet weak var containerViewB: UIView!
    @IBOutlet weak var nextTextField: UIButton!
    @IBOutlet weak var reconcileBtn: UIButton!
    @IBOutlet weak var previousTextField: UIButton!
    var customTextFieldViews : [TextFieldView] = [TextFieldView]()
    var selectedTextfieldView : TextFieldView!
    var totalValue : Double = 0.00
    @IBOutlet weak var actualDeposited: UILabel!
    @IBOutlet weak var varianceLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
    }
    
    func setup(){
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:textFieldNotification), object: nil, queue: nil, using:txtFieldActiveNotification )
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:DeleteButtonTextFieldNotification), object: nil, queue: nil, using:reCalculateDenominationValue(notification:) )
        
        customTextFieldViews = containerViewB.viewWithTag(100)?.subviews.filter{$0 is TextFieldView} as! [TextFieldView]
        
    }

    @IBAction func numberPressed(_ sender: UIButton) {
        if selectedTextfieldView != nil{
            if !containerViewB.isHidden{
                selectedTextfieldView.textField.text = selectedTextfieldView.textField.text! + (sender.titleLabel?.text)!
                var newValue : Double  = Double((selectedTextfieldView.textField.text?.replacingOccurrences(of: "$", with: ""))!)!
                if selectedTextfieldView.textField.text?.characters.count == 1{
                    newValue = newValue / 100
                } else {
                    newValue = newValue * 10
                }
                if selectedTextfieldView.textField.text?.characters.count == 1{
                    selectedTextfieldView.removeAddClearButton(add: true)
                }
                selectedTextfieldView.textField.text = "$\(newValue)"
            } else{
                selectedTextfieldView.textField.text = selectedTextfieldView.textField.text! + (sender.titleLabel?.text)!
                if selectedTextfieldView.textField.text?.characters.count == 1{
                    selectedTextfieldView.removeAddClearButton(add: true)
                }
            }
           calculateDenominationValue()
        }
    }
    
    @IBAction func keyboardToggleButton(_ sender: UIButton) {
        selectedTextfieldView.setViewState()
        if sender.tag == toggleButtonType.PreviousTextField.rawValue{
            selectedTextfieldView = customTextFieldViews[customTextFieldViews.index(of: selectedTextfieldView)! - 1]
        } else{
            selectedTextfieldView = customTextFieldViews[customTextFieldViews.index(of: selectedTextfieldView)! + 1]
        }
        activeDeactiveToggleButtons()
        selectedTextfieldView.textField.becomeFirstResponder()

    }
    
    @IBAction func segmentControlValueChange(sender : UISegmentedControl){
   
        for item in customTextFieldViews{
            item.textField.text = ""
        }
        actualDeposited.text = "0.0"
        varianceLabel.text = "-0.4"
        if selectedTextfieldView != nil {
            selectedTextfieldView.setViewState()
        }
        let hiddenContainerTag = (sender.selectedSegmentIndex == containerHiddenType.ContainerView2.rawValue) ? false : true
        containerViewB.isHidden = hiddenContainerTag
        containerViewA.isHidden = !hiddenContainerTag
        customTextFieldViews = (!hiddenContainerTag) ?    containerViewB.viewWithTag(100)?.subviews.filter { $0 is TextFieldView   }as! [TextFieldView] :
            containerViewA.viewWithTag(200)?.subviews.filter { $0 is TextFieldView} as! [TextFieldView]
        
        customTextFieldViews = customTextFieldViews.sorted{$0.tag < $1.tag}
        
    }
    @IBAction func Done(sender : UIButton){
        UIView.animate(withDuration: 0.5) { 
            self.KeyboardViewHeight.constant = self.reconcileBtn.frame.height
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func DeletePress(sender : UIButton){
        if !(selectedTextfieldView.textField.text?.replacingOccurrences(of: "$", with: "").isEmpty)! && selectedTextfieldView != nil {
            
            if !containerViewB.isHidden{
                let newValue : Double = Double((selectedTextfieldView.textField.text?.replacingOccurrences(of: "$", with: ""))!)!
                if newValue < 0{
                    let newValuetext = String(newValue)
                    let endIndex = newValuetext.index((newValuetext.endIndex), offsetBy: -1)
                    selectedTextfieldView.textField.text = "$" + newValuetext.substring(to:endIndex)
                } else{
                    selectedTextfieldView.textField.text = "$\(newValue/10)"
                }
            
            }
            let text = selectedTextfieldView.textField.text
            let endIndex = text?.index((text?.endIndex)!, offsetBy: -1)
            selectedTextfieldView.textField.text =  selectedTextfieldView.textField.text?.substring(to: endIndex!)
            if (selectedTextfieldView.textField.text?.isEmpty)!{
                selectedTextfieldView.removeAddClearButton(add: false)
            }
        }
        calculateDenominationValue()
    }
    
    func txtFieldActiveNotification(notification : Notification) -> Void{
        if selectedTextfieldView != nil{
            selectedTextfieldView.setViewState()
        }
        selectedTextfieldView = notification.userInfo?["view"] as! TextFieldView
        activeDeactiveToggleButtons()
    
    }
    func reCalculateDenominationValue(notification : Notification) -> Void{
        calculateDenominationValue()
    }
    
    func calculateDenominationValue(){
        totalValue = 0
        for textfieldView in customTextFieldViews {
            totalDenominationValue(textFieldView: textfieldView)
        }
        actualDeposited.text = String(totalValue)
        varianceLabel.text = String(totalValue - 0.40)
    }
    
    func totalDenominationValue(textFieldView : TextFieldView){
        if  textFieldView.textField.text == "" {
             return
        }
        let denom = DenominationValueType(rawValue: textFieldView.label.text!)!

        switch denom {
            case .C : totalValue += Double(textFieldView.textField.text!)!.C
            case .FIVE_C : totalValue += Double(textFieldView.textField.text!)!.FIVE_C
            case .TEN_C : totalValue += Double(textFieldView.textField.text!)!.TEN_C
            case .TWETYFIVE_C : totalValue += Double(textFieldView.textField.text!)!.TWETYFIVE_C
            case .FIFTY_C : totalValue += Double(textFieldView.textField.text!)!.FIFTY_C
            case .HUNDRED_C : totalValue += Double(textFieldView.textField.text!)!.HUNDRED_C
            case .PENNIES : totalValue += Double(textFieldView.textField.text!)!.PENNIES
            case .NICKEL : totalValue += Double(textFieldView.textField.text!)!.NICKEL
            case .DIMES: totalValue += Double(textFieldView.textField.text!)!.DIMES
            case .QUARTERS: totalValue += Double(textFieldView.textField.text!)!.QUARTERS
            case .Dollar1: totalValue += Double(textFieldView.textField.text!)!.Dollar1
            case .Dollar2: totalValue += Double(textFieldView.textField.text!)!.Dollar2
            case .Dollar5: totalValue += Double(textFieldView.textField.text!)!.Dollar5
            case .Dollar10: totalValue += Double(textFieldView.textField.text!)!.Dollar10
            case .Dollar20: totalValue += Double(textFieldView.textField.text!)!.Dollar20
            case .Dollar50: totalValue += Double(textFieldView.textField.text!)!.Dollar50
            case .Dollar100: totalValue += Double(textFieldView.textField.text!)!.Dollar100
            case .ACTUAL_AMOUNT: totalValue += Double(textFieldView.textField.text!.replacingOccurrences(of: "$", with: ""))!.ACTUAL_AMOUNT;
        }
    }
    
    func activeDeactiveToggleButtons(){
    
        
        if selectedTextfieldView == nil || ( selectedTextfieldView == customTextFieldViews.first && selectedTextfieldView == customTextFieldViews.last) {
            self.nextTextField.isEnabled = false
            self.previousTextField.isEnabled = false
        } else if selectedTextfieldView == customTextFieldViews.first{
            self.nextTextField.isEnabled = true
            self.previousTextField.isEnabled = false
        } else if selectedTextfieldView == customTextFieldViews.last{
            self.nextTextField.isEnabled = false
            self.previousTextField.isEnabled = true
        } else{
            self.nextTextField.isEnabled = true
            self.previousTextField.isEnabled = true
        }
    
    }
}


