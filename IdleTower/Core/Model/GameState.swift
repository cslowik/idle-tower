//
//  GameState.swift
//  IdleTower
//
//  Created by Chris Slowik on 1/5/26.
//

import Foundation

struct GameState: Codable {
    var materials: Double = 0
    var energy: Double = 0
    var data: Double = 0
    var producers: [String: Int] = [:]
    var lastUpdate: Date = .now
}
