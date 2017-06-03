//
//  Reservation.swift
//  bluepin
//
//  Created by Alex on 9/18/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import Foundation

typealias ReservationCompletion = (_ errMsg: String?) -> Void

class Reservation{
    
    fileprivate var _uuid: String!
    fileprivate var _status: String!
    fileprivate var _timestamp: Double!
    fileprivate var _scheduledTime: String!
    fileprivate var _leaderID: String!
    fileprivate var _businessID: String!
    
    fileprivate var _businessName: String!
    fileprivate var _customerName: String!
    
    fileprivate var _appointmentTimeInterval: Double!

    var appointmentTimeInterval: Double {
        get{
            return _appointmentTimeInterval
        }
        
        set(newInput){
            
            _appointmentTimeInterval = newInput
            
        }
    }
    
    var businessName: String {
        get{
            return _businessName
        }
        
        set(newInput){
            
            if newInput != ""{
                _businessName = newInput
            }
        }
    }
    
    var customerName: String {
        get{
            return _customerName
        }
        
        set(newInput){
            
            if newInput != ""{
                _customerName = newInput
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
    
    var status: String {
        get{
            return _status
        }
        
        set(newInput){
            
            if newInput != ""{
                _status = newInput
            }
        }
    }
    
    var timestamp: Double {
        get{
            return _timestamp
        }
        
        set(newInput){
            
            _timestamp = newInput
          
        }
    }
    
    var scheduledTime: String {
        get{
            return _scheduledTime
        }
        
        set(newInput){
            
            if newInput != ""{
                _scheduledTime = newInput
            }
        }
    }
    
    var leaderID: String {
        get{
            if let num = _leaderID{
                return num
            }else{
                return ""
            }
        }
        
        set(newInput){
            
            if newInput != ""{
                _leaderID = newInput
            }
        }
    }
    
    var businessID: String {
        get{
            return _businessID
        }
        
        set(newInput){
            
            if newInput != ""{
                _businessID = newInput
            }
        }
    }
    
    init(){
        
    }
    
    func castReservation(_ uuid: String, onComplete: ReservationCompletion?){
        
        FBDataService.instance.reservationsRef.child(uuid).observeSingleEvent(of: .value, with: { (snapshot) in

            guard snapshot.exists() else{
                return
            }
            
            let resDict = snapshot.value as! [String : AnyObject]
            
            if let id = resDict[RESERVATION_UID] as? String{
                self.uuid = id
            }
            if let status = resDict[RESERVATION_STATUS] as? String{
                self.status = status
            }
            if let timestamp = resDict[RESERVATION_TIMESTAMP] as? Double{
                self.timestamp = timestamp
            }
            if let time = resDict[RESERVATION_SCHEDULED_TIME] as? String{
                self.scheduledTime = time
            }
            if let leaderID = resDict[RESERVATION_PARTY_LEADER_ID] as? String{
                self.leaderID = leaderID
            }
            if let businessID = resDict[RESERVATION_BUSINESS_ID] as? String{
                self.businessID = businessID
            }
            if let timeInterval = resDict[RESERVATION_APPOINTMENT_TIME_INTERVAL] as? Double{
                self.appointmentTimeInterval = timeInterval
            }
            let customerObj = NewUser()
            customerObj.castUser(self.leaderID, onComplete: { (errMsg) in
                if errMsg == nil{
                    self.customerName = customerObj.fullName
                    
                    let businessObj = NewUser()
                    businessObj.castUser(self.businessID, onComplete: { (errMsg) in
                        if errMsg == nil{
                            self.businessName = businessObj.businessName
                            
                            onComplete?(nil)
                        }
                    })
                    
                }
            })
            
        }) { (error) in
            
            onComplete?(error.localizedDescription)
            
        }
        
    }
    
}





