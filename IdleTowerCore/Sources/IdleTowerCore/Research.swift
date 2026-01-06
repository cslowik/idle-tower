//
//  Research.swift
//  IdleTowerCore
//
//  Created by Chris Slowik on 1/5/26.
//

import Foundation

public struct ResearchDef: Codable, Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let cost: Double // Data cost
    public let prerequisites: [String] // IDs of required research
    public let effectType: ResearchEffectType
    public let effectValue: Double
    
    public init(id: String, name: String, description: String, cost: Double, prerequisites: [String] = [], effectType: ResearchEffectType, effectValue: Double) {
        self.id = id
        self.name = name
        self.description = description
        self.cost = cost
        self.prerequisites = prerequisites
        self.effectType = effectType
        self.effectValue = effectValue
    }
}

public enum ResearchEffectType: String, Codable, Sendable {
    case advancedMaterials = "advanced_materials"
    case energyStorage = "energy_storage"
    case efficiencyProtocols = "efficiency_protocols"
}

