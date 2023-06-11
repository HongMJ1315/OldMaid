//
//  LobbyView.swift
//  OldMaid
//
//  Created by Mr.JB on 2023/5/26.
//

import SwiftUI
import Firebase

struct LobbyView: View {
    @AppStorage("playerID") var playerID = "null"
    @AppStorage("roomID") var roomID = "null"
    @AppStorage("firstInRoom") var firstInRoom = true
    @State private var roomNumber: String = ""
    @State private var showJoinRoomAlert: Bool = false
    @State private var showGameHistory: Bool = false
    @State var player : Player = Player()
    @State var isInRoom : Bool = false
    @State private var playerResult: [String: [String]] = [:]

    @Binding var isLogIn : Bool
    init(isLogIn : Binding<Bool>){
        _isLogIn = isLogIn
    }

    var body: some View {
        NavigationView{
            GeometryReader{ geometry in
                ZStack{
                    VStack{
                        Text("Please Roatte Your Phone")
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(geometry.size.width < geometry.size.height ? 1 : 0)
                    .zIndex(4)
                    Group{
                        VStack{
                            Text(player.playerID)
                            Button("Join room random"){
                                firstInRoom = true
                                print(playerID, player.roomID)
                                resetPlayer(player: player)
                                joinRoomRandom(player: player){ result in
                                    roomID = player.roomID
                                    isInRoom = result
                                }
                            }
                            Button("Join room by room number") {
                                showJoinRoomAlert = true
                            }
                            .sheet(isPresented: $showJoinRoomAlert, content: {
                                joinRoomDialog()
                            })
                            Button("Create Room"){
                                resetPlayer(player: player)
                                joinRoom(player:player, roomID:createRoom(player:player)){
                                    roomID = player.roomID
                                    isInRoom = true
                                    print("is in room true")
                                }
                            }
                            Button("Show Game History") {
                                getPlayerResult(playerID: playerID) { history in
                                    self.playerResult = history
                                    
                                    for key in self.playerResult.keys.sorted() {
                                        print(key)
                                        for value in self.playerResult[key]! {
                                            print(value)
                                        }
                                    }
                                    showGameHistory = true
                                }
                            }
                            .sheet(isPresented: $showGameHistory, content: {
                                GameHistoryView(showGameHistory: $showGameHistory)
                            })
                            Button("Log Out"){
                                playerID = "null"
                                isLogIn = false
                                do {
                                   try Auth.auth().signOut()
                                } catch {
                                   print(error)
                                }
                            }
                            Text("appsotre" +  roomID + " class" + player.roomID)
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(geometry.size.width < geometry.size.height ? 0 : 1)
                    .zIndex(3)
                    .background(
                        NavigationLink(destination: RoomView(player : $player, isInRoom : $isInRoom), isActive: $isInRoom) { EmptyView() }
                    )
                }
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            self.player.setPlayerInfo(playerID: playerID, roomID: roomID)
            print("player ID : \(playerID)")
            print("roomID: ", player.roomID)
            if !(roomID == "null" || roomID == ""){
                isInRoom = true
            } else {
                player.roomID = ""
                player.deckID = ""
                isInRoom = false
            }
            getPlayerResult(playerID: playerID) { history in
                self.playerResult = history
                
                for key in self.playerResult.keys.sorted() {
                    print(key)
                    for value in self.playerResult[key]! {
                        print(value)
                    }
                }
            }
        }
    }
    @ViewBuilder
    func joinRoomDialog() -> some View {
        VStack {
            Text("Enter room number")
                .font(.title)
            TextField("Room Number", text: $roomNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            HStack {
                Spacer()
                Button("Cancel") {
                    showJoinRoomAlert = false
                }
                .padding()
                Button("Join") {
                    // 执行加入房间逻辑，使用roomNumber变量
                    firstInRoom = true
                    print(playerID, player.roomID)
                    resetPlayer(player: player)
                    joinRoomWithRoomNumber(player: player, roomNumber: roomNumber) { result in
                        roomID = player.roomID
                        isInRoom = result
                    }
                    print("Joining room: \(roomNumber)")
                    showJoinRoomAlert = false
                }
                .padding()
                .disabled(roomNumber.isEmpty)
            }
        }
    }
}

func getPlayerResult(playerID : String, completion: @escaping ([String: [String]]) -> Void) {
    print("get History \(playerID)")
    var result : [String: [String]] = [String: [String]] ()
    let db = Firestore.firestore()
    let docRef = db.collection("player").document(playerID)
    docRef.getDocument { (document, error) in
        guard let document = document, document.exists else {
            print("Document does not exist")
            return
        }
        var player = try! document.data(as: Player.self)
        result = player.gameHistory
        completion(player.gameHistory)
    }
}


struct GameHistoryView: View{
    @State var playerResult: [String: [String]] = [:]
    @Binding var showGameHistory: Bool
    @AppStorage("playerID") var playerID = "null"
    var body: some View{
        ScrollView { // 或者使用 ScrollView 包装
            VStack {
                VStack{
                    ForEach(playerResult.keys.sorted(), id: \.self) { key in
                        Text("Play time: \(key)")
                        let values = playerResult[key]!
                        ForEach(0..<values.count) { i in
                            Text("Rank \(i): \(values[i])")
                        }
                    }
                }
                Button("Close"){
                    showGameHistory = false
                }
            }
        }
        .onAppear{
            getPlayerResult(playerID: playerID) { history in
                self.playerResult = history
                
                for key in self.playerResult.keys.sorted() {
                    print(key)
                    for value in self.playerResult[key]! {
                        print(value)
                    }
                }
                showGameHistory = true
            }
        }
    }
}
