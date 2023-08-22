//
//  ProfileCompletionView1.swift
//  FroopProof
//
//  Created by David Reed on 1/19/23.
//

import SwiftUI
import iPhoneNumberField
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift


struct ProfileCompletionView1: View {

    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var froopDataListener = FroopDataListener.shared
    
    var PCtotalPages = 6
    @AppStorage("ProfileCompletionCurrentPage") var ProfileCompletionCurrentPage = 1
    
    var body: some View {
        NavigationView{
            ZStack {
                ScrollView (showsIndicators: false) {
                    VStack {
                        ProfileCompletionTitleView()
                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Froop Sports")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button{
                        if ProfileCompletionCurrentPage <= PCtotalPages {
                            ProfileCompletionCurrentPage += 1
                            PrintControl.shared.printProfile(ProfileCompletionCurrentPage.description)
                        }
                    }label:{
                        Text("Next")
                            .foregroundColor(.primary)
                        Image(systemName: "arrow.right.square.fill")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
}
