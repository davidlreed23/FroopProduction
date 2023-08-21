//
//  Messages.swift
//  FroopProof
//
//  Created by David Reed on 7/25/23.
//

import SwiftUI
import Combine
import Firebase
import FirebaseFirestore

// Model for each message
struct Message: Identifiable, Hashable {
    let id: String
    let text: String
    let froopId: String
    let senderId: String
    let receiverId: String
    let timestamp: Timestamp
    let conversationId: String
    
    // Initializer from a Firestore Document
    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let text = data["text"] as? String,
              let froopId = data["froopId"] as? String,
              let senderId = data["senderId"] as? String,
              let receiverId = data["receiverId"] as? String,
              let timestamp = data["timestamp"] as? Timestamp,
              let conversationId = data["conversationId"] as? String else { return nil }
        
        self.id = document.documentID
        self.text = text
        self.froopId = froopId
        self.senderId = senderId
        self.receiverId = receiverId
        self.timestamp = timestamp
        self.conversationId = conversationId
    }
}

extension Message: Equatable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(froopId)
        hasher.combine(senderId)
        hasher.combine(receiverId)
        hasher.combine(timestamp)
        hasher.combine(conversationId)
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.text == rhs.text &&
        lhs.froopId == rhs.froopId &&
        lhs.senderId == rhs.senderId &&
        lhs.receiverId == rhs.receiverId &&
        lhs.timestamp == rhs.timestamp &&
        lhs.conversationId == rhs.conversationId
    }
}
