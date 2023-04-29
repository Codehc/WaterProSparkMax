//
//  ContentView.swift
//  WaterProSparkMax
//
//  Created by Reza Bagheri on 4/27/23.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State private var config = Config(
        table: "", usingPurelyInterval: false, interval: 0, wateringThreshold: 20, wateringTime: 5000
    )
    
    var body: some View {
        let tableBinding = Binding<String>(get: {
            self.config.table
        }, set: {
            self.config.table = $0.lowercased()
        })
        
        VStack {
            Text("WaterProSparkMax!")
                .bold()
                .font(.title)
                .fontWeight(.black)
            VStack {
                Text("Interval")
                IntervalPicker(milliseconds: $config.interval)
            }
            VStack {
                Text("Watering Time")
                WateringLengthPicker(milliseconds: $config.wateringTime)
            }
            Toggle("Disable Smart Watering", isOn: $config.usingPurelyInterval)
                .padding(.top)
                .padding(.horizontal)
            TextField("Plant Name", text: tableBinding)
                .padding()
                .autocorrectionDisabled(true)
                .foregroundColor(.white)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(15)
            Button(action: configure) {
                Text("Configure")
            }
            Spacer()
        }
        .padding()
    }
    
    func configure() {
        
    }
}

struct IntervalPicker: View {
    @Binding var milliseconds: Int
    
    @State var days: String = "0"
    @State var hours: String = "0"
    @State var minutes: String = "0"
    
    var body: some View {
        HStack {
            PickerColumn(timeUnit: "days", range: Array(0...30).map { "\($0)" }, selection: $days)
                .onChange(of: days) { [days] newStringDays in
                    let oldDays = Int(days) ?? 0
                    let newDays = Int(newStringDays) ?? 0
                    
                    subtractDays(days: oldDays)
                    addDays(days: newDays)
                }
            PickerColumn(timeUnit: "hours", range: Array(0...24).map { "\($0)" }, selection: $hours)
                .onChange(of: hours) { [hours] newStringHours in
                    let oldHours = Int(hours) ?? 0
                    let newHours = Int(newStringHours) ?? 0
                    
                    subtractHours(hours: oldHours)
                    addHours(hours: newHours)
                }
            PickerColumn(timeUnit: "min", range: Array(0...60).map { "\($0)" }, selection: $minutes)
                .onChange(of: minutes) { [minutes] newStringMinutes in
                    let oldMinutes = Int(minutes) ?? 0
                    let newMinutes = Int(newStringMinutes) ?? 0
                    
                    subtractMinutes(minutes: oldMinutes)
                    addMinutes(minutes: newMinutes)
                }
        }
        .frame(height: 200)
    }
    
    func addDays(days: Int) {
        self.milliseconds += days * Int(8.64e+7)
    }
    
    func subtractDays(days: Int) {
        self.milliseconds -= days * Int(8.64e+7)
    }
    
    func addHours(hours: Int) {
        self.milliseconds += hours * Int(3.6e+6)
    }
    
    func subtractHours(hours: Int) {
        self.milliseconds -= hours * Int(3.6e+6)
    }
    
    func addMinutes(minutes: Int) {
        self.milliseconds += minutes * 60000
    }
    
    func subtractMinutes(minutes: Int) {
        self.milliseconds -= minutes * 60000
    }
}

struct WateringLengthPicker: View {
    @Binding var milliseconds: Int
    
    @State var seconds: String = "0"
    
    var body: some View {
        HStack {
            PickerColumn(timeUnit: "sec", range: Array(0...60).map { "\($0)" }, selection: $seconds)
                .onChange(of: seconds) { [seconds] newStringSeconds in
                    let oldSeconds = Int(seconds) ?? 0
                    let newSeconds = Int(newStringSeconds) ?? 0
                    
                    subtractSeconds(seconds: oldSeconds)
                    addSeconds(seconds: newSeconds)
                }
        }
        .frame(height: 200)
    }
    
    func addSeconds(seconds: Int) {
        self.milliseconds += seconds * 1000
    }
    
    func subtractSeconds(seconds: Int) {
        self.milliseconds -= seconds * 1000
    }
}

struct PickerColumn: View {
    typealias Label = String
    typealias Entry = String
    
    let timeUnit: Label
    let range: [Entry]
    
    @Binding var selection: Entry
    
    var body: some View {
        HStack() {
            GeometryReader { geometry in
                Picker(timeUnit, selection: $selection) {
                    ForEach(0 ..< range.count, id: \.self) { row in
                        Text(range[row])
                            .tag(range[row])
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .pickerStyle(WheelPickerStyle())
                .clipped()
            }
            Text(timeUnit)
                .bold()
        }
    }
}

struct MultiPicker: View  {

    typealias Label = String
    typealias Entry = String

    let data: [ (Label, [Entry]) ]
    @Binding var selection: [Entry]

    var body: some View {
        GeometryReader { geometry in
            HStack {
                ForEach(0 ..< self.data.count, id: \.self) { column in
                    Picker(self.data[column].0, selection: self.$selection[column]) {
                        ForEach(0..<self.data[column].1.count, id: \.self) { row in
                            Text(verbatim: self.data[column].1[row])
                                .tag(self.data[column].1[row])
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: geometry.size.width / CGFloat(self.data.count), height: geometry.size.height)
                    .clipped()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
