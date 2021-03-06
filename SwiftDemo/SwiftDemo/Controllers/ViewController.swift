//
//  ViewController.swift
//  SwiftDemo
//
//  Created by Khurram Iqbal on 13/06/2017.
//  Copyright © 2017 Nisum. All rights reserved.
//

import UIKit
import CoreData

//MARK: - Enums
enum EntityType : String {
    case Item = "Item"
    case Bin = "Bin"
    case Location = "Location"

}


enum ButtonTag : Int{

    case AddBin = 1
    case AddLocation = 2
}

enum EmptyFieldError : String{
    case EmtpyFieldTitle = "Empty Field"
    case BinFieldEmpty = "Bin Cannot be Empty"
    case LocationFieldEmpty = "Location Cannot be Empty"
    case ItemFieldEmpty = "Item Cannot be Empty"
}

class ViewController: UIViewController,ViewControllerProtocol {
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var binText: UITextField!
    @IBOutlet weak var itemText: UITextField!
    @IBOutlet weak var qtyText: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    var name : String?
    var pickerData : [EntityBaseModel]?
    var selectedLoc : LocationModel?
    var selectedBin : BinModel?

    var binLocModel : BinLocModel?

    override func viewDidLoad() {
       
        super.viewDidLoad()
        binLocModel = BinLocModel()
        binLocModel?.getAllEntityBaseModel()
        
        self.title = "Bin View"
        NetworkOperations.sharedInstance.getAllData(dataType: AppConstant.allData,completionHandler:  {[unowned self] (responseDict, success) in
            self.binLocModel!.getAllEntityBaseModel()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    @IBAction func save(_ sender: UIButton) {
        

        let context = CoreDataManager.shared.viewContext
        if binText!.text!.isEmpty{
            self.showErrorAlert(title: " Empty Field", message: EmptyFieldError.BinFieldEmpty.rawValue)
            return
        } else if (itemText.text?.isEmpty)!{
            self.showErrorAlert(title: " Empty Field", message: EmptyFieldError.ItemFieldEmpty.rawValue)
            return
        }
        
        let itemModel : ItemModel = self.getCoreDataManagerObject().newManagedObject(entityName: CoreDataModelName.ItemModel.rawValue,context: context)!
        itemModel.setObjectProperties(jsonDict:  [
            "name":self.itemText.text!,
            "id": itemModel.getObjectId(entityName: CoreDataModelName.ItemModel.rawValue, context: context),
            "binId":selectedBin!.id,
            "quantity" : Int16(self.qtyText.text!)!
            ], entityType: EntityType.Item.rawValue, context: context)
        if getCoreDataManagerObject().saveViewContext(){
            itemText.text = ""
        }
    }
 
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {
        let vc = segue.source as! SearchViewController
        self.itemText.text = vc.selectedItem?.name
        self.binText.text = vc.selectedItem?.iItemToBin?.name
        self.locationText.text = vc.selectedItem?.iItemToBin?.binToLocation?.name
        self.qtyText.text = String(describing: (vc.selectedItem!.qty))
    }
    
    @IBAction func changeSegue(sender: UIButton){
        self.pickerView.isHidden = true
        self.binLocModel?.modelType = (sender.tag == ButtonTag.AddBin.rawValue) ? .Bin : .Location
        self.showAlertController(entityType: (self.binLocModel?.modelType)!,sender:sender )
    
    }
    
    @IBAction func searchBtnClick(sender : UIButton){
        self.performSegue(withIdentifier:AppConstant.searchViewControllerSegueIdentifier , sender: self)
    }
}
//MARK: - PickerViewDelegate
extension ViewController : UIPickerViewDelegate , UIPickerViewDataSource{
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (pickerData == nil) ? 0 : (pickerData?.count)!
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerData![row].name
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if self.pickerData == nil {
            return
        }
        if let item = pickerData![row] as? LocationModel{
            selectedLoc = item
        } else{
            selectedBin = pickerData![row] as? BinModel
        }
        self.setTitle(name: (self.pickerData![row].name)!)
        self.pickerView.isHidden = true
    }
    
}

//MARK: - TextViewDelegate
extension ViewController : UITextFieldDelegate{
   
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        var ret : Bool = true
        switch (textField){
        case binText :
            self.binLocModel?.modelType = .Bin;
            self.pickerView.isHidden = false;
            if self.binLocModel?.entityBaseModel != nil{
                self.pickerData = (self.binLocModel!.entityBaseModel?.filter({ (entityModel) -> Bool in
                    return entityModel.entityTypeModel! == EntityType.Bin.rawValue
                }))!
            }
            self.pickerView.reloadAllComponents() ;
            if (binText.text?.characters.count)! > 0 {
                self.pickerView.selectRow((self.binLocModel?.getIndexOfValue(entityObj: self.selectedBin))!, inComponent: 0, animated: true)
            }
            ret = false ;
            
        case locationText :
            self.binLocModel?.modelType = .Location;
            self.pickerView.isHidden = false;
            if self.binLocModel?.entityBaseModel != nil{
                self.pickerData = (self.binLocModel!.entityBaseModel?.filter({ (entityModel) -> Bool in
                    return entityModel.entityTypeModel! == EntityType.Location.rawValue
                }))!
            }
            self.pickerView.reloadAllComponents();
            if (locationText.text?.characters.count)! > 0 {
                self.pickerView.selectRow((self.binLocModel?.getIndexOfValue(entityObj: self.selectedLoc!))!, inComponent: 0, animated: true)
            }
            ret = false
        default : break
        }
        return ret
    }
}
//MARK: - Class Functions
extension ViewController{

    func showAlertController(entityType : EntityType, sender : UIButton?){
        let context = CoreDataManager.shared.viewContext
        let alertController = UIAlertController(title: "\(entityType)", message: "Please Add \(entityType)", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel,handler: { (action) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        })
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { [unowned self, weak sender]( action) -> Void in

            if  alertController.textFields!.first!.text!.isEmpty {
                self.showErrorAlert(title: EmptyFieldError.EmtpyFieldTitle.rawValue, message: "Add Name")
                return;
            }
            else if !alertController.textFields!.first!.text!.isEmpty {
               
                if sender?.tag == ButtonTag.AddBin.rawValue{
                    if self.locationText.text!.isEmpty {
                        self.showErrorAlert(title: "Empty Location", message: "Please Select Location first")
                        return
                    }
                    let binModel : BinModel = self.getCoreDataManagerObject().newManagedObject(entityName: CoreDataModelName.BinModel.rawValue,context:context)!
                 
                    binModel.setObjectProperties(jsonDict:    [   "name" : alertController.textFields!.first!.text!,
                                                                  "id" : binModel.getObjectId(entityName: CoreDataModelName.BinModel.rawValue, context: context),
                                                                  "locationId" : self.selectedLoc!.id
                        ], entityType: EntityType.Bin.rawValue, context: context)
                    self.selectedBin = binModel
                    self.getCoreDataManagerObject().saveViewContext()
                    self.setTitle(name: (alertController.textFields?.first?.text)!)
                    
                } else{
                    let locModel : LocationModel = self.getCoreDataManagerObject().newManagedObject(entityName: CoreDataModelName.LocationModel.rawValue,context: context)!
                    locModel.setObjectProperties(jsonDict:    [   "name" : alertController.textFields!.first!.text!,
                                                                  "id" : locModel.getObjectId(entityName: CoreDataModelName.LocationModel.rawValue, context: context),
                        ], entityType: EntityType.Location.rawValue, context: context)
                    
                    self.selectedLoc = locModel
                    self.getCoreDataManagerObject().saveViewContext()
                    self.binLocModel?.addElement(name: alertController.textFields!.first!.text!)
                    self.binLocModel?.setName()
                    self.setTitle(name: (alertController.textFields?.first?.text)!)
                }
                alertController.dismiss(animated: true, completion: nil)
            }
            self.binLocModel?.getAllEntityBaseModel()
        })
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        alertController.addTextField { (textField) in
            textField.placeholder = "\(entityType)"
            textField.accessibilityLabel = "\(entityType.rawValue) Input"
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setTitle(name : String){
        switch ((self.binLocModel)!.modelType){
        case .Bin : self.binText.text = name
        case .Location: self.locationText.text = name
        default : break
        }
    }
    
    func showErrorAlert (title : String, message : String){
        let alert = UIAlertView(title: "", message: message, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    func getCoreDataManagerObject()->CoreDataManager{
        return CoreDataManager.shared
    }
}
