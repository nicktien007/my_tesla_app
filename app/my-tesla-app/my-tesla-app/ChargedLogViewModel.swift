import Foundation
import Combine

class ChargedLogViewModel: ObservableObject {
    @Published var logs: [ChargedLogEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

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

