//
//  GameState.swift
//  IdleTowerCore
//
//  Created by Chris Slowik on 1/5/26.
//

import Foundation

public struct GameState: Codable {
    public var materials: Double = 0
    public var energy: Double = 0
    public var data: Double = 0
    public var producers: [String: Int] = [:]
    public var lastUpdate: Date = Date()
    
    // Card tracking
    public var inHand: [Card] = []
    public var playedCards: [Card] = []
    
    // Research tracking
    public var researchedTech: [String] = [] // IDs of completed research
    
    // Prestige tracking
    public var prestige: Int = 0 // Prestige level for card generation
    
    public init(
        materials: Double = 0,
        energy: Double = 0,
        data: Double = 0,
        producers: [String: Int] = [:],
        lastUpdate: Date = Date(),
        inHand: [Card] = [],
        playedCards: [Card] = [],
        researchedTech: [String] = [],
        prestige: Int = 0
    ) {
        self.materials = materials
        self.energy = energy
        self.data = data
        self.producers = producers
        self.lastUpdate = lastUpdate
        self.inHand = inHand
        self.playedCards = playedCards
        self.researchedTech = researchedTech
        self.prestige = prestige
    }
}

