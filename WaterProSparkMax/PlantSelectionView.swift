//
//  PlantSelectionView.swift
//  WaterProSparkMax
//
//  Created by Reza Bagheri on 4/29/23.
//

import SwiftUI
import FirebaseDatabase

struct PlantSelectionView: View {
    @State var deleteMode: Bool = false
    
    @EnvironmentObject var plants: ConfigList
    
    /*
     Config(
         table: "Acacia Tree", usingPurelyInterval: false, interval: 0, wateringThreshold: 20, wateringTime: 5000, enabled: true
     )
     */
    
    var body: some View {
        NavigationView {
            ZStack {
                if (plants.configurations.count != 0) {
                    ScrollView(showsIndicators: false) {
                        HStack {
                            Spacer()
                            VStack() {
                                Divider()
                                ForEach(0 ..< plants.configurations.count, id: \.self) { plantId in
                                    HStack {
                                        Spacer()
                                        if deleteMode {
                                            Button(action: {
                                                let uuid = plants.configurations[plantId].id
                                                plants.configurations.remove(at: plantId)
                                                plants.deleteAtUUID(uuid: uuid)
                                            }) {
                                                Label("", systemImage: "minus.circle.fill")
                                                    .foregroundColor(.red)
                                                    .imageScale(.large)
                                            }
                                            .transition(.asymmetric(insertion: .slide, removal: .backslide).combined(with: .opacity))
                                        }
                                        
                                        PlantView(deleteMode: $deleteMode).environmentObject(plants.configurations[plantId])
                                            .environmentObject(plants)
                                    }
                                    Divider()
                                }
                            }
                        }
                    }
                } else {
                    ProgressView("Loading")
                        .progressViewStyle(.circular)
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
                        plants.configurations.append(Config(
                            table: "Default", usingPurelyInterval: false, interval: 0, wateringThreshold: 20, wateringTime: 0, enabled: true
                        ))
                        
                        plants.writeToConfig(config: plants.configurations[plants.configurations.count - 1])
                    }) {
                        Label("Add Plant", systemImage: "plus")
                            .foregroundColor(.teal)
                    }
                }
            }
            .onDisappear() {
                plants.stopListening()
            }
        }
    }
}

struct PlantView: View {
    @EnvironmentObject var plant: Config
    @EnvironmentObject var plants: ConfigList
    
    @Binding var deleteMode: Bool
    
    @State var editing: Bool = false
    
    var body: some View {
        HStack {
            Button(action: {
                editing.toggle()
            }) {
                Text(plant.name)
                    .foregroundColor(plant.enabled ? .white : .gray)
                    .font(.system(size: 36))
                    .fontWeight(.light)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
            .sheet(isPresented: $editing) {
                ConfigView()
            }
            Spacer()
            
            ZStack {
                if !deleteMode {
                    Toggle("Enabled", isOn: $plant.enabled)
                        .onChange(of: plant.enabled) { _ in
                            plants.writeToConfig(config: plant)
                        }
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
