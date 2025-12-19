//
//  RootView.swift
//  Final
//
//  Created by 114-1iosClassStudent05 on 2025/12/19.
//

import SwiftUI

struct RootView: View {
    // Data Persistence
    @AppStorage("defaultTreadDepth") private var defaultTreadDepth: Double = 26.0
    
    // State Properties
    @State private var totalHeight: Double = 300.0
    @State private var idealRiserHeight: Double = 16.5
    @State private var treadDepth: Double = 26.0
    @State private var includeLanding: Bool = false
    @State private var landingDepth: Double = 120.0
    @State private var showScaleConverter: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var projectDate: Date = Date()
    
    // Computed Properties for Calculation
    var numberOfRisers: Int {
        if idealRiserHeight <= 0 { return 0 }
        return Int(round(totalHeight / idealRiserHeight))
    }
    
    var actualRiserHeight: Double {
        if numberOfRisers == 0 { return 0 }
        return totalHeight / Double(numberOfRisers)
    }
    
    var totalRun: Double {
        let runCount = max(0, numberOfRisers - 1)
        var run = Double(runCount) * treadDepth
        if includeLanding {
            run += landingDepth
        }
        return run
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    // Visual Diagram
                    StairDiagramView(
                        numberOfRisers: numberOfRisers,
                        includeLanding: includeLanding
                    )
                    .frame(height: 200)
                    .listRowInsets(EdgeInsets()) // Make it full width
                    .background(Color(UIColor.systemGroupedBackground))
                }
                
                Section(header: Text("Project Info")) {
                    DatePicker("Date", selection: $projectDate, displayedComponents: .date)
                }
                
                Section(header: Text("Dimensions Input")) {
                    HStack {
                        Text("Total Height (cm)")
                        Spacer()
                        TextField("Height", value: $totalHeight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Ideal Riser Height")
                            Spacer()
                            Text("\(idealRiserHeight, specifier: "%.1f") cm")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $idealRiserHeight, in: 14...20, step: 0.5)
                    }
                    
                    HStack {
                        Text("Tread Depth (cm)")
                        Spacer()
                        TextField("Depth", value: $treadDepth, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    .onAppear {
                        if treadDepth == 0 { treadDepth = defaultTreadDepth }
                    }
                    .onChange(of: treadDepth) { newValue in
                        defaultTreadDepth = newValue
                    }
                }
                
                Section(header: Text("Configuration")) {
                    Toggle("Include Landing", isOn: $includeLanding)
                        .tint(.blue)
                    
                    if includeLanding {
                        HStack {
                            Text("Landing Depth (cm)")
                            Spacer()
                            TextField("Depth", value: $landingDepth, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                        .transition(.slide)
                    }
                }
                
                Section(header: Text("Results")) {
                    ResultRow(label: "Number of Risers", value: "\(numberOfRisers)")
                    ResultRow(label: "Actual Riser Height", value: String(format: "%.2f cm", actualRiserHeight))
                    ResultRow(label: "Total Run Length", value: String(format: "%.2f cm", totalRun))
                }
                
                Section {
                    Button(action: {
                        if totalHeight <= 0 {
                            alertMessage = "Total height must be greater than 0."
                            showAlert = true
                        } else {
                            // Trigger some action or just validate
                        }
                    }) {
                        Text("Validate Inputs")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Stair Calculator")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showScaleConverter = true
                    }) {
                        Image(systemName: "ruler")
                        Text("Scale")
                    }
                }
            }
            .sheet(isPresented: $showScaleConverter) {
                ScaleConverterView()
            }
            .alert("Input Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .animation(.easeInOut, value: includeLanding)
            .animation(.spring(), value: totalHeight)
        }
    }
}

struct ResultRow: View {
    var label: String
    var value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
                .foregroundColor(.primary)
        }
    }
}

struct StairDiagramView: View {
    var numberOfRisers: Int
    var includeLanding: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let padding: CGFloat = 20
            
            Canvas { context, size in
                let drawingWidth = size.width - 2 * padding
                let drawingHeight = size.height - 2 * padding
                
                // Calculate step dimensions for drawing
                // We want to fit the stairs in the box
                // Total steps = numberOfRisers
                // If landing, add extra width
                
                let steps = CGFloat(numberOfRisers)
                if steps == 0 { return }
                
                // Aspect ratio of the stairs
                // Let's assume a standard ratio for visualization or just fit to box
                // We'll fit to box.
                
                // Each step goes UP and RIGHT.
                // Total UP = steps
                // Total RIGHT = steps (approx) + landing
                
                let landingRatio: CGFloat = includeLanding ? 3.0 : 0.0 // Landing is roughly 3 steps wide visually
                let totalRunUnits = steps + landingRatio
                let totalRiseUnits = steps
                
                let unitWidth = drawingWidth / totalRunUnits
                let unitHeight = drawingHeight / totalRiseUnits
                
                // Use the smaller unit to maintain aspect ratio somewhat, or just stretch?
                // Let's stretch to fill for clarity, or maintain aspect if possible.
                // Let's just fill the available space.
                
                var path = Path()
                path.move(to: CGPoint(x: padding, y: size.height - padding))
                
                for i in 0..<Int(steps) {
                    let x = padding + CGFloat(i) * unitWidth
                    let y = size.height - padding - CGFloat(i) * unitHeight
                    
                    // Riser (Up)
                    path.addLine(to: CGPoint(x: x, y: y - unitHeight))
                    
                    // Tread (Right)
                    if i < Int(steps) - 1 {
                        path.addLine(to: CGPoint(x: x + unitWidth, y: y - unitHeight))
                    } else {
                        // Last step / Landing
                        if includeLanding {
                            path.addLine(to: CGPoint(x: x + unitWidth + (landingRatio * unitWidth), y: y - unitHeight))
                        } else {
                            path.addLine(to: CGPoint(x: x + unitWidth, y: y - unitHeight))
                        }
                    }
                }
                
                // Close the shape to fill it
                let finalX = includeLanding ? padding + drawingWidth : padding + steps * unitWidth
                let finalY = size.height - padding - steps * unitHeight
                
                path.addLine(to: CGPoint(x: finalX, y: size.height - padding))
                path.closeSubpath()
                
                context.fill(path, with: .color(.blue.opacity(0.3)))
                context.stroke(path, with: .color(.blue), lineWidth: 2)
                
            }
        }
        .background(Color.white)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
