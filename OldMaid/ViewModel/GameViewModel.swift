//
//  GameViewModel.swift
//  OldMaid
//
//  Created by Mr.JB on 2023/5/27.
//

import Foundation

class GameViewModel : ObservableObject {
    @Published var player: Player?
    @Published var room : Room?
    var playerID: String = ""
    var roomID: String = ""
    @Published var nextPlayerID: String = ""
    @Published var nextPlayerCardNumber : Int?
    @Published var playerIndex : Int?
    @Published var nowTurn : Int?
    @Published var isChoosed : Bool?
    private var isObservingNextPlayer: Bool = false

    init(){
        playerID = ""
    }
    init(playerID: String, roomID:String){
        setPlayerID(playerID: playerID){ result in
            print("next player id:", result)
            self.nextPlayerID = result
            self.setRoomID(roomID: roomID){_ in 
                self.observeNextPlayer()

            }
            self.observePlayer()
            self.observeRoom()
            self.observeNextPlayer()
        }
    }
    func setPlayerAndRoomID(playerID: String, roomID:String){
        setPlayerID(playerID: playerID){ result in
            print("next player id:", result)
            self.nextPlayerID = result
            self.setRoomID(roomID: roomID){_ in 
                self.observeNextPlayer()
            }
            self.observePlayer()
            self.observeRoom()
            self.observeNextPlayer()
        }
    }
    func setPlayerID(playerID: String, completion: @escaping (String) -> Void){
        self.playerID = playerID
        let playerRef = db.collection("player").document(playerID)
        playerRef.getDocument { (document, error) in
            guard let document = document, document.exists else{
                return
            }
            self.player = try? document.data(as : Player.self)
            let roomRef = db.collection("room").document(self.player!.roomID)
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
                completion(players[(playerIndex + 1) % players.count])
//                self.nextPlayerID = players[(playerIndex + 1) % players.count]
            }
        }
    }
    func setRoomID(roomID : String, completion: @escaping (String) -> Void){
        self.roomID = roomID
        let roomRef = db.collection("room").document(roomID)
        roomRef.getDocument { (document, error) in
            guard let document = document, document.exists else{
                return
            }
            self.room = try? document.data(as : Room.self)
            
            for i in self.room!.players.indices{
                if(self.room!.players[i] == self.player!.playerID){
                    self.playerIndex = i
                    return
                }
            }
        }
    }
    func observePlayer(){
        let cardRef = db.collection("player").document(playerID)
        cardRef.addSnapshotListener { (documentSnapshot, error) in
            guard let document = documentSnapshot else{
                print("no document")
                return
            }
            self.player = try? document.data(as : Player.self)
        
        }
    }
    func observeNextPlayer() {
            guard !isObservingNextPlayer else {
                return
            }

            isObservingNextPlayer = true

            print("Observe next player")
            let cardRef = db.collection("player").document(nextPlayerID)
            cardRef.addSnapshotListener { [weak self] documentSnapshot, error in
                guard let self = self else {
                    return
                }
            
            guard let document = documentSnapshot, document.exists else {
                print("No document")
                return
            }
            
            guard let player = try? document.data(as: Player.self) else {
                print("Player is nil")
                self.updateNextPlayerID()
                return
            }
            
            print("Next player ID: ", player.playerID, player.deck.count)
            
            if player.deck.isEmpty {
                print("Next player card empty")
                self.updateNextPlayerID()
            } else {
                self.nextPlayerCardNumber = player.deck.count
            }
            self.isObservingNextPlayer = false

        }
    }

    private func updateNextPlayerID() {
        guard let room = self.room else {
            return
        }
        
        guard let currentIndex = room.players.firstIndex(of: nextPlayerID) else {
            return
        }
        
        nextPlayerID = room.players[(currentIndex + 1) % room.players.count]
        print("Next player ID: ", nextPlayerID)
        let cardRef = db.collection("player").document(nextPlayerID)
        print("Update cardRef")
        observeNextPlayer()
    }

    func observeRoom(){
        let roomRef = db.collection("room").document(roomID)
        roomRef.addSnapshotListener { (documentSnapshot, error) in
            guard let document = documentSnapshot else{
                print("no document")
                return
            }
            self.room = try? document.data(as : Room.self)
            if(self.room?.turn == self.playerIndex){
                self.isChoosed = true
            }
            else{
                self.isChoosed = false
            }
            print("now turn \(self.room?.turn) \(self.playerIndex) \(self.isChoosed)")
        }
    }
    func shuffle(){
        playerCardShuffle(player: player!)
    }
}
