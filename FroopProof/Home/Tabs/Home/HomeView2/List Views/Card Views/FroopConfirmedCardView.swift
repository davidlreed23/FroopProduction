//
//  FroopCardView.swift
//  FroopProof
//
//  Created by David Reed on 2/6/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import MapKit


struct FroopConfirmedCardView: View {
    
    @ObservedObject private var viewModel = DetailsGuestViewModel()
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var locationServices = LocationServices.shared
    @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var friendViewController = FriendViewController.shared
    @ObservedObject var myData = MyData.shared
    @ObservedObject var timeZoneManager: TimeZoneManager = TimeZoneManager()
    @State private var confirmedFriends: [UserData] = []
    @State private var declinedFriends: [UserData] = []
    @State private var invitedFriendsLocal: [UserData] = []
    @State private var identifiableInvitedFriends: [IdentifiableFriendData] = []
    @State var froopStartTime: Date? = Date()
    @State private var dataLoaded = false
    @State var myTimeZone: TimeZone = TimeZone.current
    @State private var formattedDateString: String = ""
    @State private var isBlinking = false
    @State var hostData: UserData = UserData()
    @Binding var froopDetailOpen: Bool
    @Binding var invitedFriends: [UserData]
    
    var froop: Froop
    var db = FirebaseServices.shared.db
   
    let visibleFriendsLimit = 8
    let dateForm = DateForm()
    
    init(froopDetailOpen: Binding<Bool>, froop: Froop, invitedFriends: Binding<[UserData]>) {
        self._froopDetailOpen = froopDetailOpen
        self.froop = froop
        self._invitedFriends = invitedFriends
        self.timeZoneManager = TimeZoneManager()
    }
    
    var body: some View {
        
        ZStack (alignment: .top) {
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 185)
                .foregroundColor(.white)
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .onTapGesture {
                    if appStateManager.appState == .active && appStateManager.inProgressFroops.contains(where: { $0.froopId == froop.froopId }) {
                        locationServices.selectedTab = .froop
                        appStateManager.findFroopById(froopId: froop.froopId) { found in
                            if found {
                                locationServices.selectedTab = .froop
                            } else {
                                froopManager.froopDetailOpen = true
                                PrintControl.shared.printLists("ImageURL:  \(froop.froopHostPic)")
                            }
                        }
                    } else {
                        froopManager.selectedFroopUUID = froop.froopId
                        froopManager.selectedFroop = froop
                        froopManager.selectedHost = hostData
                        viewModel.fetchGuests()
                        froopManager.fetchFroopData(froopId: froop.froopId, froopHost: froop.froopHost) { completion in
                            print("Getting Froop")
                        }
                        froopManager.froopDetailOpen = true
                        PrintControl.shared.printLists("ImageURL:  \(froop.froopHostPic)")
                    }
                }
            
            VStack {
                HStack {
                    Spacer()
                    if appStateManager.inProgressFroops.contains(where: { $0.froopId == froop.froopId }) {
                        Text("IN PROGRESS")
                            .font(.system(size: 12))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
                            .opacity(isBlinking ? 0.0 : 1.0)
                            .onChange(of: appStateManager.appState) { newValue in
                                withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                    self.isBlinking = true
                                }
                            }
                    }
                }
                Spacer()
            }
            .frame(height: 185)
            .padding(.top, 5)
            .padding(.trailing, 35)
            
            
            
            VStack (alignment: .leading) {
                HStack (alignment: .center){
                    HostProfilePhotoView(imageUrl: froop.froopHostPic)
                        .scaledToFit()
                        .frame(width: 65, height: 35)
                        .padding(.leading, 15)
                        .onTapGesture {
                            print("\(String(describing: froop.froopStartTime))")
                            print(appStateManager.appState)
                            print("Fetched Froops:")
                            for froop in appStateManager.fetchedFroops {
                                   print(froop.froopName)
                               }

                               print("\nActive Froops:")
                            for froop in appStateManager.activeFroops {
                                   print(froop.froopName)
                               }

                               print("\(String(describing: froop.froopStartTime))")
                            
                        }
                
                  
                        Text(froop.froopName)
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(alignment: .leading)
                            
                    
                   
                }
                .frame(height: 50)
                .padding(.top, 10)
                .padding(.leading, 10)
                
                Divider()
                    .padding(.leading, 15)
                    .padding(.trailing, 15)
                    .padding(1)
                    .padding(1)
                VStack (alignment: .leading) {
                    HStack {
                        Image(systemName: "clock")
                            .frame(width: 65, height: 30)
                            .scaledToFill()
                            .font(.system(size: 24))
                            .fontWeight(.light)
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
                       
                        Text(formattedDateString)
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .padding(.leading, -15)
                        Spacer()
                    }
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .frame(width: 65, height: 30)
                            .scaledToFill()
                            .font(.system(size: 24))
                            .fontWeight(.light)
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
                        VStack (alignment: .leading){
                            Text(froop.froopLocationtitle)
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                            Text(froop.froopLocationsubtitle)
                                .font(.system(size: 14))
                                .fontWeight(.light)
                                .foregroundColor(.black)
                                .lineLimit(2)
                                .padding(.trailing, 25)
                        }
                        .padding(.leading, -15)
                        Spacer()
                    }
                }
                .padding(.leading, 5)
                
                Spacer()
            }
            .onAppear {
                appStateManager.fetchHostData(uid: froop.froopHost) { result in
                    switch result {
                    case .success(let userData):
                        self.hostData = userData
                    case .failure(let error):
                        print("Failed to fetch host data. Error: \(error.localizedDescription)")
                    }
                }
                loadConfirmedFriends()
                PrintControl.shared.printLists("Printing Date \(froop.froopStartTime)")
                timeZoneManager.convertUTCToCurrent(date: froop.froopStartTime, currentTZ: TimeZone.current.identifier) { convertedDate in
                    formattedDateString = timeZoneManager.formatDate(passedDate: convertedDate)
                }
            }

        }
    }
    
    func printFroop () {
        print(froop)
    }
    func formatTime(creationTime: Date) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .hour, .day]
        formatter.unitsStyle = .abbreviated
        
        let currentTime = Date()
        let timeSinceCreation = currentTime.timeIntervalSince(creationTime)
        
        let formattedTime = formatter.string(from: timeSinceCreation) ?? ""
        
        return formattedTime
    }
    
    func loadInvitedFriends() {
        let uid = FirebaseServices.shared.uid
        let froopRef = db.collection("users").document(uid).collection("myFroops").document(froop.froopId).collection("invitedFriends").document("inviteList")

        froopRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let invitedFriendUIDs = document.data()?["uid"] as? [String] ?? []
                self.fetchFriendsData(from: invitedFriendUIDs) { invitedFriends in
                    self.invitedFriends = invitedFriends
                }
            } else {
                print("No friends found in the invite list.")
            }
        }
    }

    func loadConfirmedFriends() {
        let uid = FirebaseServices.shared.uid
        let froopRef = db.collection("users").document(uid).collection("myFroops").document(froop.froopId).collection("invitedFriends").document("confirmedList")

        froopRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let confirmedFriendUIDs = document.data()?["uid"] as? [String] ?? []
                self.fetchFriendsData(from: confirmedFriendUIDs) { confirmedFriends in
                    self.confirmedFriends = confirmedFriends
                }
            } else {
                print("No friends found in the confirmed list.")
            }
        }
    }

    func loadDeclinedFriends() {
        let uid = FirebaseServices.shared.uid
        let froopRef = db.collection("users").document(uid).collection("myFroops").document(froop.froopId).collection("invitedFriends").document("declinedList")

        froopRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let declinedFriendUIDs = document.data()?["uid"] as? [String] ?? []
                self.fetchFriendsData(from: declinedFriendUIDs) { declinedFriends in
                    self.declinedFriends = declinedFriends
                }
            } else {
                print("No friends found in the declined list.")
            }
        }
    }
    
    func fetchConfirmedFriends() {
        let uid = FirebaseServices.shared.uid
     
        let invitedFriendsRef = db.collection("users").document(uid).collection("myFroops").document(froop.froopId).collection("invitedFriends")

        let confirmedListDocRef = invitedFriendsRef.document("confirmedList")

        confirmedListDocRef.getDocument { document, error in
            if let document = document, document.exists {
                let confirmedFriendUIDs = document.data()?["uid"] as? [String] ?? []
                
                // Fetch confirmed friends data from Firestore and update confirmedFriends array
                fetchFriendsData(from: confirmedFriendUIDs) { friends in
                    confirmedFriends = friends
                }
            }
        }
    }

    func fetchFriendsData(from friendUIDs: [String], completion: @escaping ([UserData]) -> Void) {
     
        let usersRef = db.collection("users")
        var friends: [UserData] = []

        let group = DispatchGroup()

        for friendUID in friendUIDs {
            group.enter()

            usersRef.document(friendUID).getDocument { document, error in
                if let document = document, document.exists, let friendData = document.data() {
                    let friend = UserData(dictionary: friendData)
                    friends.append(friend ?? UserData())
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(friends)
        }
    }
    
    func formatDateToTimeZone(passedDate: Date, timeZone: TimeZone) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d',' h:mm a"
        dateFormatter.timeZone = timeZone
        return dateFormatter.string(from: passedDate)
    }
}



