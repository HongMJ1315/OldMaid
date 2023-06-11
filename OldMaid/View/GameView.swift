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
    @AppStorage("firstInRoom") var firstInRoom = true
    @AppStorage("rank") var rank = -1
    @State var isMoving : Bool = false
    @State var opacityValue : Double = 1
    @State var tapCardIndex : Int = -1
    @State var secondTapCardIndex : Int = -1
    @State var chooseCard : Int = -1
    @State var dealFinish : Bool = false
    @Binding var isInGame : Bool
    @Binding var isInRoom : Bool
    @State var phoneWidth : CGFloat = 0
    @State var offsetXValues : [CGFloat] = Array(repeating: 0, count: 15)
    init(isInGame: Binding<Bool>, isInRoom: Binding<Bool>) {
        _isInGame = isInGame
        _isInRoom = isInRoom
    }
    func reset(){
        print("game view reset")
        viewModel.reset()
    }
    var body: some View {
        NavigationView{
            GeometryReader{ geometry in
                let cardSpacing : CGFloat = geometry.size.width / 15
                let cardWidth : CGFloat = geometry.size.width / 10
                let cardHeight : CGFloat = geometry.size.height / 5
                ZStack{
                    VStack{
                        Text("Please Roatte Your Phone")
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(geometry.size.width < geometry.size.height ? 1 : 0)
                    .zIndex(6)
                    
                    Group {
                        ZStack{
                            VStack{
                                Text("Game Result")
                                if let rank = viewModel.yourRank{
                                    Text("Your Rank \(rank)")
                                }
                                if let room = viewModel.room, let player = viewModel.player {
                                    if let gameResult = room.gameResult {
                                        ForEach(gameResult, id: \.self) { result in
                                            Text("\(result)")
                                        }
                                    }
                                    Button("Exit Room"){
                                        if(room.hostPlayerID == playerID){
                                            updatePlayerGameResult(playerID: room.players, result: room.gameResult, startTime: room.startTime) {
                                                let playerCopy = Player(playerID: player.playerID, roomID: player.roomID) // 创建一个 player 对象的副本
    //                                            playerCopy.roomID = player.roomID // 复制其他需要保留的属性
                                                quitRoom(player: playerCopy)
                                                closeRoom(roomID: viewModel.roomID)
                                                viewModel.reset()
                                                roomID = "null"
                                                isInGame = false
                                            }
                                        }
                                        else{
                                            viewModel.reset()
                                            roomID = "null"
                                            isInGame = false
                                            isInRoom = false
                                        }
                                    }
                                    .disabled(room.rank >= 0)
                                }
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .opacity((viewModel.player?.deck.count == 0 || viewModel.nextPlayerID == viewModel.playerID ) && viewModel.roomError == false ? 1 : 0)
                            .zIndex(5)
                            VStack{
                                Text("Room Error")
                                Button("Exit Room"){
                                    viewModel.reset()
                                    roomID = "null"
                                    isInGame = false
                                    isInRoom = false
                                }

                            }
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .opacity((viewModel.roomError) ? 1 : 0)
                            .zIndex(4)

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
                                                                calculateOffsetXValues()
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
//                                        isMoving = true
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            opacityValue = 0
                                        }
                                        withAnimation(.easeInOut(duration: 0.5))  {
                                            for i in 0..<offsetXValues.count{
                                                offsetXValues[i] = 0
                                            }
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            viewModel.shuffle()
                                            withAnimation(.easeInOut(duration: 0.5)) {
                                                opacityValue = 1
                                            }
                                            withAnimation(.easeInOut(duration: 0.5)) {
                                                guard let deck = viewModel.player?.deck else {
                                                    return
                                                }
                                                let cardSpacing: CGFloat = 50
                                                let xOffset = -CGFloat(deck.count - 1) * cardSpacing / 2
                                                offsetXValues = deck.indices.map { index in
                                                    return xOffset + CGFloat(index) * cardSpacing
                                                }
                                            }
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
                                ZStack {
                                    if let deck = viewModel.player?.deck {
                                        ForEach(Array(deck.enumerated()), id: \.element.id) { (index, card) in
                                            if let card = card {
                                                CardView(card: card)
                                                    .rotationEffect(isMoving ? .degrees(360) : .zero)
                                                    .opacity(opacityValue)
                                                    .animation(.easeInOut(duration: 1))
                                                    .frame(width: cardWidth, height: cardHeight)
                                                    .offset(x: offsetXValues[index])
                                                    .zIndex(Double(index) + 10)
                                                    .onTapGesture {
                                                        if tapCardIndex != -1 && deck[tapCardIndex].rank == card.rank && tapCardIndex != deck.firstIndex(where: { $0.id == card.id }) {
                                                            secondTapCardIndex = deck.firstIndex(where: { $0.id == card.id })!
                                                            print("secondTapCardIndex: ", secondTapCardIndex)
                                                            abandonCardFromPlayer(formPlayer: viewModel.player!, firstCardIndex: tapCardIndex, secondCardIndex: secondTapCardIndex, roomID: roomID)
                                                            tapCardIndex = -1
                                                            secondTapCardIndex = -1
                                                            return
                                                        }
                                                        if let tapIndex = deck.firstIndex(where: { $0.id == card.id }) {
                                                            print("index: ", tapIndex)
                                                            tapCardIndex = tapIndex
                                                        }
                                                    }
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(Color.blue, lineWidth: 2)
                                                            .opacity(tapCardIndex == deck.firstIndex(where: { $0.id == card.id }) ? 1 : 0)
                                                            .offset(x: offsetXValues[index])
                                                        
                                                    )
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(Color.red, lineWidth: 2)
                                                            .opacity(tapCardIndex != -1 && tapCardIndex < deck.count && deck[tapCardIndex].rank == card.rank && tapCardIndex != deck.firstIndex(where: { $0.id == card.id }) ? 1 : 0)
                                                            .offset(x: offsetXValues[index])
                                                    )
                                            }
                                        }
                                        Text("Finish")
                                            .opacity(viewModel.player?.deck.count == 0 ? 1 : 0)
                                    }
                                }
                                Text(viewModel.nextPlayerID)
                                Text(viewModel.player?.playerID ?? "")
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .opacity((viewModel.player?.deck.count == 0 || viewModel.nextPlayerID == viewModel.playerID) ? 0 : 1)
                            .zIndex(2)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            firstInRoom = true
            self.viewModel.setPlayerAndRoomID(romoveBug: !firstInRoom, playerID: playerID, roomID: roomID)
            firstInRoom = true
            calculateOffsetXValues()
        }
        .onDisappear {
            if !isInGame{
                // 在非活动状态下执行清理操作
                self.viewModel.reset()
            }
        }
        .onChange(of: viewModel.player?.deck) { _ in
            print("deck change")
            calculateOffsetXValues()
            print(viewModel.player?.deck.count)
        }
    }
    func calculateOffsetXValues() {
        print("calculateOffsetXValues")
        withAnimation {
            guard let deck = viewModel.player?.deck else {
                return
            }
            let cardSpacing: CGFloat = 50
            let xOffset = -CGFloat(deck.count - 1) * cardSpacing / 2
            for i in deck.indices{
                offsetXValues[i] = xOffset + CGFloat(i) * cardSpacing
            }
            print(offsetXValues)
        }
    }
}
