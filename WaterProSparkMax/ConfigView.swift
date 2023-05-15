//
//  ContentView.swift
//  WaterProSparkMax
//
//  Created by Reza Bagheri on 4/27/23.
//

import SwiftUI
import Combine

struct ConfigView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var config: Config
    @EnvironmentObject var plants: ConfigList
    
    @State private var keyboardHeight: CGFloat = 0
    @State private var shouldSet = true
    
    @State private var days = 30
    @State private var hours = 24
    @State private var minutes = 60
    
    @State private var seconds = 60
    
    var body: some View {
        NavigationView {
            VStack() {
                Text("Interval")
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .bold()
                
                IntervalPicker(milliseconds: $config.interval, days: $days, hours: $hours, minutes: $minutes, shouldSet: $shouldSet)
                    .padding(.horizontal)
                    .padding(.top)
                
                Divider()
                HStack {
                    VStack {
                        Text("Watering Time")
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .padding(.top)
                            .bold()
                        
                        WateringLengthPicker(milliseconds: $config.wateringTime, seconds: $seconds, shouldSet: $shouldSet)
                            .padding(.horizontal)
                    }
                    
                    VStack {
                        Text("Watering Threshold")
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .padding(.top)
                            .bold()
                        
                        PickerColumn(timeUnit: "%", range: Array(0...100), mod: 120, selection: $config.wateringThreshold)
                            .padding()
                    }
                }
                    
                List {
                    HStack {
                        Text("Plant Name")
                        Spacer()
                        TextField("Plant Name", text: $config.name)
                            .autocorrectionDisabled(true)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(.secondary)
                    }
                    Toggle("Disable Smart Watering", isOn: $config.usingPurelyInterval)
                }
                .scrollDisabled(true)
            }
            .foregroundColor(.white)
            .navigationTitle("Edit Plant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        shouldSet = false
                        dismiss()
                    }
                    .foregroundColor(.teal)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        shouldSet = true
                        dismiss()
                    }
                    .foregroundColor(.teal)
                    .bold()
                }
            }
        }
        .onDisappear() {
            config.interval = (days % 30) * Int(8.64e+7) + (hours % 24) * Int(3.6e+6) + (minutes % 60) * 60000
            config.wateringTime = (seconds % 60) * 1000
            
            if (shouldSet) {
                config.saveChanges()
                plants.writeToConfig(config: config)
            } else {
                config.discardChanges()
            }
        }
    }
}

struct IntervalPicker: View {
    @Binding var milliseconds: Int
    
    @Binding var days: Int
    @Binding var hours: Int
    @Binding var minutes: Int
    
    @Binding var shouldSet: Bool
    
    var body: some View {
        HStack {
            PickerColumn(timeUnit: "days", range: Array(0...60), mod: 30, selection: $days)
            PickerColumn(timeUnit: "hours", range: Array(0...48), mod: 24, selection: $hours)
            PickerColumn(timeUnit: "min", range: Array(0...120), mod: 60, selection: $minutes)
        }
        .onAppear() {
            var ms = milliseconds
            
            // Decode days from ms
            days = 30 + ms / Int(8.64e+7)
            ms %= Int(8.64e+7)
            
            // Decode hours from ms
            hours = 24 + ms / Int(3.6e+6)
            ms %= Int(3.6e+6)
            
            
            // Decode minutes from ms
            minutes = 60 + ms / 60000
        }
    }
}

struct WateringLengthPicker: View {
    @Binding var milliseconds: Int
    
    @Binding var seconds: Int
    
    @Binding var shouldSet: Bool
    
    var body: some View {
        HStack {
            PickerColumn(timeUnit: "sec", range: Array(0...120), mod: 60, selection: $seconds)
        }
        .onAppear() {
            seconds = 60 + milliseconds / 1000
        }
    }
}

struct PickerColumn: View {
    let timeUnit: String
    let range: [Int]
    
    let mod: Int
    
    @Binding var selection: Int
    
    var body: some View {
        HStack() {
            Picker(timeUnit, selection: $selection) {
                ForEach(range, id: \.self) { row in
                    Text("\(row % mod)")
                        .tag(row)
                }
            }
            .pickerStyle(.wheel)
            .clipped()
            Text(timeUnit)
                .bold()
        }
    }
}
