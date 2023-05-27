//
//  GameViewModel.swift
//  OldMaid
//
//  Created by Mr.JB on 2023/5/27.
//

import Foundation

class GameViewModel : ObservableObject {
    @Published var player: Player?
    
    var playerID: String = ""
    var nextPlayerID: String = ""
    init(){
        playerID = ""
    }
    init(playerID: String){
        setPlayerID(playerID: playerID)
    }
    func setPlayerID(playerID: String){
        self.playerID = playerID
        let playerRef = db.collection("player").document(playerID)
        playerRef.getDocument { (document, error) in
            guard let document = document, document.exists else{
                return
            }
            self.player = try? document.data(as : Player.self)
            let roomRef = db.collection("roomID").document(self.player!.roomID)
            roomRef.getDocument { (document, error) in
                guard let document = document, document.exists else{
                    return
                }
                let room = try? document.data(as : Room.self)
                let players = room!.players
                var playerIndex = 0
                for i in players.indices{
                    if(players[i] == self.playerID){
                        playerIndex = i
                        break
                    }
                }
                self.nextPlayerID = players[(playerIndex + 1) % players.count]
            }
        }
    }
    
    
}
