//
//  Card.swift
//  IdleTowerCore
//
//  Created by Chris Slowik on 1/5/26.
//

import Foundation

public struct CardDef: Codable, Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let effectType: CardEffectType
    public let effectValue: Double
    
    public init(id: String, name: String, description: String, effectType: CardEffectType, effectValue: Double) {
        self.id = id
        self.name = name
        self.description = description
        self.effectType = effectType
        self.effectValue = effectValue
    }
}

public enum CardEffectType: String, Codable, Sendable {
    case productionBoost = "production_boost"
    case costReduction = "cost_reduction"
    case energyEfficiency = "energy_efficiency"
}

public struct Card: Codable, Sendable {
    public let id: String
    public let defId: String
    public let name: String
    public let description: String
    public let effectType: CardEffectType
    public let effectValue: Double
    
    public init(id: String, defId: String, name: String, description: String, effectType: CardEffectType, effectValue: Double) {
        self.id = id
        self.defId = defId
        self.name = name
        self.description = description
        self.effectType = effectType
        self.effectValue = effectValue
    }
    
    public init(from def: CardDef, id: String) {
        self.id = id
        self.defId = def.id
        self.name = def.name
        self.description = def.description
        self.effectType = def.effectType
        self.effectValue = def.effectValue
    }
}

