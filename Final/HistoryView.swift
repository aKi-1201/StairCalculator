import SwiftUI

struct HistoryView: View {
    @ObservedObject var historyManager: HistoryManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(historyManager.projects) { project in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(project.formattedDate)
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Height: \(String(format: "%.1f", project.totalHeight)) cm")
                                Text("Risers: \(project.numberOfRisers)")
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("總進深：\(String(format: "%.1f", project.totalRun)) cm")
                                Text("級高：\(String(format: "%.2f", project.actualRiserHeight)) cm")
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: historyManager.deleteProject)
            }
            .navigationTitle("Saved Projects")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .overlay(
                Group {
                    if historyManager.projects.isEmpty {
                        Text("No saved projects yet")
                            .foregroundColor(.secondary)
                    }
                }
            )
        }
    }
}
