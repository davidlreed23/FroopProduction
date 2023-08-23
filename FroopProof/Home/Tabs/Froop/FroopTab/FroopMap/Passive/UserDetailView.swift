//
//  UserDetailView.swift
//  FroopProof
//
//  Created by David Reed on 2/16/23.
//

import SwiftUI
import UserNotifications

struct UserDetailView: View {
    @ObservedObject var dataController = DataController.shared
    @State var showInviteView = false
    @State var profileView: Bool = true
    @Binding var selectedTab: Int

    
    
    var body: some View {
        ZStack {
            
            GeometryReader {
                let size = $0.size
                let safeArea = $0.safeAreaInsets
                
                MyFroopLandingView(size: size, safeArea: safeArea, selectedTab: $selectedTab)
                    .ignoresSafeArea()
            }
        }
    }
}

