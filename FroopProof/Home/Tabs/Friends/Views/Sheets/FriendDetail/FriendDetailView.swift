//
//  FriendDetailView.swift
//  FroopProof
//
//  Created by David Reed on 2/16/23.
//

import SwiftUI
import UserNotifications

struct FriendDetailView: View {
    @ObservedObject var dataController = DataController.shared

    @Binding var selectedFriend: UserData
    @State var showInviteView = false
    @State var profileView: Bool = true
   
    
    
    var body: some View {
        ZStack {
            
            GeometryReader {
                let size = $0.size
                let safeArea = $0.safeAreaInsets
                
                FroopLandingView(size: size, safeArea: safeArea, profileView: $profileView, selectedFriend: $selectedFriend)
                    .ignoresSafeArea(.all, edges: .top)
            }
            
            if dataController.allSelected > 0 {
                VStack {
                    Spacer()
                    ZStack {
                        Rectangle()
                            .foregroundColor(.black)
                            .opacity(0.7)
                            .frame(height: 100)
                        Text("Invite to a Froop")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .fontWeight(.thin)
                            .padding(.horizontal)
                            .padding(.bottom, 40)
                    }
                    .transition(.opacity)
                    
                }
                .ignoresSafeArea()
            } else {
                EmptyView()
            }
        }
    }
}

