//
//  CustomPriceManager.swift
//  my-tesla-app
//
//  管理自訂價格的儲存與讀取
//

import Foundation

class CustomPriceManager {
    static let shared = CustomPriceManager()
    
    private let key = "customChargePrices"
    private let maxCount = 10
    
    /// 預設價格選項
    let defaultPrices: [Double] = [2.5, 3.0, 3.5, 4.0, 7.0]
    
    private init() {}
    
    /// 取得所有自訂價格（已排序）
    func getCustomPrices() -> [Double] {
        let prices = UserDefaults.standard.array(forKey: key) as? [Double] ?? []
        return prices.sorted()
    }
    
    /// 新增自訂價格
    func addCustomPrice(_ price: Double) {
        var prices = UserDefaults.standard.array(forKey: key) as? [Double] ?? []
        
        // 檢查是否已存在於預設選項（避免重複）
        if defaultPrices.contains(price) { return }
        
        // 檢查是否已存在於自訂選項（避免重複）
        if prices.contains(price) { return }
        
        // 新增價格
        prices.append(price)
        
        // 超過上限時移除最舊的
        if prices.count > maxCount {
            prices.removeFirst()
        }
        
        UserDefaults.standard.set(prices, forKey: key)
    }
    
    /// 取得完整價格選項（預設 + 自訂，已排序去重）
    func getAllPriceOptions() -> [Double] {
        let customPrices = getCustomPrices()
        return Array(Set(defaultPrices + customPrices)).sorted()
    }
    
    /// 清除所有自訂價格（測試用）
    func clearCustomPrices() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
