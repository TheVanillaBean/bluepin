////
////  NewUser.swift
////  Bizmi
////
////  Created by Alex on 9/18/16.
////  Copyright © 2016 Alex. All rights reserved.
////
//
//import Foundation
//
//typealias UserCompletion = (_ errMsg: String?) -> Void
//
//class Reservation{
//    
//    fileprivate var _uuid: String!
//    fileprivate var _status: String!
//    fileprivate var _timestamp: String!
//    fileprivate var _size: String!
//    fileprivate var _scheduledTime: String!
//    fileprivate var _leaderID: String!
//    fileprivate var _businessID: String!
//    
//    var uuid: String {
//        get{
//            return _uuid
//        }
//        
//        set(newUUID){
//            
//            if newUUID != ""{
//                _uuid = newUUID
//            }
//        }
//    }
//    
//    var status: String {
//        get{
//            return _status
//        }
//        
//        set(newInput){
//            
//            if newInput != ""{
//                _status = newInput
//            }
//        }
//    }
//    
//    var timestamp: String {
//        get{
//            return _timestamp
//        }
//        
//        set(newInput){
//            
//            if newInput != ""{
//                _timestamp = newInput
//            }
//        }
//    }
//    
//    
//    var size: String {
//        get{
//            return _size
//        }
//        
//        set(newInput){
//            
//            if newInput != ""{
//                _size = newInput
//            }
//        }
//    }
//    
//    var scheduledTime: String {
//        get{
//           return _scheduledTime
//        }
//        
//        set(newInput){
//            
//            if newInput != ""{
//                _scheduledTime = newInput
//            }
//        }
//    }
//    
//    var leaderID: String {
//        get{
//            if let num = _leaderID{
//                return num
//            }else{
//                return ""
//            }
//        }
//        
//        set(newInput){
//            
//            if newInput != ""{
//                _leaderID = newInput
//            }
//        }
//    }
//    
//    var businessID: String {
//        get{
//            return _businessID
//        }
//        
//        set(newInput){
//            
//            if newInput != ""{
//                _businessID = newInput
//            }
//        }
//    }
//    
//    init(){
//        
//    }
//    
//    func castUser(_ uuid: String, onComplete: UserCompletion?){
//        
//        FBDataService.instance.reservationsRef.child(uuid).observeSingleEvent(of: .value, with: { (snapshot) in
//            // Get user value
//            let resDict = snapshot.value as! [String : AnyObject]
//            
//                if let id = resDict[RESERVATION_UID] as? String{
//                    self.uuid = id
//                }
//                if let status = resDict[RESERVATION_STATUS] as? String{
//                    self.status = status
//                }
//                if let timestamp = resDict[RESERVATION_TIMESTAMP] as? String{
//                    self.timestamp = timestamp
//                }
//                if let size = resDict[RESERVATION_SIZE]as? String{
//                    self.size = size
//                }
//                if let time = resDict[RESERVATION_SCHEDULED_TIME] as? String{
//                    self.scheduledTime = time
//                }
//                if let leaderID = resDict[RESERVATION_PARTY_LEADER_ID] as? String{
//                    self.leaderID = leaderID
//                }
//                if let businessID = resDict[RESERVATION_BUSINESS_ID] as? String{
//                    self.businessID = businessID
//                }
//                
//                onComplete?(nil)
//            
//            }) { (error) in
//                
//                onComplete?(error.localizedDescription)
//                
//                print(error.localizedDescription)
//            }
//        
//    }
//    
//}
//
//
//
//
//
