//
//  AddChargeRecordViewModel.swift
//  my-tesla-app
//
//  處理新增充電紀錄表單邏輯與 API 呼叫
//

import Foundation
import SwiftUI

/// 充電類型列舉
enum ChargeType: String, CaseIterable, Identifiable {
    case acSingleWireCAN = "ACSingleWireCAN"
    case supercharger = "Supercharger"
    case j1772 = "J1772"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .acSingleWireCAN: return "AC"
        case .supercharger: return "DC (Supercharger)"
        case .j1772: return "J1772"
        }
    }
}

/// API 回應模型
struct AddChargeRecordResponse: Codable {
    let status: String
    let code: Int
    let data: [String: String]?
    let message: String
    
    var isSuccess: Bool {
        return status == "success"
    }
}

/// 新增充電紀錄 ViewModel
@MainActor
class AddChargeRecordViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var priceText: String = ""
    @Published var selectedChargeType: ChargeType = .acSingleWireCAN
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showSuccessAlert: Bool = false
    @Published var successMessage: String = ""
    @Published var priceOptions: [Double] = []
    
    // MARK: - Private Properties
    private let apiEndpoint = "https://script.google.com/macros/s/AKfycbzQ8eh0akIWnsk1XOuYippDln5usy2_CKobrZyH9AN6k8j9cbAicHGroNspBOTWQwt-/exec"
    private let priceManager = CustomPriceManager.shared
    
    // MARK: - Computed Properties
    var price: Double? {
        return Double(priceText)
    }
    
    var isValidPrice: Bool {
        guard let price = price else { return false }
        return price > 0
    }
    
    var canSubmit: Bool {
        return isValidPrice && !isLoading
    }
    
    // MARK: - Initialization
    init() {
        loadPriceOptions()
    }
    
    // MARK: - Public Methods
    func loadPriceOptions() {
        priceOptions = priceManager.getAllPriceOptions()
    }
    
    func selectPrice(_ price: Double) {
        priceText = formatPrice(price)
    }
    
    func reset() {
        priceText = ""
        selectedChargeType = .acSingleWireCAN
        errorMessage = nil
        isLoading = false
    }
    
    func submit() async -> Bool {
        guard canSubmit else {
            errorMessage = "請輸入有效的價格"
            return false
        }
        
        guard let priceValue = price else {
            errorMessage = "價格格式不正確"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await addChargeRecord(price: priceValue, type: selectedChargeType)
            
            if response.isSuccess {
                // 成功：儲存自訂價格
                priceManager.addCustomPrice(priceValue)
                loadPriceOptions()
                
                successMessage = response.message
                showSuccessAlert = true
                isLoading = false
                return true
            } else {
                // 失敗：顯示錯誤訊息
                errorMessage = response.message
                isLoading = false
                return false
            }
        } catch {
            errorMessage = "網路連線失敗，請檢查網路後重試"
            isLoading = false
            return false
        }
    }
    
    // MARK: - Private Methods
    private func addChargeRecord(price: Double, type: ChargeType) async throws -> AddChargeRecordResponse {
        guard let url = URL(string: apiEndpoint) else {
            throw URLError(.badURL)
        }
        
        // 建立 POST 請求
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // 使用 text/plain 避免 GAS 跨域 CORS 問題
        request.setValue("text/plain;charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // 建立 JSON body
        let body: [String: Any] = [
            "p": price,
            "t": type.rawValue,
            "method": "POST"
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        print("AddChargeRecord API URL: \(url.absoluteString)")
        print("AddChargeRecord Request Body: \(body)")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Debug: 列印原始回應
        if let jsonString = String(data: data, encoding: .utf8) {
            print("AddChargeRecord API Response: \(jsonString)")
        }
        
        return try JSONDecoder().decode(AddChargeRecordResponse.self, from: data)
    }
    
    private func formatPrice(_ price: Double) -> String {
        // 移除不必要的小數點後 0
        if price.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", price)
        } else {
            return String(format: "%.2f", price).replacingOccurrences(of: "\\.?0+$", with: "", options: .regularExpression)
        }
    }
}
