//
//  CustomerViewBusinessesVC.swift
//  bluepin
//
//  Created by Alex on 7/27/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import Kingfisher

class CustomerViewBusinessesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate  {

    @IBOutlet weak var tableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
     
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()

        FBDataService.instance.retriveAllBusinesses { (errMsg, data) in
            self.tableView.reloadData()
        }
        
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing Data ...", attributes: nil)
        refreshControl.addTarget(self, action: #selector(CustomerViewBusinessesVC.refresh(sender:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }
    
    func refresh(sender: UIRefreshControl) {
        FBDataService.instance.retriveAllBusinesses { (errMsg, data) in
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = EMPTY_DATA_WELCOME
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = EMPTY_BUSINESSES_DATA_SET_CUSTOMER
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let business = FBDataService.instance.allBusinesses[(indexPath as NSIndexPath).row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ViewBusinessesCell", for: indexPath) as? ViewBusinessesCell{
            
            if ImageCache.default.isImageCached(forKey: business).cached {

                ImageCache.default.retrieveImage(forKey: business, options: nil) {
                    image, cacheType in
                    if let image = image {
                        cell.businessBGImage.image = image
                    }
                }
                
            }
            
            cell.configureCell(business)
            
            return cell
        }else {
            
            let cell = ViewBusinessesCell()
            cell.configureCell(business)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FBDataService.instance.allBusinesses.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let business = FBDataService.instance.allBusinesses[(indexPath as NSIndexPath).row]
        
        performSegue(withIdentifier: "ViewSingleBusiness", sender: business)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewSingleBusiness" {
            if let viewBusinessVC = segue.destination as? ViewBusinessVC{
                if let business = sender as? String {
                    viewBusinessVC.businessID = business
                }
            }
            
        }
    }
   

}
