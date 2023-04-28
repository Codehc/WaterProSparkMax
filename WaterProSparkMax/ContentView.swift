//
//  ContentView.swift
//  WaterProSparkMax
//
//  Created by Reza Bagheri on 4/27/23.
//

import SwiftUI

struct ContentView: View {
    @State private var config = Config(
        table: "", usingPurelyInterval: false, interval: 2000, wateringThreshold: 20, wateringTime: 5000
    )
    
    var body: some View {
        VStack {
            Text("WaterProSparkMax!")
            TextField("Plant Name", text: $config.table)
            Toggle("Disable Smart Watering", isOn: $config.usingPurelyInterval)
            TimePicker()
        }
        .padding()
    }
}

struct TimePicker: View {
    @State private var days = 0;
    @State private var hours = 0;
    @State private var minutes = 0;
    @State private var seconds = 0;
    
    var body: some View {
        UnitTimePicker()
        .padding()
    }
}

struct UnitTimePicker: View {
    @State private var scrollOffset: CGFloat = 0
    @State private var isScrolling = false

    var body: some View {
        HStack {
            ScrollView(showsIndicators: false) {
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: ScrollOffsetKey.self,
                        value: geometry.frame(in: .named("scrollView")).origin.y
                    )
                }.frame(width: 0, height: 0)
                VStack(spacing: 10) {
                    ForEach(0 ..< 24) {
                        Text("\($0)")
                    }
                }
            }
            .coordinateSpace(name: "scrollView")
            .onPreferenceChange(ScrollOffsetKey.self) { value in
                let delta = scrollOffset - value
                scrollOffset = value
                isScrolling = delta != 0
                if !isScrolling {
                    // The scroll view has stopped moving
                    print("Scrolling stopped")
                }
            }
            .frame(height: 100)
            Spacer()
            VStack {
                Text("Scrolling: \(isScrolling.description)")
            }
        }
    }
}

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/*struct UnitTimePicker: View {
    @State var currentTime: Double = CACurrentMediaTime();
    @State var lastTime: Double = CACurrentMediaTime();
    @State var currentPos: CGPoint = CGPoint(x: 0, y: 0)
    @State var lastPos: CGPoint = CGPoint(x: 0, y: 0)
    
    var body: some View {
        HStack {
            ScrollViewReader { proxy in
                BetterScrollView (showsIndicators: false, offsetChanged: {
                    lastPos = currentPos
                    currentPos = $0
                    
                    lastTime = currentTime;
                    currentTime = CACurrentMediaTime();
                }) {
                    VStack(spacing: 10) {
                        ForEach(0 ..< 24) {
                            Text("\($0)")
                        }
                    }
                }
                .frame(height: 100)
            }
            Spacer()
            VStack {
                Text("Delta: \(currentPos.y - lastPos.y)")
                Text("Velo: \((currentPos.y - lastPos.y) / (CACurrentMediaTime() - lastTime))")
                Text("Current: \(currentPos.y)")
                Text("Last: \(lastPos.y)")
                Text("Time: \(CACurrentMediaTime())")
            }
        }
    }
}*/

struct BetterScrollView<Content: View>: View {
    let axes: Axis.Set
    let showsIndicators: Bool
    let offsetChanged: (CGPoint) -> Void
    let content: Content

    init(
        axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        offsetChanged: @escaping (CGPoint) -> Void = { _ in },
        @ViewBuilder content: () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.offsetChanged = offsetChanged
        self.content = content()
    }
    
    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            GeometryReader { geometry in
                Color.clear.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: geometry.frame(in: .named("scrollView")).origin
                )
            }.frame(width: 0, height: 0)
            content
        }
        .coordinateSpace(name: "scrollView")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: offsetChanged)
    }
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
