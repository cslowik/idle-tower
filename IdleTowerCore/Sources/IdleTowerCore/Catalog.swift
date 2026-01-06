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
    
    public init(producers: [ProducerDef]) {
        self.producers = producers
    }

    public static let demo = Catalog(producers: [
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
    ])
}

