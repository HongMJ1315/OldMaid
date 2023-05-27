//
//  RoomView.swift
//  OldMaid
//
//  Created by Mr.JB on 2023/5/27.
//

import SwiftUI
import FirebaseFirestoreSwift

struct RoomView: View {
    @StateObject var viewModel: RoomViewModel = RoomViewModel(){
        willSet {
//            self.objectWillChange.send()
            print("get room playerr number \(viewModel.room?.players.count)")
        }
    
    }
    @AppStorage("roomID") var roomID = "null"
    @Binding var isInRoom : Bool
    @Binding var player : Player
    init(player : Binding<Player>, isInRoom: Binding<Bool>) {
        _isInRoom = isInRoom
        _player = player
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
                            Text(roomID)
                            Text(viewModel.room?.hostPlayerID ?? "null")
                            Text(player.playerID)
                            if let room = viewModel.room {
                                ForEach(room.players, id: \.self) { playerID in
                                    Text(playerID)
                                }
                            } else {
                                Text("No players available")
                            }

                            Button("Start Game"){
                                roomStart(roomID: roomID)
                            }
                            .disabled(viewModel.room?.players.count ?? 0 < 4 || viewModel.room?.hostPlayerID != player.playerID)
                            
                            
                            Button("Exit"){
                                isInRoom = false
                                
                                roomID = "null"
                                quitRoom(player: player)
                            }
                        }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .opacity(geometry.size.width < geometry.size.height ? 0 : 1)
                .zIndex(3)
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .onAppear{

            self.viewModel.setRoomID(roomID: roomID)
        }
    }
}

//struct RoomView_Previews: PreviewProvider {
//    static var previews: some View {
//        RoomView()
//    }
//}
