//
//  my_tesla_appTests.swift
//  my-tesla-appTests
//
//  Created by nick on 2025/7/25.
//

import Testing
@testable import MyTesla

// MARK: - CustomPriceManager Tests
@Suite(.serialized)
struct CustomPriceManagerTests {
    
    @Test func defaultPricesAreCorrect() {
        let manager = CustomPriceManager.shared
        let defaultPrices = manager.defaultPrices
        
        #expect(defaultPrices == [2.5, 3.0, 3.5, 4.0, 7.0])
    }
    
    @Test func addCustomPriceStoresValue() {
        let manager = CustomPriceManager.shared
        manager.clearCustomPrices()
        
        manager.addCustomPrice(5.5)
        let customPrices = manager.getCustomPrices()
        
        #expect(customPrices.contains(5.5))
        
        // Cleanup
        manager.clearCustomPrices()
    }
    
    @Test func addDuplicatePriceIsIgnored() {
        let manager = CustomPriceManager.shared
        manager.clearCustomPrices()
        
        manager.addCustomPrice(6.0)
        manager.addCustomPrice(6.0)
        let customPrices = manager.getCustomPrices()
        
        let count = customPrices.filter { $0 == 6.0 }.count
        #expect(count == 1)
        
        // Cleanup
        manager.clearCustomPrices()
    }
    
    @Test func addDefaultPriceIsIgnored() {
        let manager = CustomPriceManager.shared
        manager.clearCustomPrices()
        
        // 2.5 是預設價格
        manager.addCustomPrice(2.5)
        let customPrices = manager.getCustomPrices()
        
        #expect(!customPrices.contains(2.5))
        
        // Cleanup
        manager.clearCustomPrices()
    }
    
    @Test func getAllPriceOptionsIncludesBoth() {
        let manager = CustomPriceManager.shared
        manager.clearCustomPrices()
        
        manager.addCustomPrice(5.5)
        let allPrices = manager.getAllPriceOptions()
        
        // 應包含預設的 2.5 和自訂的 5.5
        #expect(allPrices.contains(2.5))
        #expect(allPrices.contains(5.5))
        #expect(allPrices == allPrices.sorted())
        
        // Cleanup
        manager.clearCustomPrices()
    }
    
    @Test func maxTenCustomPrices() {
        let manager = CustomPriceManager.shared
        manager.clearCustomPrices()
        
        // 新增 12 個價格
        for i in 10..<22 {
            manager.addCustomPrice(Double(i))
        }
        
        let customPrices = manager.getCustomPrices()
        #expect(customPrices.count <= 10)
        
        // Cleanup
        manager.clearCustomPrices()
    }
}

// MARK: - ChargeType Tests
struct ChargeTypeTests {
    
    @Test func rawValuesAreCorrect() {
        #expect(ChargeType.acSingleWireCAN.rawValue == "ACSingleWireCAN")
        #expect(ChargeType.supercharger.rawValue == "Supercharger")
        #expect(ChargeType.j1772.rawValue == "J1772")
    }
    
    @Test func displayNamesAreCorrect() {
        #expect(ChargeType.acSingleWireCAN.displayName == "AC")
        #expect(ChargeType.supercharger.displayName == "DC (Supercharger)")
        #expect(ChargeType.j1772.displayName == "J1772")
    }
    
    @Test func allCasesCount() {
        #expect(ChargeType.allCases.count == 3)
    }
}

// MARK: - AddChargeRecordViewModel Tests
@Suite(.serialized)
@MainActor
struct AddChargeRecordViewModelTests {
    
    @Test func initialStateIsCorrect() {
        let viewModel = AddChargeRecordViewModel()
        
        #expect(viewModel.priceText == "")
        #expect(viewModel.selectedChargeType == .acSingleWireCAN)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.showSuccessAlert == false)
    }
    
    @Test func priceValidation() {
        let viewModel = AddChargeRecordViewModel()
        
        viewModel.priceText = ""
        #expect(viewModel.isValidPrice == false)
        
        viewModel.priceText = "abc"
        #expect(viewModel.isValidPrice == false)
        
        viewModel.priceText = "-1"
        #expect(viewModel.isValidPrice == false)
        
        viewModel.priceText = "0"
        #expect(viewModel.isValidPrice == false)
        
        viewModel.priceText = "3.5"
        #expect(viewModel.isValidPrice == true)
        
        viewModel.priceText = "7"
        #expect(viewModel.isValidPrice == true)
    }
    
    @Test func canSubmitDependsOnValidPriceAndNotLoading() {
        let viewModel = AddChargeRecordViewModel()
        
        viewModel.priceText = ""
        #expect(viewModel.canSubmit == false)
        
        viewModel.priceText = "5.0"
        #expect(viewModel.canSubmit == true)
    }
    
    @Test func selectPriceUpdatesPriceText() {
        let viewModel = AddChargeRecordViewModel()
        
        viewModel.selectPrice(3.5)
        #expect(viewModel.priceText == "3.5")
        
        viewModel.selectPrice(7.0)
        #expect(viewModel.priceText == "7")
    }
    
    @Test func resetClearsState() {
        let viewModel = AddChargeRecordViewModel()
        
        viewModel.priceText = "5.0"
        viewModel.selectedChargeType = .supercharger
        viewModel.errorMessage = "some error"
        
        viewModel.reset()
        
        #expect(viewModel.priceText == "")
        #expect(viewModel.selectedChargeType == .acSingleWireCAN)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test func priceOptionsLoadFromManager() {
        let viewModel = AddChargeRecordViewModel()
        
        // 應至少包含預設價格
        #expect(viewModel.priceOptions.contains(2.5))
        #expect(viewModel.priceOptions.contains(7.0))
    }
}

// MARK: - AddChargeRecordResponse Tests
struct AddChargeRecordResponseTests {
    
    @Test func successResponseDetection() {
        let successResponse = AddChargeRecordResponse(
            status: "success",
            code: 0,
            data: nil,
            message: "紀錄成功"
        )
        #expect(successResponse.isSuccess == true)
        
        let failureResponse = AddChargeRecordResponse(
            status: "error",
            code: 1,
            data: nil,
            message: "失敗"
        )
        #expect(failureResponse.isSuccess == false)
    }
}
