import Foundation
import Combine


class ChargedLogViewModel: ObservableObject {
    @Published var logs: [ChargedLogEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // 日期篩選
    @Published var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @Published var endDate: Date = Date()

    private var cancellables = Set<AnyCancellable>()

    // 日期格式化器（只初始化一次）
    private static let dateFormatter: DateFormatter = {
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
}

