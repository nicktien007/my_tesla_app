import Foundation

class ChargedLogService {
    static let shared = ChargedLogService()

    private let spreadsheetId = "1f1yibdEzIu_z_Wvi9p2sU18v-15QQXjtK5DqjG-zOkk"
    private let chargedLogRange = "ChargedLog"
    private let statisticsRange = "統計!A:H"

    private let apiKey: String

    init() {
        // 讀取 Config.plist 內 GOOGLE_SHEETS_API_KEY
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let key = dict["GOOGLE_SHEETS_API_KEY"] as? String {
            self.apiKey = key
        } else {
            self.apiKey = ""
        }
    }

    private var chargedLogEndpoint: String {
        "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId)/values/\(chargedLogRange)?key=\(apiKey)"
    }
    private var statisticsEndpoint: String {
        "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId)/values/\(statisticsRange)?key=\(apiKey)"
    }

    struct APIResponse: Codable {
        let range: String
        let majorDimension: String
        let values: [[String]]
    }

    func fetchChargedLogs(completion: @escaping (Result<[ChargedLogEntry], Error>) -> Void) {
        guard let url = URL(string: chargedLogEndpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }

        print("ChargedLog API URL: \(url.absoluteString)")

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

    func fetchStatistics(completion: @escaping (Result<APIResponse, Error>) -> Void) {
        guard let url = URL(string: statisticsEndpoint) else {
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
                completion(.success(apiResponse))
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
    // let efficiencyKey = "電耗(km/kwh)" // 已移除
        let pricePerKWhKey = "價格 / kwh"
    let mileageKey = "階段里程"
        return dataRows.compactMap { row in
            ChargedLogEntry(
                date: row[safe: header.firstIndex(of: "日期") ?? 0] ?? "",
                totalMileage: row[safe: header.firstIndex(of: totalMileageKey) ?? 1],
                stageMileage: nil,
                chargedKWh: row[safe: header.firstIndex(of: "充電度數") ?? 3],
                mileage: row[safe: header.firstIndex(of: mileageKey) ?? 2],
                pricePerKWh: row[safe: header.firstIndex(of: pricePerKWhKey) ?? 5],
                totalCost: row[safe: header.firstIndex(of: "總費用") ?? 6],
                chargeType: row[safe: header.firstIndex(of: "充電類型") ?? 7]
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
