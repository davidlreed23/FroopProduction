//
//  HVBackGroundComponent.swift
//  FroopProof
//
//  Created by David Reed on 2/4/23.
//

import SwiftUI
import UIKit


struct HVBackGroundComponent: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var myData = MyData.shared
    
    
    
    var body: some View {
        ZStack (alignment: .top){
            
//            Image("F_bkg1")
//                .resizable()
//                .scaledToFit()
//                .scaleEffect(x: 1, y: -1)
//                .offset(y: 700)
//            Image("F_bkg1")
//                .resizable()
//                .scaledToFit()
//                .ignoresSafeArea()
     
            VStack{
                
                ZStack (alignment: .top){
                    
                    Rectangle()
                        .frame(minWidth: 0,maxWidth: .infinity, minHeight: 250, maxHeight: 250, alignment: .top)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .opacity(colorScheme == .dark ? 0.25 : 0.75)
                        .offset(y: 0)
                        .padding(.top, 20)
                }
            }
            .toolbar{
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    
                }
            }
        }
    }
}


