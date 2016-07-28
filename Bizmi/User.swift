//
//  User.swift
//  Bizmi
//
//  Created by Alex on 7/20/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import Foundation

class User: BackendlessUser{
    
    //Password and Email computed properies have "user" in front because they are actually part of BackendlessUser class
    
    //Password has additional variable because BackendlessUser class doesn't return password
    var _password: String!
    
    var fullName: String {
        get{
            if let fullNameProperty = self.getProperty("fullName") as? String{
                return fullNameProperty
            }else{
                return ""
            }
        }
        
        set(newFullName){
            
            if newFullName != ""{
                self.setProperty("fullName", object: newFullName)
            }
        }
    }
    
    var phoneNumber: String {
        get{
            if let phoneNumberProperty = self.getProperty("phoneNumber") as? String{
                return phoneNumberProperty
            }else{
                return ""
            }
        }
        
        set(newPhoneNumber){
            
            if newPhoneNumber != ""{
                self.setProperty("phoneNumber", object: newPhoneNumber)
            }
        }
    }
    
    var userEmail: String {
        get{
            if let email = self.email{
                return email
            }else{
                return ""
            }
        }
        
        set(newEmail){
            
            if newEmail != ""{
                self.email = newEmail
            }
        }
    }
    
    // _password is used because BackendlessUser class doesn't return password
    var userPassword: String {
        get{
            if let password = self._password{
                return password
            }else{
                return ""
            }
        }
        
        set(newPassword){
            
            if newPassword != ""{
                self.password = newPassword
                self._password = newPassword
            }
            
        }
    }
    
    var businessName: String {
        get{
            if let businessNameProperty = self.getProperty("businessName") as? String{
                return businessNameProperty
            }else{
                return ""
            }
        }
        
        set(newBusinessName){
            
            if newBusinessName != ""{
                self.setProperty("businessName", object: newBusinessName)
            }
        }
    }
    
    var businessType: String {
        get{
            if let businessTypeProperty = self.getProperty("businessType") as? String{
                return businessTypeProperty
            }else{
                return ""
            }
        }
        
        set(newBusinessType){
            
            if newBusinessType != ""{
                self.setProperty("businessType", object: newBusinessType)
            }
        }
    }
    
    var userType: String {
        get{
            if let userTypeProperty = self.getProperty("userType") as? String{
                return userTypeProperty
            }else{
                return ""
            }
        }
        
        set(newUserType){
            
            if newUserType != ""{
                self.setProperty("userType", object: newUserType)
            }
        }
    }
    
    func populateUserData(backendlessUser: BackendlessUser?){
    
        if let user = backendlessUser{
            
            if let userTypeProperty = user.getProperty("userType") as? String{
                self.userType = userTypeProperty
            }
            
            if let businessNameProperty = user.getProperty("businessName") as? String{
                self.businessName = businessNameProperty
            }
            
            if let businessTypeProperty = user.getProperty("businessType") as? String{
                self.businessType = businessTypeProperty
            }
            
            if let fullNameProperty = user.getProperty("fullName") as? String{
                self.fullName = fullNameProperty
            }
            
            if let phoneNumberProperty = user.getProperty("phoneNumber") as? String{
                self.phoneNumber = phoneNumberProperty
            }
            
            if let emailProperty = user.email{
                self.email = emailProperty
            }
            
            if let passwordProperty = user.password{
                self.password = passwordProperty
            }
            
        }
        
    }
    
    override init() {
        super.init()
        //Empty init used for casting of BackendlessUser Object to Bizmi User Object Model
    }

    init(email: String?, password: String?, userType: String?){
        super.init()
        
        if let userEmail = email, userPassword = password, type = userType {
        self.userEmail = userEmail
        self.userPassword = userPassword
        self.userType = type
        }
        
    }
 
}




































