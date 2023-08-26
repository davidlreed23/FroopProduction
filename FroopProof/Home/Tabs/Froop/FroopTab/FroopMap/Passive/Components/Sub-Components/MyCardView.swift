//
//  MyCardsView.swift
//  FroopProof
//
//  Created by David Reed on 8/9/23.
//


import SwiftUI
import Kingfisher

struct MyCardsView: View {

    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var locationServices = LocationServices.shared
    @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var froopTypeStore = FroopTypeStore.shared
    
    let currentUserId = FirebaseServices.shared.uid
    let index: Int
    var db = FirebaseServices.shared.db
    let froopHostAndFriends: FroopHistory
    @State private var offset: CGFloat = 0
    @State private var isDragging = false
    @State private var hostFirstName: String = ""
    @State private var hostLastName: String = ""
    @State private var hostURL: String = ""
    @State private var showAlert = false
    @State private var selectedImageIndex = 0
    @State private var isMigrating = false
    @State private var isDownloading = false
    @State private var downloadedImages: [String: Bool] = [:]
    @State private var isImageSectionVisible: Bool = true
    @State private var froopTypeArray: [FroopType] = []
    @State private var thisFroopType: String = ""
    
   // @Namespace private var animation
    
    init(index: Int, froopHostAndFriends: FroopHistory, thisFroopType: String) {
        self.index = index
        self.froopHostAndFriends = froopHostAndFriends
    }
    
    var body: some View {
        ZStack {
            VStack (){
                HStack {
                    KFImage(URL(string: froopHostAndFriends.host.profileImageUrl))
                        .placeholder {
                            ProgressView()
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50, alignment: .leading)
                        .clipShape(Circle())
                        .padding(.leading, 10)
                        .padding(.top, 5)
                    VStack (alignment:.leading){
                        Text(froopHostAndFriends.froop.froopName)
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(colorScheme == .dark ? .black : .black)
                            .multilineTextAlignment(.leading)
                            .offset(y: 6)
                        HStack (alignment: .center){
                            Text("Host:")
                                .font(.system(size: 14))
                                .fontWeight(.light)
                                .foregroundColor(colorScheme == .dark ? .black : .black)
                                .multilineTextAlignment(.leading)
                            
                            Text(froopHostAndFriends.host.firstName)
                                .font(.system(size: 14))
                                .fontWeight(.light)
                                .foregroundColor(colorScheme == .dark ? .black : .black)
                                .multilineTextAlignment(.leading)
                            
                            Text(froopHostAndFriends.host.lastName)
                                .font(.system(size: 14))
                                .fontWeight(.light)
                                .foregroundColor(colorScheme == .dark ? .black : .black)
                                .multilineTextAlignment(.leading)
                                .offset(x: -5)
                        }
                        .offset(y: 6)
                        
                        Text("\(formatDate(for: froopHostAndFriends.froop.froopStartTime))")
                            .font(.system(size: 14))
                            .fontWeight(.thin)
                            .foregroundColor(colorScheme == .dark ? .black : .black)
                            .multilineTextAlignment(.leading)
                            .padding(.top, 2)
                            .offset(y: -6)
                    }
                    .padding(.top, 5)
                    
                    Spacer()
                    
                }
                .background(Color(red: 251/255, green: 251/255, blue: 249/255))
//                .padding(.horizontal, 10)
                .padding(.bottom, 1)
                .frame(maxHeight: 60)

                ZStack {
                    Rectangle()
                        .frame(minWidth: UIScreen.main.bounds.width, maxWidth: UIScreen.main.bounds.width, minHeight: UIScreen.main.bounds.width * 1.3333, maxHeight: UIScreen.main.bounds.width * 1.3333)
                        .foregroundColor(.white)
                    TabView(selection: $selectedImageIndex) {
                        ForEach(froopHostAndFriends.froop.froopDisplayImages.indices, id: \.self) { index in
                            VStack () {
                                KFImage(URL(string: froopHostAndFriends.froop.froopDisplayImages[index]))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(minWidth: UIScreen.main.bounds.width, maxWidth: UIScreen.main.bounds.width, minHeight: UIScreen.main.bounds.width * 0.5, alignment: .top)
                                    .overlay(downloadButton, alignment: .topTrailing)
                                Spacer()
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    Spacer()
                }
                //.matchedGeometryEffect(id: "ZStackAnimation", in: animation)
                //.transition(froopManager.areAllCardsExpanded ? .move(edge: .top) : .move(edge: .bottom))
                .background(Color(.white))
                
                Divider()
                    .padding(.top, 10)
            }
            
        }
        .onTapGesture {
            print("tap")
            for friend in froopHostAndFriends.friends {
                
                print(friend.firstName)
            }
        }
    }
    
    func formatDate(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MMM.dd.yyyy 'at' h:mm a"
        return formatter.string(from: date)
    }
    
    var downloadButton: some View {
        // check if current user's id is in the friend list
        let isFriend = froopHostAndFriends.friends.contains { $0.froopUserID == currentUserId }
        
        if isFriend {
            return AnyView(
                Button(action: {
                    isDownloading = true
                    downloadImage()
                }) {
                    if selectedImageIndex < froopHostAndFriends.froop.froopImages.count {
                        let imageKey = froopHostAndFriends.froop.froopImages[selectedImageIndex]
                        let isImageDownloaded = downloadedImages[imageKey] ?? false
                        Image(systemName: "arrow.down.square")
                            .font(.system(size: 30))
                            .fontWeight(.thin)
                            .foregroundColor(isImageDownloaded ? .white : Color(red: 249/255, green: 0/255, blue: 98/255))
                            .background(.ultraThinMaterial)
                    } else {
                        // You may want to provide some default Image or other view when there's an error
                        EmptyView()
                    }
                }
                    .frame(width: 50, height: 50)
                    .background(Color.white.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .disabled(isDownloading)
                    .padding()
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    func downloadImage() {
        guard let url = URL(string: froopHostAndFriends.froop.froopImages[selectedImageIndex]) else { return }
        
        // Check if the image has already been downloaded
        if downloadedImages[froopHostAndFriends.froop.froopImages[selectedImageIndex]] == true {
            print("Image already downloaded")
            return
        }
        
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
                case .success(let value):
                    UIImageWriteToSavedPhotosAlbum(value.image, nil, nil, nil)
                    downloadedImages[froopHostAndFriends.froop.froopImages[selectedImageIndex]] = true
                case .failure(let error):
                    print("Error downloading image: \(error)")
            }
            isDownloading = false
        }
    }
}
