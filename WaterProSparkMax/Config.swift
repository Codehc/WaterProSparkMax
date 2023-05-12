//
//  Data.swift
//  WaterProSparkMax
//
//  Created by Reza Bagheri on 4/27/23.
//

import Foundation
import SwiftUI
import FirebaseDatabase

class Config: Identifiable, ObservableObject, Codable {
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        
        name = try container.decode(String.self, forKey: .name)
        originalName = try container.decode(String.self, forKey: .name)
        
        usingPurelyInterval = try container.decode(Bool.self, forKey: .usingPurelyInterval)
        originalUsingPurelyInterval = try container.decode(Bool.self, forKey: .usingPurelyInterval)
        
        interval = try container.decode(Int.self, forKey: .interval)
        originalInterval = try container.decode(Int.self, forKey: .interval)
        
        wateringThreshold = try container.decode(Int.self, forKey: .wateringThreshold)
        originalWateringThreshold = try container.decode(Int.self, forKey: .wateringThreshold)
        
        wateringTime = try container.decode(Int.self, forKey: .wateringTime)
        originalWateringTime = try container.decode(Int.self, forKey: .wateringTime)
        
        enabled = try container.decode(Bool.self, forKey: .enabled)
    }
    
    init(table: String, usingPurelyInterval: Bool, interval: Int, wateringThreshold: Int, wateringTime: Int, enabled: Bool) {
        self.name = table
        self.originalName = table
        
        self.usingPurelyInterval = usingPurelyInterval
        self.originalUsingPurelyInterval = usingPurelyInterval
        
        self.interval = interval
        self.originalInterval = interval
        
        self.wateringThreshold = wateringThreshold
        self.originalWateringThreshold = wateringThreshold
        
        self.wateringTime = wateringTime
        self.originalWateringTime = wateringTime
        
        self.enabled = enabled
        
        self.id = UUID()
    }
    
    @Published var name: String
    private var originalName: String
    
    @Published var usingPurelyInterval: Bool
    private var originalUsingPurelyInterval: Bool
    
    @Published var interval: Int
    private var originalInterval: Int
    
    @Published var wateringThreshold: Int
    private var originalWateringThreshold: Int
    
    @Published var wateringTime: Int
    private var originalWateringTime: Int
    
    @Published var enabled: Bool
    
    var id: UUID
    
    private enum CodingKeys : String, CodingKey {
        case id = "id"
        case name = "name"
        case usingPurelyInterval = "usingPurelyInterval"
        case interval = "interval"
        case wateringThreshold = "wateringThreshold"
        case wateringTime = "wateringTime"
        case enabled = "enabled"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(usingPurelyInterval, forKey: .usingPurelyInterval)
        try container.encode(interval, forKey: .interval)
        try container.encode(wateringThreshold, forKey: .wateringThreshold)
        try container.encode(wateringTime, forKey: .wateringTime)
        try container.encode(enabled, forKey: .enabled)
    }
    
    func decode() {
        
    }
    
    func saveChanges() {
        originalName = name
        originalUsingPurelyInterval = usingPurelyInterval
        originalInterval = interval
        originalWateringThreshold = wateringThreshold
        originalWateringTime = wateringTime
    }
    
    func discardChanges() {
        name = originalName
        usingPurelyInterval = originalUsingPurelyInterval
        interval = originalInterval
        wateringThreshold = originalWateringThreshold
        wateringTime = originalWateringTime
    }
}

class ConfigList: ObservableObject {
    init(configurations: [Config]) {
        self.configurations = configurations
    }
    
    init() {
        self.configurations = []
        
        listentoRealtimeDatabase()
    }
    
    @Published var configurations: [Config]
    
    private lazy var databasePath: DatabaseReference? = {
            let ref = Database.database().reference().child("profiles")
            return ref
        }()
        
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func listentoRealtimeDatabase() {
        guard let databasePath = databasePath else {
            return
        }
        
        databasePath
            .observe(.childAdded) { [weak self] snapshot in
                guard
                    let self = self,
                    var json = snapshot.value as? [String: Any]
                else {
                    print("Failed JSON Unwrap")
                    return
                }
                json["id"] = snapshot.key
                do {
                    let profileData = try JSONSerialization.data(withJSONObject: json)
                    let profile = try self.decoder.decode(Config.self, from: profileData)
                    self.configurations.append(profile)
                } catch {
                }
            }
    }
    
    func stopListening() {
        databasePath?.removeAllObservers()
    }
    
    func writeToConfig(config: Config) {
        let profile = databasePath?.child(config.id.uuidString)
        profile?.child("name").setValue(config.name)
        profile?.child("enabled").setValue(config.enabled)
        profile?.child("usingPurelyInterval").setValue(config.usingPurelyInterval)
        profile?.child("interval").setValue(config.interval)
        profile?.child("wateringThreshold").setValue(config.wateringThreshold)
        profile?.child("wateringTime").setValue(config.wateringTime)
    }
    
    func deleteAtUUID(uuid: UUID) {
        databasePath?.child(uuid.uuidString).removeValue()
    }
}
