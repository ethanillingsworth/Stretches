import SwiftUI

class SaveManager {
    static func save(_ data: [BaseTask]) {
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data) {
            UserDefaults.standard.set(encoded, forKey: "save")
        }
        
    }
    
    static func load() -> [BaseTask]? {
        if let data = UserDefaults.standard.object(forKey: "save") as? Data {
            let decoder = JSONDecoder()
            if let savedData = try? decoder.decode([BaseTask].self, from: data) {
                return savedData
            }
            
        }
        return nil
    }
    
    static func clear() {
        UserDefaults.standard.set(nil, forKey: "save")
    }
}
