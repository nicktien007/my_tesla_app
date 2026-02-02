import Foundation

class ChargedLogService {
    static let shared = ChargedLogService()

    private let spreadsheetId = "1f1yibdEzIu_z_Wvi9p2sU18v-15QQXjtK5DqjG-zOkk"
    private let chargedLogRange = "ChargedLog"
    private let statisticsRange = "統計!A:H"

    private let apiKey: String
    
    // P1-1: 自訂 URLSession 配置
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30  // 請求超時 30 秒
        config.timeoutIntervalForResource = 60 // 資源超時 60 秒
        config.waitsForConnectivity = true
        // 使用適度的快取策略，平衡性能與資料新鮮度
        config.requestCachePolicy = .useProtocolCachePolicy
        config.urlCache = URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 50 * 1024 * 1024)
        
        // 背景策略：不使用延長背景閒置模式
        config.shouldUseExtendedBackgroundIdleMode = false
        
        return URLSession(configuration: config)
    }()

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

    @discardableResult
    func fetchChargedLogs(forceRefresh: Bool = false, completion: @escaping (Result<[ChargedLogEntry], Error>) -> Void) -> URLSessionDataTask? {
        guard let url = URL(string: chargedLogEndpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return nil
        }

        print("ChargedLog API URL: \(url.absoluteString) (forceRefresh: \(forceRefresh))")

        var request = URLRequest(url: url)
        // 手動刷新時忽略快取，否則使用預設策略
        if forceRefresh {
            request.cachePolicy = .reloadIgnoringLocalCacheData
        }

        let task = urlSession.dataTask(with: request) { data, response, error in
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
        }
        task.resume()
        return task
    }

    @discardableResult
    func fetchStatistics(forceRefresh: Bool = false, completion: @escaping (Result<[StatisticsEntry], Error>) -> Void) -> URLSessionDataTask? {
        guard let url = URL(string: statisticsEndpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return nil
        }
        
        print("Statistics API URL: \(url.absoluteString) (forceRefresh: \(forceRefresh))")
        
        var request = URLRequest(url: url)
        // 手動刷新時忽略快取，否則使用預設策略
        if forceRefresh {
            request.cachePolicy = .reloadIgnoringLocalCacheData
        }
        
        let task = urlSession.dataTask(with: request) { data, response, error in
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
                let entries = self.parseStatisticsRows(apiResponse.values)
                completion(.success(entries))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
        return task
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
                date: (header.firstIndex(of: "日期").flatMap { row[$0] }) ?? "",
                totalMileage: header.firstIndex(of: totalMileageKey).flatMap { row[$0] },
                stageMileage: nil,
                chargedKWh: header.firstIndex(of: "充電度數").flatMap { row[$0] },
                mileage: header.firstIndex(of: mileageKey).flatMap { row[$0] },
                pricePerKWh: header.firstIndex(of: pricePerKWhKey).flatMap { row[$0] },
                totalCost: header.firstIndex(of: "總費用").flatMap { row[$0] },
                chargeType: header.firstIndex(of: "充電類型").flatMap { row[$0] }
            )
        }
    }

    private func parseStatisticsRows(_ rows: [[String]]) -> [StatisticsEntry] {
        guard rows.count > 1 else { return [] }
        let header = rows[0]
        let dataRows = rows.dropFirst()
        
        return dataRows.compactMap { row in
            StatisticsEntry(
                date: (header.firstIndex(of: "日期").flatMap { row[$0] }) ?? "",
                year: (header.firstIndex(of: "年").flatMap { row[$0] }) ?? "",
                month: (header.firstIndex(of: "月").flatMap { row[$0] }) ?? "",
                stageMileage: header.firstIndex(of: "統計階段里程(KM)").flatMap { row[$0] },
                chargedKWh: header.firstIndex(of: "統計充電度數").flatMap { row[$0] },
                avgEfficiency: header.firstIndex(of: "統計平均電耗(km/kwh)").flatMap { row[$0] },
                avgPricePerKWh: header.firstIndex(of: "統計平均每度價格").flatMap { row[$0] },
                totalCost: header.firstIndex(of: "統計總費用").flatMap { row[$0] }
            )
        }
    }
}