//
//  Channel.swift
//  Bluepin
//
//  Created by Alex on 6/8/17.
//  Copyright © 2017 Alex Alimov. All rights reserved.
//

import Foundation

class Channel{

    fileprivate var _channelID: String!
    fileprivate var _date: Date!

    var channelID: String {
        get{
            return _channelID
        }
        
        set(newInput){
            
            if newInput != ""{
                _channelID = newInput
            }
        }
    }
    
    var date: Date {
        get{
            return _date
        }
        
        set(newInput){
       
           _date = newInput
            
        }
    }
    
    init(channelID: String?, date: Date?){
        
        if let channel = channelID, let timestamp = date{
            self.channelID = channel
            self.date = timestamp
        }
        
    }
    
    init(){
    }

}
