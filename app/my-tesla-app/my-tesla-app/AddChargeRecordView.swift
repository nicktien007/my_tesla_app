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
    @ObservedObject private var theme = AppTheme.shared
    
    /// 成功後的回調
    var onSuccess: (() -> Void)?
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景色
                theme.backgroundColor
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
            .toolbarBackground(theme.cardBackgroundColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(theme.mode == .dark ? .dark : .light, for: .navigationBar)
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
                .foregroundColor(theme.secondaryTextColor)
                .font(.system(size: 15, weight: .medium))
            
            // 數字輸入框
            ZStack(alignment: .leading) {
                if viewModel.priceText.isEmpty {
                    Text("輸入價格")
                        .foregroundColor(theme.placeholderColor)
                        .padding(.leading, 4)
                }
                TextField("", text: $viewModel.priceText)
                    .keyboardType(.decimalPad)
            }
            .padding()
            .background(theme.inputBackgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(theme.inputBorderColor, lineWidth: 1)
            )
            .cornerRadius(12)
            .foregroundColor(theme.primaryTextColor)
            .font(.system(size: 18))
            
            // 常用價格選項
            Text("常用價格")
                .foregroundColor(theme.secondaryTextColor)
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
                            .foregroundColor(isSelectedPrice(price) ? .white : AppTheme.accentPurple)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                isSelectedPrice(price)
                                    ? AppTheme.accentPurple
                                    : theme.inputBackgroundColor
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isSelectedPrice(price) ? Color.clear : theme.inputBorderColor, lineWidth: 1)
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
                .foregroundColor(theme.secondaryTextColor)
                .font(.system(size: 15, weight: .medium))
            
            CustomSegmentedControl(
                selection: $viewModel.selectedChargeType,
                options: ChargeType.allCases,
                trackColor: theme.segmentedTrackColor,
                selectedColor: AppTheme.accentPurple,
                textColor: theme.primaryTextColor
            )
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
                    ? AppTheme.accentPurple
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

// MARK: - Custom Segmented Control
struct CustomSegmentedControl<T: Equatable & Identifiable & Hashable>: View where T.ID == String {
    @Binding var selection: T
    let options: [T]
    let trackColor: Color
    let selectedColor: Color
    let textColor: Color
    
    // Display Name Helper
    private func displayName(for option: T) -> String {
        if let type = option as? ChargeType {
            return type.displayName
        }
        return "\(option)"
    }
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let count = CGFloat(options.count)
            let segmentWidth = width / count
            
            ZStack(alignment: .leading) {
                // Track Background
                RoundedRectangle(cornerRadius: 10)
                    .fill(trackColor)
                
                // Selected Thumb
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedColor)
                    .frame(width: segmentWidth - 4, height: 40) // Height - padding
                    .offset(x: (CGFloat(selectedIndex) * segmentWidth) + 2)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selection)
                
                // Labels
                HStack(spacing: 0) {
                    ForEach(options, id: \.id) { option in
                        Text(displayName(for: option))
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(selection == option ? .white : textColor)
                            .frame(width: segmentWidth, height: 44)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selection = option
                            }
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let index = Int((value.location.x / width) * count)
                        if index >= 0 && index < options.count {
                            selection = options[index]
                        }
                    }
            )
        }
        .frame(height: 44)
    }
    
    private var selectedIndex: Int {
        options.firstIndex(of: selection) ?? 0
    }
}
