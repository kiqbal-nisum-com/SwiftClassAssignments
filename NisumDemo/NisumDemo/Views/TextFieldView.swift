//
//  TextFieldView.swift
//  NisumDemo
//
//  Created by Khurram Iqbal on 19/07/2017.
//  Copyright © 2017 Nisum. All rights reserved.
//

import UIKit

let textFieldNotification = "TextFieldActive"
let DeleteButtonTextFieldNotification = "DeleteButtonNotification"
class TextFieldView: UIView {
    var rightSuperView : UIView!
    var clearButton : UIButton!
    var rightCursorView : UIView!
    weak var textField :CustomTextField!
    weak var label : UILabel!
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.label = self.viewWithTag(tag: 1)
        self.textField = self.viewWithTag(tag: 2)
        self.textField.delegate = self
        self.setViewState()
        self.setupRightView()
    }
    
}
extension TextFieldView{
    func  viewWithTag<T>(tag : Int) -> T{
        return self.viewWithTag(tag) as! T
    }
    
    func setViewState(){
        
        let color = (textField.text?.isEmpty)! ? UIColor.customGreyColor() : UIColor.customBlueColor()
        self.textField.setView(color: color.cgColor)
        self.label.textColor =  color
        self.textField.layer.removeAllAnimations()
        self.textField.rightView = nil
    }
    
    func setupRightView(){
        rightSuperView = UIView(frame: CGRect(x: 0, y: 0, width: 2, height: self.textField.frame.height))
        
        clearButton = UIButton(frame:  CGRect(x: 3, y: self.textField.frame.height/4, width: 15, height: 15))
        clearButton.addTarget(self, action: #selector(clear(sender:)), for: .touchUpInside)
        clearButton.setImage(UIImage(named:"ClearButton"), for: .normal)
        
        rightCursorView =  UIView(frame: CGRect(x: 0, y: 0, width: 2, height: self.textField.frame.height))
        rightCursorView.backgroundColor = UIColor.customBlueColor()
        rightSuperView.addSubview(rightCursorView)
    }
    
    func clear(sender : Any){
        self.textField.text = ""
        removeAddClearButton(add: false)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:DeleteButtonTextFieldNotification ), object: nil, userInfo: nil)
    }
    
    func removeAddClearButton(add : Bool){
        var frame = rightSuperView.frame
        if add{
            frame.size =  CGSize(width: frame.width + clearButton.frame.width, height: frame.height)
            rightSuperView.frame = frame
            rightSuperView.addSubview(clearButton)
        } else{
            clearButton.removeFromSuperview()
            frame.origin =  CGPoint(x: frame.origin.x - 7.5, y: frame.origin.y)
            frame.size =  CGSize(width: frame.width - clearButton.frame.width, height: frame.height)
            rightSuperView.frame = frame
        }
    }
}

extension TextFieldView : UITextFieldDelegate{

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: textFieldNotification), object: nil, userInfo: ["view":self])
        self.textField.rightViewMode = .unlessEditing
        self.textField.rightView = rightSuperView
        UIView.animate(withDuration: 0.8, delay: 0.4, options: [.curveEaseInOut,.repeat], animations: {
            self.rightCursorView.alpha = 0.0
        }, completion: { finished in
            
            self.rightCursorView.alpha = 1.0
        })
        self.textField.setView(color: UIColor.customBlueColor().cgColor)
        self.label.textColor =  UIColor.customBlueColor()
        return false
    }
    
}

extension UIColor {

    static func customBlueColor() -> UIColor{
        return  UIColor.blue
    }
    
    static func customGreyColor() -> UIColor {
        return UIColor.gray
    }
}

