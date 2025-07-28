import Foundation
import Combine

class ChargedLogViewModel: ObservableObject {
    /// 上次進入前景的時間
    private var lastActiveDate: Date? = nil
    /// 最小自動刷新間隔（秒）
    let minRefreshInterval: TimeInterval = 600 // 10 分鐘
    @Published var logs: [ChargedLogEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // 日期篩選
    @Published var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @Published var endDate: Date = Date()

    private var cancellables = Set<AnyCancellable>()

    // 日期格式化器（只初始化一次）
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd H:mm:ss"
        return formatter
    }()

    // 依據日期篩選後的資料
    var logsFiltered: [ChargedLogEntry] {
        let formatter = Self.dateFormatter
        let start = startDate
        let end = endDate
        var filtered: [ChargedLogEntry] = []
        for entry in logs {
            if let entryDate = formatter.date(from: entry.date) {
                if entryDate >= start && entryDate <= end {
                    filtered.append(entry)
                }
            }
        }
        return filtered
    }

    func loadLogs() {
        isLoading = true
        errorMessage = nil
        ChargedLogService.shared.fetchChargedLogs { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let logs):
                    self?.logs = logs
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
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
        loadLogs()
    }

    /// 手動刷新，無間隔限制，startDate 也重設為一個月前
    func manualRefresh() {
        let now = Date()
        lastActiveDate = now
        self.endDate = now
        self.startDate = Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now
        loadLogs()
    }
}

