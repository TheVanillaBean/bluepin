//
//  Constants.swift
//  Bluepin
//
//  Created by Alex on 7/19/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import Foundation
import UIKit

//API Keys
let sinchApplicationKey = "fb9c06d5-53e7-4d60-83d0-cb853587884a";


//User Interface
let SHADOW_COLOR: CGFloat = 157.0 / 255.0
let ACCENT_COLOR: UIColor = UIColor(red: 255.0/255.0, green: 87.0/255.0, blue: 34.0/255.0, alpha: 1.0)
let DARK_PRIMARY_COLOR: UIColor = UIColor(red: 2.0/255.0, green: 136.0/255.0, blue: 209.0/255.0, alpha: 1.0)
let PRIMARY_COLOR: UIColor = UIColor(red: 3.0/255.0, green: 169.0/255.0, blue: 244.0/255.0, alpha: 1.0)
let LIGHT_PRIMARY_COLOR: UIColor = UIColor(red: 179.0/255.0, green: 229.0/255.0, blue: 252.0/255.0, alpha: 1.0)
let DIVIDER_COLOR: UIColor = UIColor(red: 182.0/255.0, green: 182.0/255.0, blue: 182.0/255.0, alpha: 1.0)

//User Types
let USER_BUSINESS_TYPE: String = "Business"
let USER_CUSTOMER_TYPE: String = "Customer"

//Firebase KEYS

//Users
let UUID: String = "uuid"
let EMAIL: String = "email"
let USER_TYPE: String = "userType"
let FULL_NAME: String = "fullName"
let PHONE_NUMBER: String = "phoneNumber"
let PHONE_NUMBER_VERIFIED: String = "phoneNumberVerified"
let PASSWPRD: String = "password"
let BUSINESS_NAME: String = "businessName"
let BUSINESS_TYPE: String = "businessType"
let BUSINESS_DESC: String = "businessDesc"
let BUSINESS_WEBSITE: String = "businessWebsite"
let BUSINESS_HOURS: String = "businessHours"
let BUSINESS_LOCATION: String = "businessLocation"
let PROFILE_PIC_LOCATION: String = "userProfilePicLocation"
let DEVICE_TOKEN: String = "deviceToken"

//Firebase Messages

let MESSAGE_UID: String = "messageID"
let MESSAGE_TYPE: String = "messageType"
let MESSAGE_LOCATION: String = "messageLocation"
let MESSAGE_TEXT: String = "messageText"
let MESSAGE_DATA: String = "messageData"
let MESSAGE_SENDERID: String = "senderUID"
let MESSAGE_RECIPIENTID: String = "recipientUID"
let MESSAGE_TIMESTAMP: String = "timeStamp"
let MESSAGE_CHANNEL_NAME: String = "channelName"
let MESSAGE_RECIPIENT_NAME: String = "recipientName"
let MESSAGE_SENDER_NAME: String = "senderName"

let MESSAGE_TEXT_TYPE: String = "type/text"

//Channel Keys
let CHANNEL_ID: String = "ChannelID"
let SORT_TIMESTAMP: String = "sortTimestamp"

//Firebase Notification Requests
let REQUEST_ID: String = "requestID"
let REQUEST_SENDER_ID: String = "senderID"
let REQUEST_RECIPIENT_ID: String = "recipientID"
let REQUEST_SENDER_NAME: String = "senderName"
let REQUEST_MESSAGE: String = "message"


let MESSAGE_NOTIF = "Message"
let NEW_RESERVATION_NOTIF = "Reservation"
let EXISTING_RESERVATION_NOTIF = "ReservationChange"
let DELETED_RESERVATION_NOTIF = "ReservationDeleted"
let ACCEPTED_RESERVATION_NOTIF = "AcceptedRes"
let DECLINED_RESERVATION_NOTIF = "DeclinedRes"

//Firebase Reservations
let RESERVATION_UID = "uuid"
let RESERVATION_STATUS = "status"
let RESERVATION_TIMESTAMP = "timestamp"
let RESERVATION_SCHEDULED_TIME = "scheduledTime"
let RESERVATION_PARTY_LEADER_ID = "leaderID"
let RESERVATION_PARTY_LEADER_NAME = "leaderName"
let RESERVATION_BUSINESS_ID = "businessID"
let RESERVATION_BUSINESS_NAME = "businessName"
let RESERVATION_APPOINTMENT_TIME_INTERVAL = "appointmentTimeInterval"

let PENDING_STATUS = "pending"
let ACTIVE_STATUS = "active"
let INACTIVE_STATUS = "inactive"
let DECLINED_STATUS = "declined"

//CHILD NODES
let FIR_CHILD_USERS = "Users"
let FIR_CHILD_USERS_BUSINESS = "Business-Users"
let FIR_CHILD_USERS_CUSTOMER = "Customer-Users"
let FIR_CHILD_USER_CHANNELS = "Channels-Users"
let FIR_CHILD_CHANNELS = "Channels-Messages"
let FIR_CHILD_CHANNEL_IDS = "ChannelIDS"
let FIR_CHILD_MESSAGES = "Messages"
let FIR_CHILD_RESERVATIONS = "Reservations"
let FIR_CHILD_NOTIFICATIONS = "NotificationRequests"
let FIR_CHILD_CUSTOMER_FOLLOWERS = "Customer-Followers"
let FIR_CHILD_BUSINESS_FOLLOWERS = "Business-Followers"
let FIR_CHILD_USER_RESERVATIONS = "User-Reservations"

//STORAGE NODES
let FIR_STORAGE_CHILD_USER_PROFILE_PICS = "Profile-Pictures"
let FIR_STORAGE_CHILD_MESSAGES = "Messages"

//EMPTY DATA SETS
let EMPTY_DATA_WELCOME = "Welcome"
let EMPTY_MESSAGES_DATA_SET_BUSINESS = "You do not have any messages yet. Whenever a customer messages you, the conversation will show up here."
let EMPTY_FOLLOWERS_DATA_SET_BUSINESS = "You do not have any followers yet. Tell your customers to download Bluepin and subscribe to your business page. They will then show up here."
let EMPTY_RESERVATION_DATA_SET_BUSINESS = "You do not have any reservations yet. You can make a reservation for a customer by pressing the + button in the toolbar. Your customers will recieve a pending reservation and will have the option to accept or decline the reservation. All reservations will show up here."
let EMPTY_MESSAGES_DATA_SET_CUSTOMER = "You do not have any messages yet. Whenever you message a business, the conversation will show up here."
let EMPTY_BUSINESSES_DATA_SET_CUSTOMER = "There are currently no businesses in your area that use Bluepin. Contact a local business and refer them to Bluepin."
let EMPTY_RESERVATION_DATA_SET_CUSTOMER = "You do not have any reservations yet. Whenever a business sends you a reservation, it will show up here as pending. You will then have the option to accept or decline the reservation."



