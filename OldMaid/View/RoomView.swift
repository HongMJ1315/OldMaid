//
//  RoomView.swift
//  OldMaid
//
//  Created by Mr.JB on 2023/5/27.
//

import SwiftUI
import FirebaseFirestoreSwift

struct RoomView: View {
    @State var viewModel: RoomViewModel = RoomViewModel()
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
                            if let room = viewModel.room {
                                ForEach(room.players, id: \.self) { playerID in
                                    Text(playerID)
                                }
                            } else {
                                Text("No players available")
                            }

                            
                            Button("Exit"){
                                isInRoom = false
                                
                                roomID = "null"
                                quitRoom(player: player)
                            }
                        }
                    }
                }
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .onAppear{

            self.viewModel = RoomViewModel(roomID: roomID)
        }
    }
}

//struct RoomView_Previews: PreviewProvider {
//    static var previews: some View {
//        RoomView()
//    }
//}
