//
//  Collection.swift
//  FirebasePractice
//
//  Created by Yi-Chin Hsu on 2021/9/23.
//

import Foundation

enum Collection: CaseIterable{
    case articles
    case users
    case friends
    
    var title: String {
        switch self {
        case .articles:
            return "Articles"
        case .users:
            return "Users"
        case .friends:
            return "Friends"
        }
    }
    
}

enum Users: CaseIterable {
    
    case id
    case email
    case name
    
    var field: String {
        switch self {
        case .id:
            return "id"
        case .email:
            return "email"
        case .name:
            return "name"
        }
    }
    
}

enum Friends: CaseIterable {
    
    
    case userID
    case friendList
    case invitationList
    
    var field: String {
        
        switch self {
        case .userID:
            return "user_id"
        case .friendList:
            return "friend_list"
        case .invitationList:
            return "invitation_list"
        }
        
    }
    
}
