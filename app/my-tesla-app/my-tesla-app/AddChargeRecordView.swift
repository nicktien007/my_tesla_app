//
//  AddChargeRecordView.swift
//  my-tesla-app
//
//  新增充電紀錄表單 View
//

import SwiftUI

struct AddChargeRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddChargeRecordViewModel()
    
    /// 成功後的回調
    var onSuccess: (() -> Void)?
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景色
                Color(red: 24/255, green: 26/255, blue: 32/255)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // 價格輸入區
                    priceInputSection
                    
                    // 充電類型選擇
                    chargeTypeSection
                    
                    // 錯誤訊息
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // 按鈕區
                    buttonSection
                }
                .padding()
            }
            .navigationTitle("新增充電紀錄")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
            .alert("成功", isPresented: $viewModel.showSuccessAlert) {
                Button("確定") {
                    onSuccess?()
                    dismiss()
                }
            } message: {
                Text(viewModel.successMessage)
            }
        }
    }
    
    // MARK: - 價格輸入區
    private var priceInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("價格 / kWh")
                .foregroundColor(.gray)
                .font(.system(size: 15, weight: .medium))
            
            // 數字輸入框
            TextField("輸入價格", text: $viewModel.priceText)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color(red: 35/255, green: 38/255, blue: 47/255))
                .cornerRadius(12)
                .foregroundColor(.white)
                .font(.system(size: 18))
            
            // 常用價格選項
            Text("常用價格")
                .foregroundColor(.gray)
                .font(.system(size: 13))
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(viewModel.priceOptions, id: \.self) { price in
                    Button(action: {
                        viewModel.selectPrice(price)
                    }) {
                        Text(formatPriceDisplay(price))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(isSelectedPrice(price) ? .white : .blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                isSelectedPrice(price)
                                    ? Color(red: 94/255, green: 96/255, blue: 206/255)
                                    : Color(red: 35/255, green: 38/255, blue: 47/255)
                            )
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    // MARK: - 充電類型選擇
    private var chargeTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("充電類型")
                .foregroundColor(.gray)
                .font(.system(size: 15, weight: .medium))
            
            Picker("充電類型", selection: $viewModel.selectedChargeType) {
                ForEach(ChargeType.allCases) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - 按鈕區
    private var buttonSection: some View {
        Button(action: {
            Task {
                await viewModel.submit()
            }
        }) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.trailing, 8)
                }
                Text(viewModel.isLoading ? "送出中..." : "送出")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                viewModel.canSubmit
                    ? Color(red: 94/255, green: 96/255, blue: 206/255)
                    : Color.gray.opacity(0.5)
            )
            .cornerRadius(12)
        }
        .disabled(!viewModel.canSubmit)
    }
    
    // MARK: - Helper Methods
    private func formatPriceDisplay(_ price: Double) -> String {
        if price.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "$%.0f", price)
        } else {
            return String(format: "$%.1f", price)
        }
    }
    
    private func isSelectedPrice(_ price: Double) -> Bool {
        guard let currentPrice = viewModel.price else { return false }
        return abs(currentPrice - price) < 0.001
    }
}

// MARK: - Preview
struct AddChargeRecordView_Previews: PreviewProvider {
    static var previews: some View {
        AddChargeRecordView()
            .preferredColorScheme(.dark)
    }
}
