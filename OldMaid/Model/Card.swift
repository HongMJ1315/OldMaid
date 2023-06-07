//
//  Card.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/23.
//

import Foundation

struct Card: Comparable, Codable, Identifiable, Hashable {
    let id = UUID()
    
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
        case unknowMark
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
        case unknowMark
    }
    // Custom decoding logic
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let suitRawValue = try container.decode(Int.self, forKey: .suit)
        let rankRawValue = try container.decode(Int.self, forKey: .rank)

        guard let suit = Suit(rawValue: suitRawValue), let rank = Rank(rawValue: rankRawValue) else {
            throw DecodingError.dataCorruptedError(forKey: .suit, in: container, debugDescription: "Invalid suit or rank")
        }

        self.suit = suit
        self.rank = rank
    }
    
    init (suit: Suit, rank: Rank) {
        self.suit = suit
        self.rank = rank
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
        case .unknowMark:
            return "?"
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
        case .unknowMark:
            return "?"
        }
    }
}
