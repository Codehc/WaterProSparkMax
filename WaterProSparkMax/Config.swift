//
//  Data.swift
//  WaterProSparkMax
//
//  Created by Reza Bagheri on 4/27/23.
//

import Foundation
import SwiftUI

struct Config: Identifiable {
    var table: String
    var usingPurelyInterval: Bool
    var interval: Int
    var wateringThreshold: Int
    var wateringTime: Int
    var enabled: Bool
    
    var id: String { table }
}
