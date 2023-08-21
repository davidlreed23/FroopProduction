//
//  ProfileView.swift
//  FroopProof
//
//  Created by David Reed on 1/18/23.
//
//
//import SwiftUI
//import UIKit
//import Firebase
//import FirebaseFirestore
//import FirebaseFirestoreSwift
//import FirebaseAuth
//import FirebaseCore
//import FirebaseStorage
//import Kingfisher
//
//struct ProfileView: View {
//    @Environment(\.colorScheme) var colorScheme
//    @ObservedObject var myData = MyData.shared
//    @Binding var showEditView: Bool
//    @Binding var showAlert: Bool
//    @Binding var alertMessage: String
//    @State private var profileImageUrl: URL?
//    @State private var showSheet = true
//    var uid = FirebaseServices.shared.uid
//    var db = FirebaseServices.shared.db
//    @State var showProfileImagePicker = false
//    @State private var avatarImage: UIImage?
//    @State var selectedImage: UIImage?
//    @State var urlHolder: String
//
//    var body: some View {
//        ZStack (alignment: .top){
//            Rectangle()
//                .frame(minWidth: 0,maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
//                .foregroundColor(.gray)
//                .opacity(0.2)
//                .ignoresSafeArea()
//
//
//            VStack {
//                ZStack(alignment: .top) {
//                    Rectangle()
//                        .frame(minWidth: 0,maxWidth: .infinity, minHeight: 175, maxHeight: 175, alignment: .top)
//                        .foregroundColor(.black)
//                        .opacity(0.5)
//                        .ignoresSafeArea()
//                        .offset(y: -50)
//                    HStack{
//                        Spacer()
//                        Text("Profile")
//                            .foregroundColor(colorScheme == .dark ? .white : .black)
//                            .fontWeight(.light)
//                        Spacer()
//                    }
//                    .offset(y: -45)
//                    HStack{
//                        Spacer()
//
//                        VStack{
//
//
//                            KFImage(URL(string: (String(describing: profileImageUrl))))
//                                .placeholder {
//                                    ProgressView()
//                                }
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: 126, height: 126)
//                                .clipShape(Circle())
//                                .padding()
//                                .onTapGesture {
//                                    showProfileImagePicker = true
//                                }
//                                .onAppear {
//                                    FirebaseServices.shared.getDownloadUrl(uid: uid) { url in
//                                        self.profileImageUrl = url
//                                    }
//                                }
//
//
//                            Text("Profile Picture")
//                                .font(.system(size: 10, weight: .light))
//                                .foregroundColor(.gray)
//                                .offset(y: -10)
//                        }
//
//                        Spacer()
//
//                    }
//                    .padding(.top, 50)
//
//                }
//
//                List {
//                    Section(header: Text("Name")) {
//                        Text(MyData.shared.firstName)
//                        Text(MyData.shared.lastName)
//                    }
//                    Section(header: Text("Contact")) {
//                        Text(MyData.shared.phoneNumber)
//                    }
//                    Section(header: Text("Address")) {
//                        Text(MyData.shared.addressNumber)
//                        Text(MyData.shared.addressStreet)
//                        Text(MyData.shared.unitName)
//                        Text(MyData.shared.addressCity)
//                        Text(MyData.shared.addressState)
//                        Text(MyData.shared.addressZip)
//                        Text(MyData.shared.addressCountry)
//                        Text(MyData.shared.profileImageUrl)
//                    }
//                }
//                .scrollContentBackground(.hidden)
//
//            }
//        }
//        .toolbar{
//            ToolbarItemGroup(placement: .navigationBarTrailing) {
//                Button{
//
//
//                }label:{
//                    Text("Edit")
//                        .foregroundColor(colorScheme == .dark ? .white : .black)
//                    Image(systemName: "square.and.arrow.right.fill")
//                        .foregroundColor(colorScheme == .dark ? .white : .black)
//                }
//            }
//        }
//
//    }
//
//}
//
//
