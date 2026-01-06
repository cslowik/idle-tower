//
//  GameState.swift
//  IdleTower
//
//  Created by Chris Slowik on 1/5/26.
//

import Foundation

struct GameState: Codable {
    var resources: [String: Double] = ["credits": 0]
    var producers: [String: Int] = [:]
    var lastUpdate: Date = .now
}
