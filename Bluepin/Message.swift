//
//  Message.swift
//  Bizmi
//
//  Created by Alex on 10/2/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import Foundation

typealias MessageCompletion = (_ errMsg: String?) -> Void

class Message{
    
    fileprivate var _messageID: String!
    fileprivate var _messageType: String!
    fileprivate var _messageData: String!
    fileprivate var _senderUID: String!
    fileprivate var _recipientUID: String!
    fileprivate var _channelName: String!
    
    fileprivate var _timeStamp: String!
    fileprivate var _messageLocation: String!
    
    fileprivate var _timeStampDouble: Double!

    fileprivate var _senderUserObj: NewUser!
    fileprivate var _recipientuserObj: NewUser!

    
    var timeStampDouble: Double {
        get{
            return _timeStampDouble
        }
        
        set(timeStamp){
            
            _timeStampDouble = timeStamp
            
        }
    }
    
    var messageLocation: String {
        get{
            return _messageLocation
        }
        
        set(newLocation){
            
            if newLocation != ""{
                _messageLocation = newLocation
            }
        }
    }
    
    var senderUserObj: NewUser {
        get{
            return _senderUserObj
        }
        
        set(senderUser){
            
            _senderUserObj = senderUser
            
        }
    }
    
    var recipientUserObj: NewUser {
        get{
            return _recipientuserObj
        }
        
        set(recipientUser){
            
            _recipientuserObj = recipientUser
            
        }
    }
    
    var messageType: String {
        get{
            return _messageType
        }
        
        set(newType){
            
            if newType != ""{
                _messageType = newType
            }
        }
    }
    
    var messageData: String {
        get{
            return _messageData
        }
        
        set(newData){
            
            if newData != ""{
                _messageData = newData
            }
        }
    }
    
    var senderUID: String {
        get{
            return _senderUID
        }
        
        set(senderUID){
            
            if senderUID != ""{
                _senderUID = senderUID
            }
        }
    }
    
    var recipientUID: String {
        get{
            return _recipientUID
        }
        
        set(recipientUID){
            
            if recipientUID != ""{
                _recipientUID = recipientUID
            }
        }
    }
    
    var timeStamp: String {
        get{
            return _timeStamp
        }
        
        set(timeStamp){
            
            _timeStamp = timeStamp
            
        }
    }
    
    var channelName: String {
        get{
            return _channelName
        }
        
        set(channelName){
            
            if channelName != ""{
                _channelName = channelName
            }
        }
    }
    
    var messageID: String {
        get{
            return _messageID
        }
        
        set(newInput){
            
            if newInput != ""{
                _messageID = newInput
            }
        }
    }
    
    init(){
        
    }
    
    init(messageType: String, messageData: String, senderUID: String, recipientUID: String, channelName: String){
    
        self.messageType = messageType
        self.messageData = messageData
        self.senderUID = senderUID
        self.recipientUID = recipientUID
        self.channelName = channelName
        
    }
    
    func castMessage(_ uuid: String, onComplete: MessageCompletion?){
        
        FBDataService.instance.messagesRef.child(uuid).observeSingleEvent(of: .value, with: { (snapshot) in

            guard snapshot.exists() else{
                return
            }
            
            let messageDict = snapshot.value as! [String : AnyObject]
            
            if let id = messageDict[MESSAGE_UID] as? String{
                print(id)
                self.messageID = id
            }
            if let type = messageDict[MESSAGE_TYPE] as? String{
                self.messageType = type
            }
            
            if let senderID = messageDict[MESSAGE_SENDERID] as? String{
                self.senderUID = senderID
            }
            
            if let recID = messageDict[MESSAGE_RECIPIENTID] as? String{
                self.recipientUID = recID
            }
            
            if let stamp = messageDict[MESSAGE_TIMESTAMP] as? Double{
                
                let date = NSDate(timeIntervalSince1970: stamp/1000)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEE MMM dd  "
                let dateString = dateFormatter.string(from: date as Date)
                
                self.timeStamp = dateString
                self.timeStampDouble = stamp
            }
            
            if let channel = messageDict[MESSAGE_CHANNEL_NAME]as? String{
                self.channelName = channel
            }
            
            if let loc = messageDict[MESSAGE_LOCATION] as? String{
                
                self.messageLocation = loc
                
                FBDataService.instance.messagesStorageRef.child(loc).data(withMaxSize: 10 * 1024 * 1024) { (data, error) -> Void in
                    if (error != nil) {
                        onComplete?(error?.localizedDescription)
                    } else {
                        if self.messageType == MESSAGE_TEXT_TYPE{
                            self.messageData = String(data: data!, encoding: String.Encoding.utf8)!
                            
                            self._senderUserObj = NewUser()
                            self.senderUserObj.castUser(self.senderUID, onComplete: { (errMsg) in
                                if errMsg == nil{
                                
                                    self._recipientuserObj = NewUser()
                                    self.recipientUserObj.castUser(self.recipientUID, onComplete: { (errMsg) in
                                        if errMsg == nil{
                                            onComplete?(nil)
                                        }
                                    })
                                    
                                }
                            })
                            
                        }
                        
                    }
                }
                
            }
            
            
            
            
        }){ (error) in
            onComplete?(error.localizedDescription)
        }
        
    }
}





