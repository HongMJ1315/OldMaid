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
    @State var player : Player = Player()
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
                                print(playerID, player.playerID)
                                joinRoomRandom(player: player)
                            }
                            Button("Joint room for room number"){
                                
                            }
                            Button("Create Room"){
                                
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
                        }
                    }
                }
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .onAppear{
            self.player = Player(playerID : playerID)

        }
    }
}


