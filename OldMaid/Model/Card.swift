//
//  Card.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/23.
//

import Foundation

struct Card: Comparable, Codable {
    let suit: Suit
    let rank: Rank

    static func < (lhs: Card, rhs: Card) -> Bool {
        if lhs.rank == rhs.rank {
            return lhs.suit.rawValue < rhs.suit.rawValue
        }
        return lhs.rank.rawValue < rhs.rank.rawValue
    }

    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.rank == rhs.rank
    }

    enum Suit: Int, CaseIterable, Codable {
        case joker = 0
        case clubs = 1
        case diamonds
        case hearts
        case spades
    }

    enum Rank: Int, CaseIterable, Codable {
        case joker = 0
        case ace
        case two
        case three
        case four
        case five
        case six
        case seven
        case eight
        case nine
        case ten
        case jack
        case queen
        case king
    }
}


extension Card.Rank: CustomStringConvertible {
    var description: String {
        switch self {
        case .ace:
            return "A"
        case .king:
            return "K"
        case .queen:
            return "Q"
        case .jack:
            return "J"
        case .joker:
            return "🃏"
        default:
            return "\(rawValue)"
        }
    }
}

extension Card.Suit: CustomStringConvertible {
    var description: String {
        switch self {
        case .clubs:
            return "♣️"
        case .diamonds:
            return "♦️"
        case .hearts:
            return "♥️"
        case .spades:
            return "♠️"
        case .joker:
            return "🃏"
        }
    }
}
