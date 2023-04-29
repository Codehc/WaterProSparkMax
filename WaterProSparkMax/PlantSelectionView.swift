//
//  PlantSelectionView.swift
//  WaterProSparkMax
//
//  Created by Reza Bagheri on 4/29/23.
//

import SwiftUI

struct PlantSelectionView: View {
    @State var deleteMode: Bool = false
    @State var plants: [Config] = [
        Config(
            table: "Acacia Tree", usingPurelyInterval: false, interval: 0, wateringThreshold: 20, wateringTime: 5000, enabled: true
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                Divider()
                VStack() {
                    ForEach($plants) { plant in
                        PlantView(plant: plant, deleteMode: $deleteMode)
                        Divider()
                    }
                }
            }
            .navigationTitle("Plant")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation {
                            deleteMode.toggle()
                        }
                    }) {
                        if !deleteMode {
                            Text("Edit")
                        } else {
                            Text("Done")
                                .bold()
                        }
                    }
                    .foregroundColor(.teal)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        print("Add pressed")
                    }) {
                        Label("Add Folder", systemImage: "plus")
                            .foregroundColor(.teal)
                    }
                }
            }
        }
    }
}

struct PlantView: View {
    @Binding var plant: Config
    @Binding var deleteMode: Bool
    
    @State var editing = false
    
    var body: some View {
        HStack {
            ZStack {
                if deleteMode {
                    Button(action: {
                        
                    }) {
                        Label("", systemImage: "minus.circle.fill")
                            .foregroundColor(.red)
                            .imageScale(.large)
                    }
                }
            }
            .transition(.asymmetric(insertion: .slide, removal: .backslide))
            
            Button(action: {
                editing.toggle()
            }) {
                Text(plant.table)
                    .foregroundColor(plant.enabled ? .white : .gray)
                    .font(.system(size: 36))
                    .fontWeight(.light)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
            .sheet(isPresented: $editing) {
                ConfigView(config: $plant, editing: $editing)
            }
            Spacer()
            
            ZStack {
                if !deleteMode {
                    Toggle("Enabled", isOn: $plant.enabled)
                        .transition(.asymmetric(insertion: .slide, removal: .backslide).combined(with: .opacity))
                        .labelsHidden()
                } else {
                    Label("", systemImage: "chevron.right")
                        .transition(.asymmetric(insertion: .backslide, removal: .slide).combined(with: .opacity))
                }
            }
        }
        .foregroundColor(.gray)
        .padding()
    }
}

extension AnyTransition {
    static var backslide: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading))}
}

struct PlantSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        PlantSelectionView()
    }
}
