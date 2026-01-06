//
//  Catalog.swift
//  IdleTowerCore
//
//  Created by Chris Slowik on 1/5/26.
//

import Foundation

public struct ResourceCost: Codable, Sendable {
    public var materials: Double = 0
    public var energy: Double = 0
    public var data: Double = 0
    
    public init(materials: Double = 0, energy: Double = 0, data: Double = 0) {
        self.materials = materials
        self.energy = energy
        self.data = data
    }
}

public struct ResourceOutput: Codable, Sendable {
    public var materials: Double = 0
    public var energy: Double = 0
    public var data: Double = 0
    
    public init(materials: Double = 0, energy: Double = 0, data: Double = 0) {
        self.materials = materials
        self.energy = energy
        self.data = data
    }
}

public struct ProducerDef: Codable, Sendable {
    public let id: String
    public let name: String
    public let baseCost: ResourceCost
    public let baseOutput: ResourceOutput // per second per unit
    
    public init(id: String, name: String, baseCost: ResourceCost, baseOutput: ResourceOutput) {
        self.id = id
        self.name = name
        self.baseCost = baseCost
        self.baseOutput = baseOutput
    }
}

public struct Catalog: Sendable {
    public let producers: [ProducerDef]
    public let cardDefs: [CardDef]
    public let availableResearchTree: [ResearchDef]
    
    public init(producers: [ProducerDef], cardDefs: [CardDef] = [], availableResearchTree: [ResearchDef] = []) {
        self.producers = producers
        self.cardDefs = cardDefs
        self.availableResearchTree = availableResearchTree
    }

    public static let demo = Catalog(
        producers: [
            ProducerDef(
                id: "miner",
                name: "Miner",
                baseCost: ResourceCost(materials: 10, energy: 0, data: 0),
                baseOutput: ResourceOutput(materials: 1, energy: 0, data: 0)
            ),
            ProducerDef(
                id: "generator",
                name: "Generator",
                baseCost: ResourceCost(materials: 50, energy: 0, data: 0),
                baseOutput: ResourceOutput(materials: 0, energy: 2, data: 0)
            ),
            ProducerDef(
                id: "analyzer",
                name: "Analyzer",
                baseCost: ResourceCost(materials: 100, energy: 5, data: 0),
                baseOutput: ResourceOutput(materials: 0, energy: 0, data: 0.5)
            )
        ],
        cardDefs: [
            CardDef(
                id: "production_boost",
                name: "Production Boost",
                description: "Increases all production by 25%",
                effectType: .productionBoost,
                effectValue: 0.25
            ),
            CardDef(
                id: "cost_reduction",
                name: "Cost Reduction",
                description: "Reduces all costs by 15%",
                effectType: .costReduction,
                effectValue: 0.15
            ),
            CardDef(
                id: "energy_efficiency",
                name: "Energy Efficiency",
                description: "Increases energy production by 50%",
                effectType: .energyEfficiency,
                effectValue: 0.5
            )
        ],
        availableResearchTree: [
            ResearchDef(
                id: "advanced_materials",
                name: "Advanced Materials",
                description: "Unlocks advanced material processing techniques",
                cost: 100,
                prerequisites: [],
                effectType: .advancedMaterials,
                effectValue: 1.2
            ),
            ResearchDef(
                id: "energy_storage",
                name: "Energy Storage",
                description: "Improves energy storage capacity and efficiency",
                cost: 150,
                prerequisites: [],
                effectType: .energyStorage,
                effectValue: 1.3
            ),
            ResearchDef(
                id: "efficiency_protocols",
                name: "Efficiency Protocols",
                description: "Optimizes all production processes",
                cost: 200,
                prerequisites: ["advanced_materials", "energy_storage"],
                effectType: .efficiencyProtocols,
                effectValue: 1.5
            )
        ]
    )
}

