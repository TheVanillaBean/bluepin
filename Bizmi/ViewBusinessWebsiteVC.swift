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
        
        UIApplication.sharedApplication().statusBarStyle = .Default
        
        webView = WKWebView()
        container.addSubview(webView)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
    }
    
    override func viewDidAppear(animated: Bool) {
       
        let frame = CGRectMake(0, 0, container.bounds.width, container.bounds.height)
        webView.frame = frame

        if let urlString = URL, url = NSURL(string: urlString) where UIApplication.sharedApplication().canOpenURL(url) {
            print(urlString)
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request)
            
        }else{
            Messages.displayToastMessage(self.view, msg: "Cannot Display Webpage...")
        }
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        
        print("default")
        
        return UIStatusBarStyle.Default
       
    }
    
    @IBAction func cancelBtnPressed(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
