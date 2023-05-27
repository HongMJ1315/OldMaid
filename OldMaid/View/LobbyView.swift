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
    
    @State var player : Player = Player()
    @State var isInRoom : Bool = false
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
                            Button("Join room random"){
                                print("join room")
                                print(playerID, player.roomID)
                                joinRoomRandom(player: player){ result in
                                    print("in room")
                                    print(playerID," | ", player.roomID)
                                    roomID = player.roomID
                                    isInRoom = result

                                }
                                
                            }
                            Button("Joint room for room number"){
                                joinRoomRandom(player: player){ result in
                                    print("join room")
                                    isInRoom = true
                                }
                                
                            }
                            Button("Create Room"){
                                joinRoom(player:player, roomID:createRoom(player:player)){
                                    roomID = player.roomID
                                    isInRoom = true
                                }
                                
                            }
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
            self.player = Player(playerID: playerID, roomID: roomID)
            print(player.roomID)
            if !(roomID == "null" || roomID == ""){
                isInRoom = true
            } else {
                isInRoom = false
            }
        }
    }
}


