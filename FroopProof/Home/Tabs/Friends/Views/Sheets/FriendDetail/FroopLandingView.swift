//
//  FroopLandingView.swift
//  FroopProof
//
//  Created by David Reed on 8/9/23.
//

import SwiftUI

struct FroopLandingView: View {
    @ObservedObject var dataController = DataController.shared
    var size: CGSize
    var safeArea: EdgeInsets
    @Binding var selectedFriend: UserData
    @Binding var profileView: Bool
    @State var friendsView: Bool = false
    @State private var offsetY: CGFloat = 0
    
    
    var body: some View {
        ZStack {
            ScrollViewReader { scrollProxy in
                ZStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 5) {
                            ProfileHeaderView(offsetY: $offsetY, selectedFriend: $selectedFriend, profileView: $profileView, size: size, safeArea: safeArea)
                                .zIndex(1000)
                                .ignoresSafeArea()
                            
                            if profileView {
                                FriendFroopsView(selectedFriend: $dataController.selectedUser)
                                    .transition(.opacity)
                            } else {
                                FriendListView(selectedFriend: $dataController.selectedUser)
                                    .transition(.opacity)
                            }
                        }
                        .id("SCROLLVIEW")
                        .background {
                            ScrollDetector { offset in
                                offsetY = -offset
                            } onDraggingEnd: { offset, velocity in
                                /// Resetting to Intial State, if not Completely Scrolled
                                let headerHeight = (size.height * 0.3) + safeArea.top
                                let minimumHeaderHeight = 65 + safeArea.top
                                
                                let targetEnd = offset + (velocity * 45)
                                if targetEnd < (headerHeight - minimumHeaderHeight) && targetEnd > 0 {
                                    withAnimation(.interactiveSpring(response: 0.55, dampingFraction: 0.65, blendDuration: 0.65)) {
                                        scrollProxy.scrollTo("SCROLLVIEW", anchor: .top)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}




extension View {
    func moveText(_ progress: CGFloat, _ headerHeight: CGFloat, _ headerWidth: CGFloat, _ minimumHeaderHeight: CGFloat, _ minimumHeaderWidth: CGFloat) -> some View {
        self
            .hidden()
            .overlay {
                GeometryReader { proxy in
                    let rect = proxy.frame(in: .global)
                    //let minX = rect.minX
                    let midY = rect.midY
                    // let midTarget = 0
                    // let delta = rect.width - 125
                    // let adjustededX = rect.width - delta
                    /// Half Scaled Text Height (Since Text Scaling will be 0.85 (1 - 0.15))
                    let halfScaledTextHeight = (rect.height * 0.85) / 2
                    // let halfScaledTextWidth = (rect.width * 0.85) / 2
                    /// Profile Image
                    let profileImageHeight = (headerHeight * 0.9)
//                    let profileImageWidth = (headerWidth * 0.9)
                    /// Since Image Scaling will be 0.3 (1 - 0.7)
                    let scaledImageHeight = profileImageHeight * 0.3
                    //let scaledImageWidth = profileImageWidth * 0.3
                    // let halfScaledImageHeight = scaledImageHeight / 2
                    // let halfScaledImageWidth = scaledImageWidth / 2
                    /// Applied VStack Spacing is 15
                    /// 15 / 0.3 = 4.5 (0.3 -> Image Scaling)
                    let vStackSpacing: CGFloat = 4.5
                    let resizedOffsetY = (midY - (minimumHeaderHeight - halfScaledTextHeight - vStackSpacing - scaledImageHeight))
                    // let resizedOffsetX = ((125) - (rect.width / 2))
                    
                    self
                        .scaleEffect(1 - (progress * 0.15))
                        .offset(y: -resizedOffsetY * progress)
                    //.offset(x: -resizedOffsetX * progress)
                }
            }
    }
    func moveSymbols(_ progress: CGFloat, _ headerHeight: CGFloat, _ headerWidth: CGFloat, _ minimumHeaderHeight: CGFloat, _ minimumHeaderWidth: CGFloat) -> some View {
        self
            .hidden()
            .overlay {
                GeometryReader { proxy in
                    let rect = proxy.frame(in: .global)
                    let minX = rect.minX
                    let midY = rect.midY
                    /// Half Scaled Text Height (Since Text Scaling will be 0.85 (1 - 0.15))
                    let halfScaledTextHeight = (rect.height * 1) / 2
                    // let halfScaledTextWidth = (rect.width * 1) / 2
                    /// Profile Image
                    let profileImageHeight = (headerHeight * 0.9)
//                    let profileImageWidth = (headerWidth * 0.9)
                    /// Since Image Scaling will be 0.3 (1 - 0.7)
                    let scaledImageHeight = profileImageHeight * 0.3
                    //let scaledImageWidth = profileImageWidth * 0.3
                    // let halfScaledImageHeight = scaledImageHeight / 2
                    // let halfScaledImageWidth = scaledImageWidth / 2
                    /// Applied VStack Spacing is 15
                    /// 15 / 0.3 = 4.5 (0.3 -> Image Scaling)
                    let vStackSpacing: CGFloat = 4.5
                    let resizedOffsetY = (midY - (minimumHeaderHeight - halfScaledTextHeight - vStackSpacing - scaledImageHeight))
                    let resizedOffsetX = (minX)
                    
                    self
                        .scaleEffect(1 - (progress * 1))
                        .offset(y: -resizedOffsetY * progress / 2)
                        .offset(x: -resizedOffsetX * progress)
                        .opacity(1 - progress)
                }
            }
    }
    
    func moveMenu(_ progress: CGFloat, _ headerHeight: CGFloat, _ headerWidth: CGFloat, _ minimumHeaderHeight: CGFloat, _ minimumHeaderWidth: CGFloat) -> some View {
        self
            .hidden()
            .overlay {
                GeometryReader { proxy in
                    let rect = proxy.frame(in: .global)
                    //let minX = rect.minX
                    let midY = rect.midY
                    /// Half Scaled Text Height (Since Text Scaling will be 0.85 (1 - 0.15))
                    let halfScaledTextHeight = (rect.height * 1) / 2
                    /// Profile Image
                    let profileImageHeight = (headerHeight * 0.9)
//                    let profileImageWidth = (headerWidth * 0.9)
                    /// Since Image Scaling will be 0.3 (1 - 0.7)
                    let scaledImageHeight = profileImageHeight * 0.3
                    // let scaledImageWidth = profileImageWidth * 0.3
                    /// Applied VStack Spacing is 15
                    /// 15 / 0.3 = 4.5 (0.3 -> Image Scaling)
                    let vStackSpacing: CGFloat = 4.5
                    let resizedOffsetY = (midY - (minimumHeaderHeight - halfScaledTextHeight - vStackSpacing - scaledImageHeight + 65))
                    // let resizedOffsetX = 0
                    
                    self
                        .scaleEffect(1)
                        .offset(y: -resizedOffsetY * progress)
                    //.offset(x: -resizedOffsetX * progress)
                }
            }
    }
}
