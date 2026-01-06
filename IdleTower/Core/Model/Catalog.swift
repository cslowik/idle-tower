//
//  Catalog.swift
//  IdleTower
//
//  Created by Chris Slowik on 1/5/26.
//

import Foundation

struct ResourceCost: Codable {
    var materials: Double = 0
    var energy: Double = 0
    var data: Double = 0
}

struct ResourceOutput: Codable {
    var materials: Double = 0
    var energy: Double = 0
    var data: Double = 0
}

struct ProducerDef: Codable {
    let id: String
    let name: String
    let baseCost: ResourceCost
    let baseOutput: ResourceOutput // per second per unit
}

struct Catalog {
    let producers: [ProducerDef]

    static let demo = Catalog(producers: [
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
