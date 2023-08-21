//
//  FroopTypeStore.swift
//  FroopProof
//
//  Created by David Reed on 1/19/23.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import UIKit

class FroopTypeStore: ObservableObject {
    static let shared = FroopTypeStore()
    
    @Published var froopTypes: [FroopType] = []
    @ObservedObject var froopType: FroopType = FroopType(dictionary: [:])
    
    private var db = Firestore.firestore()
    
    init() {
        getFroopTypes()
    }
    
    func getFroopTypes() {
        
        let froopTypeRef = db.collection("froopTypes")
        var froopTypes: [FroopType] = []
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        froopTypeRef .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting froop type documents: \(err)")
                
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let froopType = FroopType(dictionary: data)
                    froopTypes.append(froopType)
                }
            }
            dispatchGroup.leave()
            self.froopTypes = froopTypes
        }
    }
}
