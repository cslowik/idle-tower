//
//  Catalog.swift
//  IdleTower
//
//  Created by Chris Slowik on 1/5/26.
//

import Foundation

struct ProducerDef: Codable {
    let id: String
    let name: String
    let baseCost: Double
    let baseOutput: Double // credits per second per unit
}

struct Catalog {
    let producers: [ProducerDef]

    static let demo = Catalog(producers: [
        ProducerDef(id: "miner", name: "Miner", baseCost: 10, baseOutput: 1)
    ])
}
