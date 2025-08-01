import Foundation
import Combine

class StatisticsViewModel: ObservableObject {
    @Published var statistics: [StatisticsEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // 篩選條件
    @Published var selectedYear: String = ""
    @Published var selectedTimeRange: TimeRangeFilter = .sixMonths
    @Published var filterTip: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    enum TimeRangeFilter: String, CaseIterable, Identifiable {
        case threeMonths = "3months"
        case sixMonths = "6months"
        case oneYear = "1year"
        case all = "all"
        
        var id: String { rawValue }
        
        var display: String {
            switch self {
            case .threeMonths: return "近 3 個月"
            case .sixMonths: return "近 6 個月"
            case .oneYear: return "近 1 年"
            case .all: return "全部"
            }
        }
    }
    
    init() {
        // 設定預設年份為當前年份
        let currentYear = Calendar.current.component(.year, from: Date())
        selectedYear = String(currentYear)
        
        // 監聽篩選條件變化，實現自動切換
        $selectedYear
            .sink { [weak self] year in
                guard let self = self else { return }
                if !year.isEmpty && year != "all" {
                    // 選擇特定年份時，自動設為全部時間範圍
                    if self.selectedTimeRange != .all {
                        self.selectedTimeRange = .all
                        self.filterTip = "已自動切換到「全部時間範圍」以顯示 \(year) 年資料"
                        self.clearTipAfterDelay()
                    }
                }
            }
            .store(in: &cancellables)
        
        $selectedTimeRange
            .sink { [weak self] timeRange in
                guard let self = self else { return }
                if timeRange != .all {
                    // 選擇特定時間範圍時，自動設為全部年份
                    if !self.selectedYear.isEmpty && self.selectedYear != "all" {
                        self.selectedYear = "all"
                        self.filterTip = "已自動切換到「全部年份」以顯示\(timeRange.display)資料"
                        self.clearTipAfterDelay()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // 可用的年份列表
    var availableYears: [String] {
        let years = Set(statistics.map { $0.year })
        return ["all"] + Array(years).sorted(by: >)
    }
    
    // 根據篩選條件過濾的統計資料
    var filteredStatistics: [StatisticsEntry] {
        var filtered = statistics
        
        // 年份篩選
        if !selectedYear.isEmpty && selectedYear != "all" {
            filtered = filtered.filter { $0.year == selectedYear }
        }
        
        // 時間範圍篩選（以現在時間為基準）
        if selectedTimeRange != .all {
            // 依年月排序，直接取最後N筆（跨年）
            let sorted = filtered.sorted {
                let aKey = (Int($0.year) ?? 0) * 100 + (Int($0.month) ?? 0)
                let bKey = (Int($1.year) ?? 0) * 100 + (Int($1.month) ?? 0)
                return aKey < bKey
            }
            let takeCount: Int
            switch selectedTimeRange {
            case .threeMonths: takeCount = 3
            case .sixMonths: takeCount = 6
            case .oneYear: takeCount = 12
            case .all: takeCount = sorted.count
            }
            filtered = Array(sorted.suffix(takeCount))
        }
        
        return filtered.sorted { a, b in
            // 按年月排序
            let aDate = "\(a.year)/\(a.month)"
            let bDate = "\(b.year)/\(b.month)"
            return aDate < bDate
        }
    }
    
    // 總充電量
    var totalChargedKWh: Double {
        filteredStatistics.reduce(0) { $0 + $1.chargedKWhValue }
    }
    
    // 總費用
    var totalCost: Double {
        filteredStatistics.reduce(0) { $0 + $1.totalCostValue }
    }
    
    // 總里程
    var totalMileage: Double {
        filteredStatistics.reduce(0) { $0 + $1.stageMileageValue }
    }
    
    // 平均電耗
    var averageEfficiency: Double {
        let entries = filteredStatistics.filter { $0.avgEfficiencyValue > 0 }
        guard !entries.isEmpty else { return 0 }
        return entries.reduce(0) { $0 + $1.avgEfficiencyValue } / Double(entries.count)
    }
    
    // 平均每度價格
    var averagePricePerKWh: Double {
        let entries = filteredStatistics.filter { $0.avgPricePerKWhValue > 0 }
        guard !entries.isEmpty else { return 0 }
        return entries.reduce(0) { $0 + $1.avgPricePerKWhValue } / Double(entries.count)
    }
    
    // 月度充電量資料（用於圖表）
    var monthlyChargedData: [(month: String, value: Double)] {
        let stats = filteredStatistics.sorted {
            let aKey = (Int($0.year) ?? 0) * 100 + (Int($0.month) ?? 0)
            let bKey = (Int($1.year) ?? 0) * 100 + (Int($1.month) ?? 0)
            return aKey < bKey
        }
        // 判斷是否跨年
        let years = Set(stats.map { $0.year })
        let showYear = years.count > 1
        return stats.map { entry in
            let yearShort = String(entry.year.suffix(2))
            let monthDisplay = showYear ? "\(yearShort)/\(entry.month)" : "\(entry.month)"
            return (month: monthDisplay, value: entry.chargedKWhValue)
        }
    }
    
    // 月度費用資料（用於圖表）
    var monthlyCostData: [(month: String, value: Double)] {
        return filteredStatistics.map { entry in
            let monthDisplay = "\(entry.year)/\(entry.month)"
            return (month: monthDisplay, value: entry.totalCostValue)
        }
    }
    
    // 效率 vs 費用資料（用於圖表）
    var efficiencyVsCostData: [(efficiency: Double, cost: Double, month: String)] {
        return filteredStatistics.map { entry in
            let monthDisplay = "\(entry.year)/\(entry.month)"
            return (efficiency: entry.avgEfficiencyValue, cost: entry.totalCostValue, month: monthDisplay)
        }
    }
    
    func loadStatistics() {
        isLoading = true
        errorMessage = nil
        
        ChargedLogService.shared.fetchStatistics { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let statistics):
                    self?.statistics = statistics
                    // 更新可用年份後，確保選中的年份有效
                    if let self = self, !self.availableYears.contains(self.selectedYear) {
                        self.selectedYear = self.availableYears.first ?? "all"
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // 清除提示訊息的延遲方法
    private func clearTipAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.filterTip = ""
        }
    }
}
