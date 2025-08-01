import Foundation

struct StatisticsEntry: Identifiable, Codable {
    let id: UUID
    let date: String
    let year: String
    let month: String
    let stageMileage: String?
    let chargedKWh: String?
    let avgEfficiency: String?
    let avgPricePerKWh: String?
    let totalCost: String?
    
    init(id: UUID = UUID(), 
         date: String,
         year: String, 
         month: String, 
         stageMileage: String?, 
         chargedKWh: String?, 
         avgEfficiency: String?, 
         avgPricePerKWh: String?, 
         totalCost: String?) {
        self.id = id
        self.date = date
        self.year = year
        self.month = month
        self.stageMileage = stageMileage
        self.chargedKWh = chargedKWh
        self.avgEfficiency = avgEfficiency
        self.avgPricePerKWh = avgPricePerKWh
        self.totalCost = totalCost
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        self.date = try container.decode(String.self, forKey: .date)
        self.year = try container.decode(String.self, forKey: .year)
        self.month = try container.decode(String.self, forKey: .month)
        self.stageMileage = try container.decodeIfPresent(String.self, forKey: .stageMileage)
        self.chargedKWh = try container.decodeIfPresent(String.self, forKey: .chargedKWh)
        self.avgEfficiency = try container.decodeIfPresent(String.self, forKey: .avgEfficiency)
        self.avgPricePerKWh = try container.decodeIfPresent(String.self, forKey: .avgPricePerKWh)
        self.totalCost = try container.decodeIfPresent(String.self, forKey: .totalCost)
    }
    
    // 轉換為數值的便利方法
    var chargedKWhValue: Double {
        Double(chargedKWh ?? "") ?? 0
    }
    
    var totalCostValue: Double {
        Double(totalCost ?? "") ?? 0
    }
    
    var stageMileageValue: Double {
        Double(stageMileage ?? "") ?? 0
    }
    
    var avgEfficiencyValue: Double {
        Double(avgEfficiency ?? "") ?? 0
    }
    
    var avgPricePerKWhValue: Double {
        Double(avgPricePerKWh ?? "") ?? 0
    }
}
