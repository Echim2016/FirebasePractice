//
//  Tag.swift
//  FirebasePractice
//
//  Created by Yi-Chin Hsu on 2021/9/22.
//

import Foundation

enum Tag: Int, CaseIterable{
    
    case beauty = 0
    case gossiping
    case schoolLife
    
    var title: String {
        switch self {
        case .beauty:
            return "Beauty"
        case .gossiping:
            return "Gossiping"
        case .schoolLife:
            return "SchoolLife"
        }
    }
    
}
