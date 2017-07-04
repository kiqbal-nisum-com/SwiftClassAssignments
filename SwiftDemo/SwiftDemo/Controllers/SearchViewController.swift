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
    var EntityObjects : [EntityBaseModel]? = [EntityBaseModel]()
    var filteredArray : [EntityBaseModel]? = [EntityBaseModel]()
    var selectedItem : ItemModel?
    var difference : Int = 0
    let searchController = UISearchController(searchResultsController: nil)
    let scoopButtonTitles = ["All",EntityType.Item.rawValue,EntityType.Bin.rawValue,EntityType.Location.rawValue]

    override func viewDidLoad() {
        super.viewDidLoad()
//        CoreDataManager.shared.persistentContainer.loadPersistentStores { (persistentStoreDescription, error) in
//            if let error = error {
//                print("Unable to Load Persistent Store")
//                print("\(error), \(error.localizedDescription)")
//            } else {
//                do {
//                    try CoreDataManager.shared.fetchedResultsController.performFetch()
//                } catch {
//                    let fetchError = error as NSError
//                    print("Unable to Perform Fetch Request")
//                    print("\(fetchError), \(fetchError.localizedDescription)")
//                }
//            }
//        }
        CoreDataManager.shared.fetchedResultsController.delegate = self
        do {
            try CoreDataManager.shared.fetchedResultsController.performFetch()
        } catch{
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
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

    override func viewWillAppear(_ animated: Bool) {
//        self.filteredArray = self.EntityObjects
//        self.tableView.reloadData()
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
            EntityObjects = sections[section].objects as? [EntityBaseModel]
            self.filterContentForSearchText(searchText: searchController.searchBar.text!, scope: (searchController.searchBar.scopeButtonTitles?[searchController.searchBar.selectedScopeButtonIndex])!)
             return ((filteredArray == nil) ? 0 : filteredArray!.count )
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: AppConstant.searchViewControllerCellIdentifier)
        switch (EntityType(rawValue :filteredArray![indexPath.row].entityTypeModel!))!{
        case .Item:
            cell?.textLabel?.text = "Item name : \((filteredArray![indexPath.row]).name ?? "")"
            cell?.detailTextLabel?.text = "Bin Name = \((filteredArray![indexPath.row] as! ItemModel).iItemToBin?.name ?? "") Location Name = \((filteredArray![indexPath.row] as! ItemModel).iItemToBin?.binToLocation?.name ?? "")"
        case .Bin :
            cell?.textLabel?.text = "Bin name : \((filteredArray![indexPath.row] ).name ?? "")"
            cell?.detailTextLabel?.text = "Location name = \((filteredArray![indexPath.row] as! BinModel).binToLocation?.name ?? "") "
        case .Location :
            cell?.textLabel?.text = "Location name : \((filteredArray![indexPath.row]).name ?? "")"
            cell?.detailTextLabel?.text = ""
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedItem = filteredArray![indexPath.row] as? ItemModel
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
            let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
            filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
            tableView.reloadData()
    }
}

//MARK: - SearchBar Delegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchText: searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
          filterContentForSearchText(searchText: searchText, scope: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
            tableView.reloadData()
    }
}

//MARK: - Class Functions
extension SearchViewController{
    func filterContentForSearchText(searchText: String, scope: String ) {
        
        if EntityObjects != nil{
            filteredArray = ((scope == "All") ? EntityObjects : EntityObjects?.filter({return $0.entityTypeModel!.lowercased() == scope.lowercased()}))!
            
            filteredArray = filteredArray!.filter { item in
                if searchText.isEmpty{
                    return true
                }
                if searchText.isEmpty && item.entityTypeModel!.lowercased() == scope.lowercased() || searchText.isEmpty &&   scope.lowercased() == "All" {
                    return true
                }
                return item.name!.lowercased().contains(searchText.lowercased()) && ((scope == "All") ? true : item.entityTypeModel!.lowercased() == scope.lowercased())
            }
            filteredArray?.sort(by: {
                return $0.name! < $1.name!
            })
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
        difference = (CoreDataManager.shared.fetchedResultsController.sections?[(newIndexPath?.section)!].objects?.count)! - (filteredArray?.count)!
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
//                tableView.insertRows(at: [indexPath], with: .fade)
                tableView.reloadData()
            }
            break;
        case .delete:
            if let indexPath = indexPath {
//                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadData()

            }
            break;
        case .update:
            if let indexPath = indexPath {
//                _ = tableView.cellForRow(at: indexPath)
//                tableView.reloadData()

            }
            break;
        case .move:
            if let indexPath = indexPath {
//                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadData()

            }
            
            if let newIndexPath = newIndexPath {
//                tableView.insertRows(at: [newIndexPath], with: .fade)
                tableView.reloadData()

            }
            break;
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        print (sectionName)
        return sectionName
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    
    }

}


