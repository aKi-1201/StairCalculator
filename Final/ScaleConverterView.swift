import SwiftUI

struct ScaleConverterView: View {
    @Environment(\.dismiss) var dismiss
    @State private var inputValue: Double = 100
    @State private var selectedScale: Int = 50 // Represents 1:50
    @State private var isRealToScaled: Bool = true
    
    let scales = [20, 50, 100, 200, 500]
    
    var resultValue: Double {
        if isRealToScaled {
            return inputValue / Double(selectedScale)
        } else {
            return inputValue * Double(selectedScale)
        }
    }
    
    var inputLabel: String {
        isRealToScaled ? "實際尺寸 (cm)" : "縮尺尺寸 (cm)"
    }
    
    var resultLabel: String {
        isRealToScaled ? "縮尺尺寸 (cm)" : "實際尺寸 (cm)"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("模式", selection: $isRealToScaled) {
                        Text("實際尺寸 → 縮尺").tag(true)
                        Text("縮尺 → 實際尺寸").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .listRowInsets(EdgeInsets())
                    .padding()
                }
                
                Section(header: Text("輸入")) {
                    HStack {
                        Text(inputLabel)
                        Spacer()
                        TextField("Value", value: $inputValue, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .font(.title3)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("比例 1:\(selectedScale)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("Scale", selection: $selectedScale) {
                            ForEach(scales, id: \.self) { scale in
                                Text("1:\(scale)").tag(scale)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                
                Section(header: Text("結果")) {
                    HStack {
                        Text(resultLabel)
                        Spacer()
                        Text(String(format: "%.2f", resultValue))
                            .font(.title2)
                            .bold()
                            .foregroundColor(.blue)
                    }
                }
                
                Section {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("完成")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .navigationTitle("比例換算")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("重設") {
                        inputValue = 0
                    }
                }
            }
        }
    }
}

struct ScaleConverterView_Previews: PreviewProvider {
    static var previews: some View {
        ScaleConverterView()
    }
}
