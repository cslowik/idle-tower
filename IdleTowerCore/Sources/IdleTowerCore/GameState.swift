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
    
    public init(materials: Double = 0, energy: Double = 0, data: Double = 0, producers: [String: Int] = [:], lastUpdate: Date = Date()) {
        self.materials = materials
        self.energy = energy
        self.data = data
        self.producers = producers
        self.lastUpdate = lastUpdate
    }
}

