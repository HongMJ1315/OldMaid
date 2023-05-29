//
//  GameView.swift
//  OldMaid
//
//  Created by Mr.JB on 2023/5/28.
//

import SwiftUI

struct GameView: View {
    @StateObject var viewModel: GameViewModel = GameViewModel()
    @AppStorage("playerID") var playerID = "null"
    @AppStorage("roomID") var roomID = "null"
    @State var deckView : [CardView] = []
    @State var isMoving : Bool = false
    @State var opacityValue : Double = 1
    @State var tapCardIndex : Int = -1
    @State var secondTapCardIndex : Int = -1
    @State var chooseCard : Int = -1
    @State var dealFinish : Bool = false
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
                    Group {
                        VStack {
                            HStack{
                                if let deck = viewModel.player?.deck {
                                    if let nextNumber = viewModel.nextPlayerCardNumber {
                                        ForEach((0..<nextNumber), id: \.self) { index in
                                            CardView(card: Card(suit: Card.Suit.unknowMark, rank: Card.Rank.unknowMark))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color.blue, lineWidth: 2)
                                                        .opacity(chooseCard == index ? 1 : 0)
                                                )
                                                .onTapGesture {
                                                    
                                                    if(!viewModel.isChoosed!){
                                                        chooseCard = -1
                                                        return
                                                    }
                                                    if(chooseCard == index && viewModel.isChoosed!){
                                                        print("chooseCard == index")
                                                        dealCardFromPlayer(formPlayerID: viewModel.nextPlayerID, toPlayer: viewModel.player!, cardIndex: chooseCard){ result in
                                                            self.dealFinish = result
                                                            
                                                        }
                                                        chooseCard = -1
                                                        viewModel.isChoosed = false
                                                        return
                                                    }
                                                    chooseCard = index
                                                    print(index)
                                                }
                                            
                                        }
                                    }
                                }
                            }
                            HStack{
                                Button("Shuffle") {
                                    isMoving = true
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        opacityValue = 0
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        viewModel.shuffle()
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            opacityValue = 1
                                        }
                                        isMoving = false
                                    }
                                }
                                Button("Next"){
                                    nextPlayer(roomID: roomID)
                                    dealFinish = false
                                }
                                .disabled(!dealFinish )
                                Text("Your Turn")
                                    .opacity((dealFinish == true || viewModel.isChoosed ?? false) ? 1 : 0)
                            }

                            HStack {
                                if let deck = viewModel.player?.deck {
                                    ForEach(deck) { card in
                                        CardView(card: card)
                                            .rotationEffect(isMoving ? .degrees(360) : .zero)
                                            .opacity(opacityValue)
                                            .animation(.easeInOut(duration: 1))
                                            .onTapGesture {
                                                if tapCardIndex != -1 && deck[tapCardIndex].rank == card.rank && tapCardIndex != deck.firstIndex(where: { $0.id == card.id }) {
                                                    secondTapCardIndex = deck.firstIndex(where: { $0.id == card.id })!
                                                    print("secondTapCardIndex: ", secondTapCardIndex)
                                                    abandonCardFromPlayer(formPlayer: viewModel.player!, firstCardIndex: tapCardIndex, secondCardIndex: secondTapCardIndex, roomID: roomID)
                                                    
                                                    tapCardIndex = -1
                                                    secondTapCardIndex = -1
                                                    return
                                                }
                                                if let index = deck.firstIndex(where: { $0.id == card.id }) {
                                                    print("index: ", index)
                                                    tapCardIndex = index
                                                }
                                                
                                            
                                            }
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.blue, lineWidth: 2)
                                                    .opacity(tapCardIndex == deck.firstIndex(where: { $0.id == card.id }) ? 1 : 0)
                                            )
                                            .overlay{
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.red, lineWidth: 2)
                                                    .opacity(tapCardIndex != -1 && tapCardIndex < deck.count && deck[tapCardIndex].rank == card.rank && tapCardIndex != deck.firstIndex(where: { $0.id == card.id }) ? 1 : 0)
                                            }
                                    }
                                    Text("Finish")
                                        .opacity(viewModel.player?.deck.count == 0 ? 1 : 0)
                                }
                            }
                            if let player = viewModel.player{
                                Text(player.playerID)
                            }
                            if let room = viewModel {
                                Text(room.nextPlayerID)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            self.viewModel.setPlayerAndRoomID(playerID: playerID, roomID: roomID)
        }
    }
}
