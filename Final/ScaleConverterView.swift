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
        isRealToScaled ? "Real Dimension (cm)" : "Scaled Dimension (cm)"
    }
    
    var resultLabel: String {
        isRealToScaled ? "Scaled Dimension (cm)" : "Real Dimension (cm)"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Mode", selection: $isRealToScaled) {
                        Text("Real → Scaled").tag(true)
                        Text("Scaled → Real").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .listRowInsets(EdgeInsets())
                    .padding()
                }
                
                Section(header: Text("Input")) {
                    HStack {
                        Text(inputLabel)
                        Spacer()
                        TextField("Value", value: $inputValue, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .font(.title3)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Scale 1:\(selectedScale)")
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
                
                Section(header: Text("Result")) {
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
                        Text("Done")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .navigationTitle("Scale Converter")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
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
