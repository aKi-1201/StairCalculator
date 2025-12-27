import Foundation
import SwiftUI
import Combine

struct StairProject: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var totalHeight: Double
    var idealRiserHeight: Double
    var treadDepth: Double
    var includeLanding: Bool
    var landingDepth: Double
    
    // Computed results to save snapshot
    var numberOfRisers: Int
    var actualRiserHeight: Double
    var totalRun: Double
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

class HistoryManager: ObservableObject {
    @Published var projects: [StairProject] = []
    
    private let fileName = "stair_projects.json"
    
    init() {
        loadProjects()
    }
    
    private var fileURL: URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    func saveProject(_ project: StairProject) {
        projects.insert(project, at: 0)
        saveToDisk()
    }
    
    func deleteProject(at offsets: IndexSet) {
        projects.remove(atOffsets: offsets)
        saveToDisk()
    }
    
    private func saveToDisk() {
        guard let url = fileURL else { return }
        
        do {
            let data = try JSONEncoder().encode(projects)
            try data.write(to: url)
        } catch {
            print("Error saving projects: \(error.localizedDescription)")
        }
    }
    
    private func loadProjects() {
        guard let url = fileURL else { return }
        
        do {
            let data = try Data(contentsOf: url)
            projects = try JSONDecoder().decode([StairProject].self, from: data)
        } catch {
            print("Error loading projects: \(error.localizedDescription)")
        }
    }
}
