//
//  ViewBusinessWebsiteVC.swift
//  Bizmi
//
//  Created by Alex on 8/10/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import WebKit

class ViewBusinessWebsiteVC: UIViewController {
    
    @IBOutlet weak var container: UIView!
    
    var webView: WKWebView!
    
    var URL: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .default
        
        webView = WKWebView()
        container.addSubview(webView)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        UIApplication.shared.statusBarStyle = .lightContent
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
        let frame = CGRect(x: 0, y: 0, width: container.bounds.width, height: container.bounds.height)
        webView.frame = frame

        if let urlString = URL, let url = Foundation.URL(string: urlString) , UIApplication.shared.canOpenURL(url) {
            print(urlString)
            let request = URLRequest(url: url)
            webView.load(request)
            
        }else{
            Messages.displayToastMessage(self.view, msg: "Cannot Display Webpage...")
        }
        
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        
        print("default")
        
        return UIStatusBarStyle.default
       
    }
    
    @IBAction func cancelBtnPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
