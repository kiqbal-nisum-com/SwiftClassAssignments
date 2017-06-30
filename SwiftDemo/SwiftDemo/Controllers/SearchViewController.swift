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
    let searchController = UISearchController(searchResultsController: nil)
    let scoopButtonTitles = ["All",CoreDataModelName.ItemModel.rawValue,CoreDataModelName.BinModel.rawValue,CoreDataModelName.LocationModel.rawValue]

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        self.filteredArray = self.EntityObjects
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60;
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (filteredArray == nil) ? 0 : filteredArray!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AppConstant.searchViewControllerCellIdentifier)
        
        switch (CoreDataModelName(rawValue :filteredArray![indexPath.row].entityTypeModel!))!{
        
        case .ItemModel :
            cell?.textLabel?.text = "Item name : \((filteredArray![indexPath.row]).name ?? "")"
            cell?.detailTextLabel?.text = "Bin Name = \((filteredArray![indexPath.row] as! ItemModel).iItemToBin?.name ?? "") Location Name = \((filteredArray![indexPath.row] as! ItemModel).iItemToBin?.binToLocation?.name ?? "")"
            
        case .BinModel :
            cell?.textLabel?.text = "Bin name : \((filteredArray![indexPath.row] ).name ?? "")"
            cell?.detailTextLabel?.text = "Location name = \((filteredArray![indexPath.row] as! BinModel).binToLocation?.name ?? "") "
            
        case .LocationModel:
            cell?.textLabel?.text = "Location name : \((filteredArray![indexPath.row]).name ?? "")"
            cell?.detailTextLabel?.text = ""
            
        default : break
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
        filteredArray?.append((filteredArray?[0])!)
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
        
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
    }
}

//MARK: - SearchBar Delegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchText: searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
          filterContentForSearchText(searchText: searchText, scope: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
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
            
            tableView.reloadData()
        }
    }
}

//Mark: - NSFetechResult Controller Delegate
extension SearchViewController: NSFetchedResultsControllerDelegate{

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
    }
    
    

}


