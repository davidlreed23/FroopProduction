//
//  FroopCardView.swift
//  FroopProof
//
//  Created by David Reed on 2/6/23.
//

import SwiftUI
import SwiftUIBlurView
import Kingfisher
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation
import MapKit
import EventKit
import FirebaseCrashlytics

struct FroopInvitesCardView: View {
    @Binding var selectedTab: Int
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var locationServices = LocationServices.shared
    @ObservedObject var froopDataListener = FroopDataListener.shared
    
    var db = FirebaseServices.shared.db
    @ObservedObject var myData = MyData.shared
    @ObservedObject var friendViewController = FriendViewController.shared
    @ObservedObject var timeZoneManager: TimeZoneManager = TimeZoneManager()
    @Binding var froopDetailOpen: Bool
    //@ObservedObject var froopData: FroopData
    var froop: Froop
    var froops: Froop
    @Binding var selectedFroopUUID: String
    @Binding var invitedFriends: [UserData]
    @State private var showAlert = false
    @State private var confirmedFriends: [UserData] = []
    @State private var declinedFriends: [UserData] = []
    @State private var invitedFriendsLocal: [UserData] = []
    @State private var identifiableInvitedFriends: [IdentifiableFriendData] = []
    @State var myTimeZone: TimeZone = TimeZone.current
    @State var froopStartTime: Date? = Date()
    @State private var dataLoaded = false
    let visibleFriendsLimit = 8
    @State private var formattedDateString: String = ""
    
    
    init(selectedTab: Binding<Int>, froopDetailOpen: Binding<Bool>, froop: Froop, selectedFroopUUID: Binding<String>, invitedFriends: Binding<[UserData]>) {
        self._selectedTab = selectedTab
        self._froopDetailOpen = froopDetailOpen
        self.froop = froop
        self.froops = froop 
        self._selectedFroopUUID = selectedFroopUUID
        self._invitedFriends = invitedFriends
        self.timeZoneManager = TimeZoneManager()
    }
    
    var body: some View {
        
        ZStack (alignment: .top){
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 285)
                .foregroundColor(.white)
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .onTapGesture {
                    selectedFroopUUID = froop.froopId
                    froopDetailOpen = true
                }
                
            VStack (alignment: .leading) {
                HStack (alignment: .center){
                    HostProfilePhotoView(imageUrl: froop.froopHostPic)
                        .frame(width: 80, height: 80)
                        .padding(.leading, 10)
                      
                    
                    VStack (alignment: .leading){
                        Text(froops.froopName)
                            .font(.system(size: 18))
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(alignment: .leading)
                        
                        Text("Created: \(timeZoneManager.formatDurationSinceCreation(creationDate: froop.froopCreationTime)) ago")
                            .font(.system(size: 11))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .opacity(0.7)
                            .frame(alignment: .leading)
                    }
                    .padding(.leading, 10)
                }
                .padding(.top, 10)
                .padding(.leading, 10)
                
                Divider()
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(1)
                    .padding(1)
                
                
                HStack {
                    Spacer()
                    
                    let uid = FirebaseServices.shared.uid
                    
                    Button(action: {
                        LocationManager.shared.requestAlwaysAuthorization()
                        FroopDataController.shared.moveFroopInvitation(uid: uid, froopId: froop.froopId, froopHost: froop.froopHost, decision: "accept")
                        appStateManager.setupListener() {_ in
                            print("Accepted")
                        }
                         
                        selectedTab = 1
                        createCalendarEvent()
                    }) {
                        ZStack {
                            Rectangle()
                                .border(.black, width: 0.25)
                                .foregroundColor(.clear)
                                .frame(width: 150, height: 40)
                            Text("Accept")
                                .foregroundColor(.black)
                                .font(.system(size: 18))
                                .fontWeight(.light)
                        }
                    }
                    .buttonStyle(FroopButtonStyle())
                    
                    Button(action: {
                        FroopDataController.shared.moveFroopInvitation(uid: uid, froopId: froop.froopId, froopHost: froop.froopHost, decision: "decline")
                    }) {
                        ZStack {
                            Rectangle()
                                .border(.black, width: 0.25)
                                .foregroundColor(.clear)
                                .frame(width: 150, height: 40)
                            Text("Decline")
                                .foregroundColor(.black)
                                .font(.system(size: 18))
                                .fontWeight(.light)
                        }
                    }
                    .buttonStyle(FroopButtonStyle())
                    
                    Spacer()
                }
                
                
                Divider()
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(1)
                    .padding(1)
                
                VStack (alignment: .leading) {
                    HStack {
                        Image(systemName: "clock")
                            .frame(width: 30, height: 30)
                            .scaledToFill()
                            .font(.system(size: 18))
                            .fontWeight(.light)
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
                        Text(formattedDateString)
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .frame(width: 30, height: 30)
                            .scaledToFill()
                            .font(.system(size: 18))
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
                        Spacer()
                    }
                }
                .padding(.leading, 30)
                
                Spacer()
            }
            .onAppear {
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
    
    func requestCalendarAccess(completion: @escaping (Bool) -> Void) {
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event) { (granted, error) in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func createCalendarEvent() {
        let eventStore = EKEventStore()
        
        requestCalendarAccess { granted in
            if granted {
                let event = EKEvent(eventStore: eventStore)
                event.title = froop.froopName
                event.startDate = froop.froopStartTime
                event.endDate = froop.froopEndTime
                event.notes = ("\(froop.froopLocationtitle) at \(froop.froopLocationsubtitle)")
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                do {
                    try eventStore.save(event, span: .thisEvent)
                    print("Event saved successfully")
                    showAlert = true
                } catch {
                    PrintControl.shared.printErrorMessages("Error saving event: \(error.localizedDescription)")
                }
            } else {
                PrintControl.shared.printErrorMessages("Calendar access not granted")
            }
        }
    }
}




