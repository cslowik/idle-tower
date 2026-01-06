//
//  Simulator.swift
//  IdleTower
//
//  Created by Chris Slowik on 1/5/26.
//

import Foundation

final class Simulator {
    private(set) var state: GameState
    let catalog: Catalog

    init(state: GameState = GameState(), catalog: Catalog = .demo) {
        self.state = state
        self.catalog = catalog
    }

    func tick(dt: TimeInterval) {
        // production
        for def in catalog.producers {
            let count = state.producers[def.id, default: 0]
            state.resources["credits", default: 0] += Double(count) * def.baseOutput * dt
        }
        state.lastUpdate = .now
    }

    func buyProducer(id: String) -> Bool {
        guard let def = catalog.producers.first(where: { $0.id == id }) else { return false }

        let owned = state.producers[id, default: 0]
        let cost = Economy.cost(base: def.baseCost, owned: owned)
        let credits = state.resources["credits", default: 0]

        guard credits >= cost else { return false }

        state.resources["credits"] = credits - cost
        state.producers[id] = owned + 1
        return true
    }

    func producerCost(id: String) -> Double {
        guard let def = catalog.producers.first(where: { $0.id == id }) else { return .infinity }
        let owned = state.producers[id, default: 0]
        return Economy.cost(base: def.baseCost, owned: owned)
    }
}
