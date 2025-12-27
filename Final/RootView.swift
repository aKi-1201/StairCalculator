//
//  RootView.swift
//  Final
//
//  Created by 114-1iosClassStudent05 on 2025/12/19.
//

import SwiftUI
import AlertToast

struct RootView: View {
    // Data Persistence (Settings)
    @AppStorage("defaultTreadDepth") private var defaultTreadDepth: Double = 26.0
    
    // Data Persistence (History)
    @StateObject private var historyManager = HistoryManager()
    
    // State Properties
    @State private var totalHeight: Double = 300.0
    @State private var idealRiserHeight: Double = 16.5
    @State private var treadDepth: Double = 26.0
    @State private var includeLanding: Bool = false
    @State private var landingDepth: Double = 120.0
    @State private var showScaleConverter: Bool = false
    @State private var showHistory: Bool = false
    @State private var projectDate: Date = Date()
    
    // AlertToast State
    @State private var showToast: Bool = false
    @State private var toastType: AlertToast.AlertType = .regular
    @State private var toastTitle: String = ""
    @State private var toastSubTitle: String? = nil
    
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
    
    var shareSummary: String {
        """
        樓梯計算紀錄
        日期：\(projectDate.formatted(date: .numeric, time: .omitted))
        
        總高度：\(totalHeight) 公分
        階數：\(numberOfRisers)
        實際級高：\(String(format: "%.2f", actualRiserHeight)) 公分
        級深：\(treadDepth) 公分
        總進深：\(String(format: "%.2f", totalRun)) 公分
        是否包含平台：\(includeLanding ? "是" : "否")
        """
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    StairDiagramView(
                        numberOfRisers: numberOfRisers,
                        includeLanding: includeLanding
                    )
                    .frame(height: 200)
                    .listRowInsets(EdgeInsets())
                    .background(Color(UIColor.systemGroupedBackground))
                }
                
                Section(header: Text("專案資訊")) {
                    DatePicker("日期", selection: $projectDate, displayedComponents: .date)
                }
                
                Section(header: Text("樓梯尺寸")) {
                    HStack {
                        Text("總高度 (cm)")
                        Spacer()
                        TextField("Height", value: $totalHeight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("理想級高")
                            Spacer()
                            Text("\(idealRiserHeight, specifier: "%.1f") cm")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $idealRiserHeight, in: 14...20, step: 0.5)
                    }
                    
                    HStack {
                        Text("級深 (cm)")
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
                
                Section(header: Text("配置設定")) {
                    Toggle("包含平台", isOn: $includeLanding)
                        .tint(.blue)
                    
                    if includeLanding {
                        HStack {
                            Text("平台深度 (cm)")
                            Spacer()
                            TextField("Depth", value: $landingDepth, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                        .transition(.slide)
                    }
                }
                
                Section(header: Text("計算結果")) {
                    ResultRow(label: "階數", value: "\(numberOfRisers)")
                    ResultRow(label: "實際級高", value: String(format: "%.2f cm", actualRiserHeight))
                    ResultRow(label: "總進深", value: String(format: "%.2f cm", totalRun))
                }
                
                Section {
                    Button(action: {
                        if totalHeight <= 0 {
                            toastType = .error(.red)
                            toastTitle = "錯誤"
                            toastSubTitle = "總高度必須大於0."
                            showToast = true
                        } else {
                            saveProject()
                        }
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("儲存至歷史")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    if #available(iOS 16.0, *) {
                        ShareLink(item: shareSummary) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("分享結果")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .navigationTitle("樓梯計算器")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showHistory = true
                    }) {
                        Image(systemName: "clock")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showScaleConverter = true
                    }) {
                        Image(systemName: "ruler")
                        Text("比例")
                    }
                }
            }
            .sheet(isPresented: $showScaleConverter) {
                ScaleConverterView()
            }
            .sheet(isPresented: $showHistory) {
                HistoryView(historyManager: historyManager)
            }
            .toast(isPresenting: $showToast) {
                AlertToast(displayMode: .hud, type: toastType, title: toastTitle, subTitle: toastSubTitle)
            }
            .animation(.easeInOut, value: includeLanding)
            .animation(.spring(), value: totalHeight)
        }
    }
    
    func saveProject() {
        let project = StairProject(
            date: projectDate,
            totalHeight: totalHeight,
            idealRiserHeight: idealRiserHeight,
            treadDepth: treadDepth,
            includeLanding: includeLanding,
            landingDepth: landingDepth,
            numberOfRisers: numberOfRisers,
            actualRiserHeight: actualRiserHeight,
            totalRun: totalRun
        )
        historyManager.saveProject(project)
        
        toastType = .complete(.green)
        toastTitle = "已儲存"
        toastSubTitle = "專案已儲存至歷史紀錄."
        showToast = true
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
            let padding: CGFloat = 20
            
            Canvas { context, size in
                let drawingWidth = size.width - 2 * padding
                let drawingHeight = size.height - 2 * padding
                
                let steps = CGFloat(numberOfRisers)
                if steps == 0 { return }
                
                let landingRatio: CGFloat = includeLanding ? 3.0 : 0.0
                let totalRunUnits = steps + landingRatio
                let totalRiseUnits = steps
                
                let unitWidth = drawingWidth / totalRunUnits
                let unitHeight = drawingHeight / totalRiseUnits
                
                var path = Path()
                path.move(to: CGPoint(x: padding, y: size.height - padding))
                
                for i in 0..<Int(steps) {
                    let x = padding + CGFloat(i) * unitWidth
                    let y = size.height - padding - CGFloat(i) * unitHeight
                    
                    path.addLine(to: CGPoint(x: x, y: y - unitHeight))
                    
                    if i < Int(steps) - 1 {
                        path.addLine(to: CGPoint(x: x + unitWidth, y: y - unitHeight))
                    } else {
                        if includeLanding {
                            path.addLine(to: CGPoint(x: x + unitWidth + (landingRatio * unitWidth), y: y - unitHeight))
                        } else {
                            path.addLine(to: CGPoint(x: x + unitWidth, y: y - unitHeight))
                        }
                    }
                }
                
                let finalX = includeLanding ? padding + drawingWidth : padding + steps * unitWidth
                
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
