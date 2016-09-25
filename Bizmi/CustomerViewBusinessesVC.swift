//
//  CustomerViewBusinessesVC.swift
//  Bizmi
//
//  Created by Alex on 7/27/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit

class CustomerViewBusinessesVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
     
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.instance.loadAllBusinesses()
        
        NotificationCenter.default.addObserver(self, selector: #selector(CustomerViewBusinessesVC.onBusinessesLoaded), name: NSNotification.Name(rawValue: "allBusinessesLoaded"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let business = DataService.instance.allBusinesses[(indexPath as NSIndexPath).row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ViewBusinessesCell") as? ViewBusinessesCell{
            
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
        return DataService.instance.allBusinesses.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true) //So tableview row doesn't stay highlighted
        
        let business = DataService.instance.allBusinesses[(indexPath as NSIndexPath).row]
        performSegue(withIdentifier: "ViewSingleBusiness", sender: business)
        
    }
    
    func onBusinessesLoaded(){
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewSingleBusiness" {
            if let viewBusinessVC = segue.destination as? ViewBusinessVC{
                if let business = sender as? BackendlessUser {
                    viewBusinessVC.backendlessUser = business
                }
            }
            
        }
    }
    
}
