//
//  ProfileCompletionExtensions.swift
//  FroopProof
//
//  Created by David Reed on 1/19/23.
//

import Foundation
import SwiftUI
import iPhoneNumberField
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift


extension Text {
    func CcustomTitleText() -> Text {
        self
            .fontWeight(.light)
            .font(.system(size: 36))
    }
}

extension Color {
    static var CmainColor = Color(UIColor.systemIndigo)
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
