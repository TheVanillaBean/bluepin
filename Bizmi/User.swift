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
    var _email: String!
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
                return "No Phone Number Available"
            }
        }
        
        set(newPhoneNumber){
            
            if newPhoneNumber != ""{
                self.setProperty("phoneNumber", object: newPhoneNumber)
            }
        }
    }
    
//    var userEmail: String {
//        get{
//            if let email = self.email{
//                return email
//            }else{
//                return ""
//            }
//        }
//        
//        set(newEmail){
//            
//            if newEmail != ""{
//                self.email = newEmail
//            }
//        }
//    }
//    
    // _email is used because BackendlessUser class doesn't return email
    var userEmail: String {
        get{
            if let email = self._email{
                return email
            }else{
                return ""
            }
        }
        
        set(newEmail){
            
            if newEmail != ""{
                self.email = newEmail
                self._email = newEmail
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
                return "Business Type Not Available"
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
    
    var phoneNumberVerified: Bool {
        get{
            if let phoneNumberVerifiedProperty = self.getProperty("phoneNumberVerified") as? Bool{
                return phoneNumberVerifiedProperty
            }else{
                return false
            }
        }
        
        set(newStatus){
            
            self.setProperty("phoneNumberVerified", object: newStatus)
            
        }
    }
    
    //After Signup Values
    
    var businessDesc: String {
        get{
            if let businessDescProperty = self.getProperty("businessDesc") as? String{
                return businessDescProperty
            }else{
                return "No Description Available"
            }
        }
        
        set(newBusinessDesc){
            
            if newBusinessDesc != ""{
                self.setProperty("businessDesc", object: newBusinessDesc)
            }
        }
    }
    
    var businessWebsite: String {
        get{
            if let businessWebsiteProperty = self.getProperty("businessWebsite") as? String{
                return businessWebsiteProperty
            }else{
                return "Business Website Not Available"
            }
        }
        
        set(newBusinessWebsite){
            
            if newBusinessWebsite != ""{
                self.setProperty("businessWebsite", object: newBusinessWebsite)
            }
        }
    }
    
    var businessHours: String {
        get{
            if let businessHoursProperty = self.getProperty("businessHours") as? String{
                return businessHoursProperty
            }else{
                return "Hours Not Available"
            }
        }
        
        set(newBusinessHours){
            
            if newBusinessHours != ""{
                self.setProperty("businessHours", object: newBusinessHours)
            }
        }
    }
    
    var userProfilePicLocation: String {
        get{
            if let userProfilePictureProperty = self.getProperty("userProfilePicLocation") as? String{
                return userProfilePictureProperty
            }else{
                return ""
            }
        }
        
        set(newUserProfilePicture){
            
            if newUserProfilePicture != "" {
                self.setProperty("userProfilePicLocation", object: newUserProfilePicture)
            }
        }
    }
    
    var businessLocation: GeoPoint {
        get{
            if let businessLocationProperty = self.getProperty("businessLocation") as? GeoPoint{
                return businessLocationProperty
            }else{
                return GeoPoint()
            }
        }
        
        set(newBusinessLocation){
            
            self.setProperty("businessLocation", object: newBusinessLocation)
            
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
                self.userEmail = emailProperty
            }
            
            if let businessDescProperty = user.getProperty("businessDesc") as? String{
                self.businessDesc = businessDescProperty
            }
            
            if let businessWebsiteProperty = user.getProperty("businessWebsite") as? String{
                self.businessWebsite = businessWebsiteProperty
            }
            
            if let businessHoursProperty = user.getProperty("businessHours") as? String{
                self.businessHours = businessHoursProperty
            }
            
            if let userProfilePicLocationProperty = user.getProperty("userProfilePicLocation") as? String{
                self.userProfilePicLocation = userProfilePicLocationProperty
            }
            
            if let isPhoneVerifiedProperty = user.getProperty("phoneNumberVerified") as? Bool{
                self.phoneNumberVerified = isPhoneVerifiedProperty
            }
            
            //Backendless doesnt return password
            
//            if let passwordProperty = user.password{
//               self.userPassword = passwordProperty
//            }
            
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




































