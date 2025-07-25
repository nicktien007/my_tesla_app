import Foundation

struct ChargedLogEntry: Identifiable, Codable {
    let id = UUID()
    let date: String
    let totalMileage: String?
    let stageMileage: String?
    let chargedKWh: String?
    let efficiency: String?
    let pricePerKWh: String?
    let totalCost: String?
    let chargeType: String?
    let note: String?
}
