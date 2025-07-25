import Foundation


struct ChargedLogEntry: Identifiable, Codable {
    let id: UUID
    let date: String
    let totalMileage: String?
    let stageMileage: String?
    let chargedKWh: String?
    let mileage: String? // 里程
    let pricePerKWh: String?
    let totalCost: String?
    let chargeType: String?

    init(id: UUID = UUID(), date: String, totalMileage: String?, stageMileage: String?, chargedKWh: String?, mileage: String?, pricePerKWh: String?, totalCost: String?, chargeType: String?) {
        self.id = id
        self.date = date
        self.totalMileage = totalMileage
        self.stageMileage = stageMileage
        self.chargedKWh = chargedKWh
        self.mileage = mileage
        self.pricePerKWh = pricePerKWh
        self.totalCost = totalCost
        self.chargeType = chargeType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        self.date = try container.decode(String.self, forKey: .date)
        self.totalMileage = try container.decodeIfPresent(String.self, forKey: .totalMileage)
        self.stageMileage = try container.decodeIfPresent(String.self, forKey: .stageMileage)
        self.chargedKWh = try container.decodeIfPresent(String.self, forKey: .chargedKWh)
        self.mileage = try container.decodeIfPresent(String.self, forKey: .mileage)
        self.pricePerKWh = try container.decodeIfPresent(String.self, forKey: .pricePerKWh)
        self.totalCost = try container.decodeIfPresent(String.self, forKey: .totalCost)
        self.chargeType = try container.decodeIfPresent(String.self, forKey: .chargeType)
    }
}
