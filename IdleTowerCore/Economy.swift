//
//  Economy.swift
//  IdleTowerCore
//
//  Created by Chris Slowik on 1/5/26.
//

import Foundation

public enum Economy {
    public static func cost(base: ResourceCost, owned: Int) -> ResourceCost {
        let multiplier = pow(1.15, Double(owned))
        return ResourceCost(
            materials: base.materials * multiplier,
            energy: base.energy * multiplier,
            data: base.data * multiplier
        )
    }
}

