import Foundation

class ChargedLogService {
    static let shared = ChargedLogService()
    private let endpoint = "https://sheets.googleapis.com/v4/spreadsheets/1f1yibdEzIu_z_Wvi9p2sU18v-15QQXjtK5DqjG-zOkk/values/ChargedLog?key=AIzaSyBDz-gD-vsou2sAwM-AqxONGy3vdCNT-0g"

    struct APIResponse: Codable {
        let range: String
        let majorDimension: String
        let values: [[String]]
    }

    func fetchChargedLogs(completion: @escaping (Result<[ChargedLogEntry], Error>) -> Void) {
        guard let url = URL(string: endpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -2)))
                return
            }
            do {
                let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                let entries = self.parseRows(apiResponse.values)
                completion(.success(entries))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    private func parseRows(_ rows: [[String]]) -> [ChargedLogEntry] {
        guard rows.count > 1 else { return [] }
        let header = rows[0]
        let dataRows = rows.dropFirst()
        // 新欄位名稱完全比對 API header
        let totalMileageKey = "總里程(km)"
        let efficiencyKey = "電耗(km/kwh)"
        let pricePerKWhKey = "價格 / kwh"
        return dataRows.compactMap { row in
            ChargedLogEntry(
                date: row[safe: header.firstIndex(of: "日期") ?? 0] ?? "",
                totalMileage: row[safe: header.firstIndex(of: totalMileageKey) ?? 1],
                stageMileage: row[safe: header.firstIndex(of: "階段里程") ?? 2],
                chargedKWh: row[safe: header.firstIndex(of: "充電度數") ?? 3],
                efficiency: row[safe: header.firstIndex(of: efficiencyKey) ?? 4],
                pricePerKWh: row[safe: header.firstIndex(of: pricePerKWhKey) ?? 5],
                totalCost: row[safe: header.firstIndex(of: "總費用") ?? 6],
                chargeType: row[safe: header.firstIndex(of: "充電類型") ?? 7],
                note: row[safe: header.firstIndex(of: "備註") ?? 9]
            )
        }
    }
}

// Array safe index extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
