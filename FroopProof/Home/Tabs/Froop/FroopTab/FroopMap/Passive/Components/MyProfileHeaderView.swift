//
//  MyProfileHeaderView.swift
//  FroopProof
//
//  Created by David Reed on 8/9/23.
//

import SwiftUI
import Kingfisher
import UIKit
import Combine

struct MyProfileHeaderView: View {
    @ObservedObject var dataController = DataController.shared
    @Binding var offsetY: CGFloat
    @ObservedObject var froopManager = FroopManager.shared
    var size: CGSize
    var safeArea: EdgeInsets
    @State private var selectedTab = 0

    
    private var headerHeight: CGFloat {
        (size.height * 0.5) + safeArea.top
    }
    
    private var headerWidth: CGFloat {
        (size.width * 1)
    }
    
    private var minimumHeaderHeight: CGFloat {
        100 + safeArea.top
    }
    
    private var minimumHeaderWidth: CGFloat {
        size.width
    }
    
    private var progress: CGFloat {
        max(min(-offsetY / (headerHeight - minimumHeaderHeight), 1), 0)
    }
    
    var body: some View {
        GeometryReader { _ in
            ZStack {
                ZStack (alignment: .top) {
                    Rectangle()
                        .fill(Color(.white).gradient)
                    
                    Rectangle()
                        .fill(Color(.black).gradient)
                        .opacity(0.7)
                        .frame(height: 225 * (2 - progress))
                }

                VStack(alignment: .center) {
                    HStack {
                        Spacer()
                        MyProfileImage(progress: progress, headerHeight: headerHeight)
                        Spacer()
                    }
                    .padding(.top, 85)
                    .offset(y: 35)
                    HStack {
                        Spacer()
                        Text("\(froopManager.myUserData.firstName) \(froopManager.myUserData.lastName)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .opacity(0.8)
                            .frame(alignment: .leading)
                            .myMoveText(progress, headerHeight, minimumHeaderHeight, headerWidth, minimumHeaderWidth)
                        Spacer()
                    }
                    .offset(y: 35)
                    
                    HStack {
                        Spacer()
                        Text("Your Description of what you want to say goes here.  You can put anything that fits in three lines.").italic()
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .opacity(0.6)
                            .lineLimit(3)
                            .fontWeight(.light)
                            .italic()
                            .frame(height: 75 - (1 * progress), alignment: .center)
                            .ignoresSafeArea()
                        Spacer()
                    }
                    .offset(y: 10)
//                    .padding(.leading, 25)
//                    .padding(.trailing, 25)
                    .opacity(1.0 * (1 - progress))

                    Spacer()
                }
                
                .padding(.top, safeArea.top)
                .padding(.bottom, 15)
            }
            .frame(height: (headerHeight + offsetY) < minimumHeaderHeight ? minimumHeaderHeight : (headerHeight + offsetY), alignment: .bottom)
            .offset(y: -offsetY)
        }
        .frame(height: headerHeight)
    }
}

struct MyProfileImage: View {
    var progress: CGFloat
    var headerHeight: CGFloat
    @ObservedObject var froopManager = FroopManager.shared
    
    var body: some View {
        GeometryReader {
            let rect = $0.frame(in: .global)
            let halfScaledHeight = (rect.height * 0.4) * 0.5
            let halfScaledWidth = (rect.width * 0.4) * 0.5
            let midY = rect.midY - rect.height / 2
            let midX = rect.midX - rect.width / 2
            let bottomPadding: CGFloat = 0
            let leadingPadding: CGFloat = 0
            let minimumHeaderHeight = 50
            let minimumHeaderWidth = 50
            let resizedOffsetY = (midY - (CGFloat(minimumHeaderHeight) - halfScaledHeight - bottomPadding))
            let resizedOffsetX = (midX - (CGFloat(minimumHeaderWidth) - halfScaledWidth - leadingPadding))
            
            HStack {
                Spacer()
                ZStack (alignment: .center){
                    Circle()
                        .aspectRatio(contentMode: .fit)
                        .offset(y: -resizedOffsetY * progress)
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.system(size: 30))
                        .fontWeight(.thin)
                        .offset(y: -resizedOffsetY * progress)
                }
                .frame(width: rect.width * 0.5, height: rect.height * 0.5)
                .scaleEffect(1 - (progress * 0.6), anchor: .center)

                Spacer()

            }
            .frame(width: headerHeight * 0.35, height: headerHeight * 0.35)
        }
    }
}

