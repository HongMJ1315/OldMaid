//
//  RoomView.swift
//  OldMaid
//
//  Created by Mr.JB on 2023/5/27.
//

import SwiftUI
import FirebaseFirestoreSwift

struct RoomView: View {
    @AppStorage("firstInRoom") var firstInRoom = true
    @StateObject var viewModel: RoomViewModel = RoomViewModel(){
        willSet {
//            self.objectWillChange.send()
            print("get room playerr number \(viewModel.room?.players.count)")
        }
    }
    @AppStorage("roomID") var roomID = "null"
    @Binding var isInRoom : Bool
    @Binding var player : Player
    @State var isStart : Bool = false
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
                            if let room = viewModel.room{
                                Text(roomID)
                                Text(room.hostPlayerID)
                                
                                Text(player.playerID)
                                if let room = room {
                                    ForEach(room.players, id: \.self) { playerID in
                                        Text(playerID)
                                    }
                                } else {
                                    Text("No players available")
                                }

                                Button("Start Game"){
                                    
                                    roomStart(roomID: roomID){
                                        result in
                                        if(result){
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                viewModel.start()
                                                
                                            }
                                            
                                        }
                                    
                                    }
  
                                }
                                .disabled(room.players.count < 4 || room.hostPlayerID != player.playerID)
                                
                                
                                Button("Exit"){
                                    isInRoom = false
                                    
                                    roomID = "null"
                                    print("playerID: \(player.playerID) press exit button")
                                    
                                    quitRoom(player: player)
                                }
                                Text("Game Started: \(room.isStart ? "true" : "false")")
                            }
                            else {
                                Button("Room is not exist"){
                                    isInRoom = false
                                    roomID = "null"
                                    resetPlayer(player: player)
                                }
                            
                            }
                        }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .opacity(geometry.size.width < geometry.size.height ? 0 : 1)
                .zIndex(3)
                .background{
                    if let room = viewModel.room{
                        NavigationLink(destination: GameView(isInRoom: $isInRoom), isActive: room.isStart ? .constant(true) : .constant(false)) {
                            EmptyView()
                        }
                    }

                }
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .onAppear{
//            self.firstInRoom = false
            self.viewModel.setRoomID(roomID: roomID)
            checkRoomIlliberal(roomID: roomID) { result in
                isInRoom = result
                if(result == false){
                    isInRoom = false
                    roomID = "null"
                    player.deckID = ""
                    player.roomID = ""
                    return
                }
            }
            checkRoomIsStart(roomID: roomID) { result in
                isStart = result
            }
            
        }
        
    }
}

//struct RoomView_Previews: PreviewProvider {
//    static var previews: some View {
//        RoomView()
//    }
//}
