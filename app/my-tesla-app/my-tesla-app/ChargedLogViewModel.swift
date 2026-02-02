import Foundation
import Combine

class ChargedLogViewModel: ObservableObject {
    /// 上次進入前景的時間
    private var lastActiveDate: Date? = nil
    /// 最小自動刷新間隔（秒）- 改為 30 分鐘減少背景刷新
    let minRefreshInterval: TimeInterval = 1800 // 30 分鐘
    
    /// 當前進行中的網路請求
    private var currentTask: URLSessionDataTask?
    @Published var logs: [ChargedLogEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // 日期篩選
    @Published var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @Published var endDate: Date = Date()
    // 類型篩選
    @Published var chargeTypeFilter: String = "all" // "all", "ACSingleWireCAN", "Supercharger"

    private var cancellables = Set<AnyCancellable>()

    // 日期格式化器（只初始化一次）
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd H:mm:ss"
        return formatter
    }()

    // 依據日期與類型篩選後的資料
    var logsFiltered: [ChargedLogEntry] {
        let formatter = Self.dateFormatter
        let start = startDate
        let end = endDate
        let type = chargeTypeFilter
        var filtered: [ChargedLogEntry] = []
        for entry in logs {
            if let entryDate = formatter.date(from: entry.date) {
                let dateInRange = entryDate >= start && entryDate <= end
                let typeMatch = type == "all" || entry.chargeType == type
                if dateInRange && typeMatch {
                    filtered.append(entry)
                }
            }
        }
        return filtered
    }

    // 查詢區間總充電度數
    var currentPeriodKWh: Double {
        logsFiltered.compactMap { Double($0.chargedKWh ?? "") }.reduce(0, +)
    }

    // 查詢區間總充電費用
    var currentPeriodCost: Double {
        logsFiltered.compactMap { Double($0.totalCost ?? "") }.reduce(0, +)
    }

    // 查詢區間平均每度電費用
    var currentPeriodAvgCostPerKWh: Double? {
        let kWh = currentPeriodKWh
        guard kWh > 0 else { return nil }
        return currentPeriodCost / kWh
    }

    // 前一區間總充電度數
    var previousPeriodKWh: Double {
        let interval = endDate.timeIntervalSince(startDate)
        let prevEnd = Calendar.current.date(byAdding: .second, value: -1, to: startDate) ?? startDate
        let prevStart = Calendar.current.date(byAdding: .second, value: -Int(interval), to: startDate) ?? startDate
        let prevLogs = logs.filter { log in
            guard let date = Self.dateFormatter.date(from: log.date) else { return false }
            return date >= prevStart && date <= prevEnd
        }
        return prevLogs.compactMap { Double($0.chargedKWh ?? "") }.reduce(0, +)
    }

    // 前一區間總充電費用
    var previousPeriodCost: Double {
        let interval = endDate.timeIntervalSince(startDate)
        let prevEnd = Calendar.current.date(byAdding: .second, value: -1, to: startDate) ?? startDate
        let prevStart = Calendar.current.date(byAdding: .second, value: -Int(interval), to: startDate) ?? startDate
        let prevLogs = logs.filter { log in
            guard let date = Self.dateFormatter.date(from: log.date) else { return false }
            return date >= prevStart && date <= prevEnd
        }
        return prevLogs.compactMap { Double($0.totalCost ?? "") }.reduce(0, +)
    }

    // kWh 動態比較文字（含前期區間）
    var kWhComparisonText: String {
        let prev = previousPeriodKWh
        let curr = currentPeriodKWh
        guard prev > 0 else { return "—" }
        let percent = ((curr - prev) / prev) * 100
        let sign = percent >= 0 ? "+" : ""
        let interval = endDate.timeIntervalSince(startDate)
        let prevEnd = Calendar.current.date(byAdding: .second, value: -1, to: startDate) ?? startDate
        let prevStart = Calendar.current.date(byAdding: .second, value: -Int(interval), to: startDate) ?? startDate
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        let prevStartStr = formatter.string(from: prevStart)
        let prevEndStr = formatter.string(from: prevEnd)
        return "較前期 (\(prevStartStr)~\(prevEndStr)) \(sign)\(String(format: "%.1f", percent))%"
    }

    // 費用動態比較文字（含前期區間）
    var costComparisonText: String {
        let prev = previousPeriodCost
        let curr = currentPeriodCost
        guard prev > 0 else { return "—" }
        let percent = ((curr - prev) / prev) * 100
        let sign = percent >= 0 ? "+" : ""
        let interval = endDate.timeIntervalSince(startDate)
        let prevEnd = Calendar.current.date(byAdding: .second, value: -1, to: startDate) ?? startDate
        let prevStart = Calendar.current.date(byAdding: .second, value: -Int(interval), to: startDate) ?? startDate
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        let prevStartStr = formatter.string(from: prevStart)
        let prevEndStr = formatter.string(from: prevEnd)
        return "較前期 (\(prevStartStr)~\(prevEndStr)) \(sign)\(String(format: "%.1f", percent))%"
    }

    func loadLogs(forceRefresh: Bool = false) {
        isLoading = true
        errorMessage = nil
        
        // 先取消之前的請求
        currentTask?.cancel()
        
        // 取得 task 並儲存
        currentTask = ChargedLogService.shared.fetchChargedLogs(forceRefresh: forceRefresh) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.currentTask = nil // 請求完成，清空
                
                switch result {
                case .success(let logs):
                    self?.logs = logs
                case .failure(let error):
                    // 區分取消與真實錯誤
                    if (error as? URLError)?.code != .cancelled {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    /// 取消進行中的網路請求
    func cancelPendingRequests() {
        currentTask?.cancel()
        currentTask = nil
        isLoading = false
    }
    
    /// 確保資源清理
    deinit {
        cancelPendingRequests()
        print("✅ ChargedLogViewModel deinitialized")
    }

    /// 進入前景時自動更新查詢時間並刷新資料（有最小間隔限制）
    func refreshIfNeeded(minInterval: TimeInterval? = nil) {
        let now = Date()
        let interval = minInterval ?? minRefreshInterval
        if let last = lastActiveDate, now.timeIntervalSince(last) < interval {
            // 未超過最小間隔，不刷新
            return
        }
        lastActiveDate = now
        self.endDate = now
        loadLogs(forceRefresh: false) // 自動刷新允許使用快取
    }

    /// 手動刷新，無間隔限制，startDate 也重設為一個月前
    func manualRefresh() {
        let now = Date()
        lastActiveDate = now
        self.endDate = now
        self.startDate = Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now
        loadLogs(forceRefresh: true) // 手動刷新強制從伺服器取得最新資料
    }
}

