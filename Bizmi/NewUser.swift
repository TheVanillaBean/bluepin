//
//  NewUser.swift
//  Bizmi
//
//  Created by Alex on 9/18/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import Foundation

typealias UserCompletion = (errMsg: String?) -> Void

class NewUser{
    
    private var _uuid: String!
    private var _email: String!
    private var _userType: String!
    private var _fullName: String!
    private var _phoneNumber: String!
    private var _phoneNumberVerified: String!
    private var _password: String!
    
    private var _businessName: String!
    private var _businessType: String!
    private var _businessDesc: String!
    private var _businessWebsite: String!
    private var _businessHours: String!
    private var _userProfilePicLocation: String!
    private var _businessLocation: String!
    
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
            return _password
        }
        
        set(newPassword){
            
            if newPassword != ""{
                _password = newPassword
            }
        }
    }
    
    
    var userType: String {
        get{
            return _userType
        }
        
        set(newUserType){
            
            if newUserType != ""{
                _userType = newUserType
            }
        }
    }
    
    var fullName: String {
        get{
            return _fullName
        }
        
        set(newName){
            
            if newName != ""{
                _fullName = newName
            }
        }
    }
    
    var phoneNumber: String {
        get{
            return _phoneNumber
        }
        
        set(newPhoneNumber){
            
            if newPhoneNumber != ""{
                _phoneNumber = newPhoneNumber
            }
        }
    }
    
    var businessName: String {
        get{
            return _businessName
        }
        
        set(newBusinessName){
            
            if newBusinessName != ""{
                _businessName = newBusinessName
            }
        }
    }
    
    var businessType: String {
        get{
            return _businessType
        }
        
        set(newBusinessType){
            
            if newBusinessType != ""{
                _businessType = newBusinessType
            }
        }
    }
    
    var phoneNumberVerified: String {
        get{
            return _phoneNumberVerified
        }
        
        set(newPhoneNumberVerified){
            
            if newPhoneNumberVerified != ""{
                _phoneNumberVerified = newPhoneNumberVerified
            }
        }
    }
    
    var businessDesc: String {
        get{
            return _businessDesc
        }
        
        set(newBusinessDesc){
            
            if newBusinessDesc != ""{
                _businessDesc = newBusinessDesc
            }
        }
    }
    
    var businessWebsite: String {
        get{
            return _businessWebsite
        }
        
        set(newBusinessWebsite){
            
            if newBusinessWebsite != ""{
                _businessWebsite = newBusinessWebsite
            }
        }
    }
    
    var businessHours: String {
        get{
            return _businessHours
        }
        
        set(newBusinessHours){
            
            if newBusinessHours != ""{
                _businessHours = newBusinessHours
            }
        }
    }
    
    var userProfilePicLocation: String {
        get{
            return _userProfilePicLocation
        }
        
        set(newUserProfilePicLocation){
            
            if newUserProfilePicLocation != ""{
                _userProfilePicLocation = newUserProfilePicLocation
            }
        }
    }
    
    var businessLocation: String {
        get{
            return _businessLocation
        }
        
        set(newBusinessLocation){
            
            if newBusinessLocation != ""{
                _businessLocation = newBusinessLocation
            }
        }
    }
    
    
    init(email: String?, password: String?, userType: String?){
        
        if let userEmail = email, userPassword = password, type = userType {
            self.email = userEmail
            self.password = userPassword
            self.userType = type
        }
        
    }
    
    init(){
    
    }
    
    func castUser(uuid: String, onComplete: UserCompletion?){
        
        FBDataService.instance.usersRef.child(uuid).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            // Get user value
            let userDict = snapshot.value as! [String : AnyObject]
            
            print(userDict)
            
            if let id = userDict[UUID] as? String{
                self.uuid = id
            }
            if let type = userDict[USER_TYPE] as? String{
                self.userType = type
                print(type)
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
            
            onComplete?(errMsg: nil)
            
        }) { (error) in
            
            onComplete?(errMsg: error.localizedDescription)

            print(error.localizedDescription)
        }
        
    }
    
}





