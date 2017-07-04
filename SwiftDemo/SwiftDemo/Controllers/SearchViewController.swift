//
//  SearchViewController.swift
//  SwiftDemo
//
//  Created by khurram iqbal on 16/06/2017.
//  Copyright © 2017 Nisum. All rights reserved.
//

import UIKit
import CoreData
class SearchViewController: UITableViewController {
    
    
    @IBOutlet weak var refreshControlHandler: UIRefreshControl!
   
    var fetechResultController : NSFetchedResultsController<EntityBaseModel>!
    var selectedItem : ItemModel?
    var difference : Int = 0
    let searchController = UISearchController(searchResultsController: nil)
    let scoopButtonTitles = ["All",EntityType.Item.rawValue,EntityType.Bin.rawValue,EntityType.Location.rawValue]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetechResultController = CoreDataManager.shared.fetchedResultsController as! NSFetchedResultsController<EntityBaseModel>
        self.fetechResultController.delegate = self
        self.fetchResultControllerPerform()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing")
        self.tableView.refreshControl = refreshControl
        self.refreshControl?.addTarget(self, action:#selector(SearchViewController.refreshControlHandler(_:)) , for: .valueChanged)
        searchController.searchBar.scopeButtonTitles = scoopButtonTitles
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60;
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = CoreDataManager.shared.fetchedResultsController.sections else { return 0 }
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let sections = CoreDataManager.shared.fetchedResultsController.sections {
              return (sections[section].objects?.count)!
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: AppConstant.searchViewControllerCellIdentifier)
        
        let entityObject   = self.fetechResultController.object(at: indexPath)
        
        switch (EntityType(rawValue :entityObject.entityTypeModel!))!{
        case .Item:
            cell?.textLabel?.text = "Item name : \(entityObject.name ?? "")"
            cell?.detailTextLabel?.text = "Bin Name = \((entityObject as! ItemModel).iItemToBin?.name ?? "") Location Name = \( (entityObject as! ItemModel).iItemToBin?.binToLocation?.name ?? "")"
        case .Bin :
            cell?.textLabel?.text = "Bin name : \(entityObject.name ?? "")"
            cell?.detailTextLabel?.text = "Location name = \((entityObject as! BinModel).binToLocation?.name ?? "") "
        case .Location :
            cell?.textLabel?.text = "Location name : \(entityObject.name ?? "")"
            cell?.detailTextLabel?.text = ""
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedItem = self.fetechResultController.object(at: indexPath) as? ItemModel
        if (selectedItem != nil) {
            self.performSegue(withIdentifier: AppConstant.backToBinControllerSegueIdentifier, sender: self)
        }
    }

    func refreshControlHandler(_ sender: UIRefreshControl) {
//        filteredArray?.append((filteredArray?[0])!)
//        self.refreshControl?.endRefreshing()
//        self.tableView.reloadData()
        NetworkOperations.sharedInstance.getAllData(dataType: AppConstant.allData, completionHandler:{ [unowned self] (response , success) -> Void in
                self.refreshControl?.endRefreshing()
        })
        
    }
}

//MARK: - IBACTIONS
extension SearchViewController{


}
//MARK: - SearchResult Update delegate
extension SearchViewController : UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchBar = searchController.searchBar
        var predicate : NSPredicate?
        if searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex] == "All" {
            
            predicate = ((searchBar.text!.isEmpty ) ? nil : NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!))
        } else {
            if searchBar.text!.isEmpty{
                predicate = NSPredicate(format: "entityTypeModel == %@", searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
            } else {
                predicate = NSPredicate(format: "entityTypeModel == %@ && name CONTAINS[cd] %@ ", searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex],searchBar.text!)
            }
        }
        self.fetechResultController.fetchRequest.predicate =  predicate
        self.fetchResultControllerPerform()
        tableView.reloadData()
    }
}

//MARK: - SearchBar Delegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        var predicate : NSPredicate?
        if searchBar.scopeButtonTitles![selectedScope] == "All" {
        
            predicate = ((searchBar.text!.isEmpty ) ? nil : NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!))
        } else {
            if searchBar.text!.isEmpty{
                predicate = NSPredicate(format: "entityTypeModel == %@", searchBar.scopeButtonTitles![selectedScope])
            } else {
             predicate = NSPredicate(format: "entityTypeModel == %@ && name CONTAINS[cd] %@ ", searchBar.scopeButtonTitles![selectedScope],searchBar.text!)
            
            }
        }
        self.fetechResultController.fetchRequest.predicate = predicate
        self.fetchResultControllerPerform()
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var predicate : NSPredicate?
        if searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex] == "All" {
            
            predicate = ((searchBar.text!.isEmpty ) ? nil : NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!))
        } else {
            if searchBar.text!.isEmpty{
                predicate = NSPredicate(format: "entityTypeModel == %@", searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
            } else {
                predicate = NSPredicate(format: "entityTypeModel == %@ && name CONTAINS[cd] %@ ", searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex],searchBar.text!)
            }
        }
        self.fetechResultController.fetchRequest.predicate =  predicate
        self.fetchResultControllerPerform()
        tableView.reloadData()
        
    }
}

//MARK: - Class Functions
extension SearchViewController{
    func filterContentForSearchText(searchText: String, scope: String ) {
        
//        if EntityObjects != nil{
//            filteredArray = ((scope == "All") ? EntityObjects : EntityObjects?.filter({return $0.entityTypeModel!.lowercased() == scope.lowercased()}))!
//            
//            filteredArray = filteredArray!.filter { item in
//                if searchText.isEmpty{
//                    return true
//                }
//                if searchText.isEmpty && item.entityTypeModel!.lowercased() == scope.lowercased() || searchText.isEmpty &&   scope.lowercased() == "All" {
//                    return true
//                }
//                return item.name!.lowercased().contains(searchText.lowercased()) && ((scope == "All") ? true : item.entityTypeModel!.lowercased() == scope.lowercased())
//            }
//            filteredArray?.sort(by: {
//                return $0.name! < $1.name!
//            })
//        }
    }
    func fetchResultControllerPerform(){
        do {
            try CoreDataManager.shared.fetchedResultsController.performFetch()
        } catch{
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
}

//Mark: - NSFetechResult Controller Delegate
extension SearchViewController: NSFetchedResultsControllerDelegate{

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
      
        switch (type) {

        case .insert: tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete : tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update :   _ = tableView.cellForRow(at: indexPath!)
        case .move :  tableView.deleteRows(at: [indexPath!], with: .fade) ;tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        print (sectionName)
        return sectionName
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    
    }

}


