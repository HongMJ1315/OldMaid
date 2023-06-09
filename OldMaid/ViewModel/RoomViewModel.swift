//
//  RoomViewModel.swift
//  OldMaid
//
//  Created by Mr.JB on 2023/5/27.
//

import Foundation

import Firebase

class RoomViewModel: ObservableObject {
    @Published var room: Room?
    var roomListener: ListenerRegistration?
    var roomID: String
    init(){
        roomID = ""
    }
    init(roomID: String) {
        self.roomID = roomID
        observeRoom()
    }
    func setRoomID(roomID : String){
        self.roomID = roomID
        observeRoom()
    }
    deinit {
        stopObservingRoom()
    }

    func observeRoom() {
        let roomRef = Firestore.firestore().collection("room").document(roomID)
        roomListener = roomRef.addSnapshotListener { [weak self] snapshot, error in
            guard let snapshot = snapshot, snapshot.exists else {
                // Room document doesn't exist or there was an error
                print("room error")
                self?.room = nil
                self?.stopObservingRoom()
                return
            }

            do {
                self?.room = try snapshot.data(as: Room.self)

                if let room = self!.room{
                    print("\(room.isStart)")
                }
            } catch {
                // Failed to decode Room document
                self?.room = nil
            }
        }
    }

    func stopObservingRoom() {
        print("reset room observer")
        roomListener?.remove()
        roomListener = nil
    }

    func checkPlayerStatus(playerID: String) -> Bool {
        guard let room = room else {
            // Room data not available
            return false
        }
        return room.players.contains(playerID)
    }
    
    func start(){
        let roomRef = Firestore.firestore().collection("room").document(roomID)
        roomRef.updateData([
            "isStart": true
        ])
    }
}
