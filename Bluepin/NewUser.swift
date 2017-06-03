//
//  NewUser.swift
//  bluepin
//
//  Created by Alex on 9/18/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import Foundation

typealias UserCompletion = (_ errMsg: String?) -> Void

class NewUser{
    
    fileprivate var _uuid: String!
    fileprivate var _email: String!
    fileprivate var _userType: String!
    fileprivate var _fullName: String!
    fileprivate var _phoneNumber: String!
    fileprivate var _phoneNumberVerified: String!
    fileprivate var _password: String!
    
    fileprivate var _businessName: String!
    fileprivate var _businessType: String!
    fileprivate var _businessDesc: String!
    fileprivate var _businessWebsite: String!
    fileprivate var _businessHours: String!
    fileprivate var _userProfilePicLocation: String!
    fileprivate var _businessLocation: String!
    
    fileprivate var _deviceToken: String!
    
    var deviceToken: String {
        get{
            return _deviceToken
        }
        
        set(newInput){
            
            if newInput != ""{
                _deviceToken = newInput
            }
        }
    }
    
    var uuid: String {
        get{
            return _uuid
        }
        
        set(newUUID){
            
            if newUUID != ""{
                _uuid = newUUID
            }
        }
    }
    
    var email: String {
        get{
            return _email
        }
        
        set(newEmail){
            
            if newEmail != ""{
                _email = newEmail
            }
        }
    }
    
    var password: String {
        get{
            if let password = _password{
                return password
            }else{
                return ""
            }
        }
        
        set(newPassword){
            
            if newPassword != ""{
                _password = newPassword
            }
        }
    }
    
    
    var userType: String {
        get{
            if let type = _userType{
                return type
            }else{
                return ""
            }
        }
        
        set(newUserType){
            
            if newUserType != ""{
                _userType = newUserType
            }
        }
    }
    
    var fullName: String {
        get{
            if let name = _fullName{
                return name
            }else{
                return ""
            }
        }
        
        set(newName){
            
            if newName != ""{
                _fullName = newName
            }
        }
    }
    
    var phoneNumber: String {
        get{
            if let num = _phoneNumber{
                return num
            }else{
                return ""
            }
        }
        
        set(newPhoneNumber){
            
            if newPhoneNumber != ""{
                _phoneNumber = newPhoneNumber
            }
        }
    }
    
    var businessName: String {
        get{
            if let name = _businessName{
                return name
            }else{
                return ""
            }
        }
        
        set(newBusinessName){
            
            if newBusinessName != ""{
                _businessName = newBusinessName
            }
        }
    }
    
    var businessType: String {
        get{
            if let type = _businessType{
                return type
            }else{
                return ""
            }
        }
        
        set(newBusinessType){
            
            if newBusinessType != ""{
                _businessType = newBusinessType
            }
        }
    }
    
    var phoneNumberVerified: String {
        get{
            if let verif = _phoneNumberVerified{
                return verif
            }else{
                return ""
            }
        }
        
        set(newPhoneNumberVerified){
            
            if newPhoneNumberVerified != ""{
                _phoneNumberVerified = newPhoneNumberVerified
            }
        }
    }
    
    var businessDesc: String {
        get{
            if let desc = _businessDesc{
                return desc
            }else{
                return ""
            }        }
        
        set(newBusinessDesc){
            
            if newBusinessDesc != ""{
                _businessDesc = newBusinessDesc
            }
        }
    }
    
    var businessWebsite: String {
        get{
            if let website = _businessWebsite{
                return website
            }else{
                return ""
            }
        }
        
        set(newBusinessWebsite){
            
            if newBusinessWebsite != ""{
                _businessWebsite = newBusinessWebsite
            }
        }
    }
    
    var businessHours: String {
        get{
            if let hours = _businessHours{
                return hours
            }else{
                return ""
            }
        }
        
        set(newBusinessHours){
            
            if newBusinessHours != ""{
                _businessHours = newBusinessHours
            }
        }
    }
    
    var userProfilePicLocation: String {
        get{
            if let loc = _userProfilePicLocation{
                return loc
            }else{
                return ""
            }
        }
        
        set(newUserProfilePicLocation){
            
            if newUserProfilePicLocation != ""{
                _userProfilePicLocation = newUserProfilePicLocation
            }
        }
    }
    
    var businessLocation: String {
        get{
            if let loc = _businessLocation{
                return loc
            }else{
                return ""
            }
        }
        
        set(newBusinessLocation){
            
            if newBusinessLocation != ""{
                _businessLocation = newBusinessLocation
            }
        }
    }
    
    
    init(email: String?, password: String?, userType: String?){
        
        if let userEmail = email, let userPassword = password, let type = userType {
            self.email = userEmail
            self.password = userPassword
            self.userType = type
        }
        
    }
    
    init(){
    
    }
    
    func castUser(_ uuid: String, onComplete: UserCompletion?){
        
        FBDataService.instance.usersRef.child(uuid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard snapshot.exists() else{
                return
            }
            
            let userDict = snapshot.value as! [String : AnyObject]
            
            if let id = userDict[UUID] as? String{
                self.uuid = id
            }
            if let type = userDict[USER_TYPE] as? String{
                self.userType = type
               // print(type)
            }
            if let bName = userDict[BUSINESS_NAME] as? String{
                self.businessName = bName
            }
            if let type = userDict[BUSINESS_TYPE]as? String{
                self.businessType = type
            }
            if let name = userDict[FULL_NAME] as? String{
                self.fullName = name
            }
            if let number = userDict[PHONE_NUMBER] as? String{
                self.phoneNumber = number
            }
            if let email = userDict[EMAIL] as? String{
                self.email = email
            }
            if let desc = userDict[BUSINESS_DESC] as? String{
                self.businessDesc = desc
            }
            if let website = userDict[BUSINESS_WEBSITE] as? String{
                self.businessWebsite = website
            }
            
            if let hours = userDict[BUSINESS_HOURS] as? String{
                self.businessHours = hours
            }
            
            if let picLocation = userDict[PROFILE_PIC_LOCATION] as? String{
                self.userProfilePicLocation = picLocation
            }
            
            if let verified = userDict[PHONE_NUMBER_VERIFIED] as? String{
                self.phoneNumberVerified = verified
            }
            
            if let loc = userDict[BUSINESS_LOCATION] as? String{
                self.businessLocation = loc
            }
            
            if let token = userDict[DEVICE_TOKEN] as? String{
                self.deviceToken = token
            }
            
            onComplete?(nil)
            
        }) { (error) in
            
            onComplete?(error.localizedDescription)

        }
        
    }
    
}





