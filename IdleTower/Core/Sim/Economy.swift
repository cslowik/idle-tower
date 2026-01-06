//
//  Economy.swift
//  IdleTower
//
//  Created by Chris Slowik on 1/5/26.
//

import Foundation

enum Economy {
    static func cost(base: Double, owned: Int) -> Double {
        base * pow(1.15, Double(owned))
    }
}
