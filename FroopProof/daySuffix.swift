//
//  daySuffix.swift
//  FroopProof
//
//  Created by David Reed on 3/1/23.
//

import Foundation

public extension Int {
    func daySuffix() -> String {
        switch self {
        case 11...13: return "th"
        default:
            switch self % 10 {
            case 1: return "st"
            case 2: return "nd"
            case 3: return "rd"
            default: return "th"
            }
        }
    }
}
