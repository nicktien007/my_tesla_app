import SwiftUI

// MARK: - 月度充電量/費用條狀圖（支援切換）
struct MonthlyChargedChart: View {
    let chargedData: [(month: String, value: Double)]
    let costData: [(month: String, value: Double)]
    @ObservedObject var theme: AppTheme
    
    enum DisplayMode: String, CaseIterable {
        case kWh = "kWh"
        case cost = "$"
        
        var displayName: String {
            switch self {
            case .kWh: return "度數 (kWh)"
            case .cost: return "費用 ($)"
            }
        }
    }
    
    @State private var displayMode: DisplayMode = .kWh
    
    private var currentData: [(month: String, value: Double)] {
        switch displayMode {
        case .kWh: return chargedData
        case .cost: return costData
        }
    }
    
    private var maxValue: Double {
        currentData.map { $0.value }.max() ?? 1
    }
    
    private var barGradient: LinearGradient {
        switch displayMode {
        case .kWh:
            return LinearGradient(
                gradient: Gradient(colors: [
                    AppTheme.accentPurple,
                    Color(red: 150/255, green: 152/255, blue: 255/255)
                ]),
                startPoint: .bottom,
                endPoint: .top
            )
        case .cost:
            return LinearGradient(
                gradient: Gradient(colors: [
                    AppTheme.teslaRed,
                    Color(red: 255/255, green: 100/255, blue: 100/255)
                ]),
                startPoint: .bottom,
                endPoint: .top
            )
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 標題列含切換選單
            HStack {
                Text("月度充電統計")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(theme.primaryTextColor)
                
                Spacer()
                
                // 切換選單
                Picker("顯示模式", selection: $displayMode) {
                    ForEach(DisplayMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .accentColor(AppTheme.accentPurple)
            }
            
            if currentData.isEmpty {
                Text("暫無資料")
                    .foregroundColor(theme.secondaryTextColor)
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .bottom, spacing: 6) {
                        ForEach(Array(currentData.enumerated()), id: \.offset) { index, item in
                            VStack(spacing: 4) {
                                // 數值標籤
                                Text(formatValue(item.value))
                                    .font(.system(size: 10))
                                    .foregroundColor(theme.secondaryTextColor)
                                
                                // 條狀圖
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(barGradient)
                                    .frame(width: 24, height: max(4, (item.value / maxValue) * 80))
                                
                                // 月份標籤
                                Text(formatMonth(item.month))
                                    .font(.system(size: 9))
                                    .foregroundColor(theme.secondaryTextColor)
                                    .rotationEffect(.degrees(-45))
                                    .frame(width: 35, height: 25)
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                            .frame(width: 45)
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .frame(height: 120)
            }
        }
        .padding()
        .background(theme.cardBackgroundColor)
        .cornerRadius(12)
    }
    
    private func formatValue(_ value: Double) -> String {
        switch displayMode {
        case .kWh:
            return String(format: "%.1f", value)
        case .cost:
            return String(format: "$%.0f", value)
        }
    }
    
    private func formatMonth(_ monthString: String) -> String {
        if monthString.contains("/") {
            return monthString
        } else {
            return "\(monthString)月"
        }
    }
}

// MARK: - 充電來源圓餅圖（AC vs DC）
struct ChargeSourcePieChart: View {
    let acKWh: Double
    let dcKWh: Double
    let acCost: Double
    let dcCost: Double
    @ObservedObject var theme: AppTheme
    
    enum DisplayMode: String, CaseIterable {
        case kWh = "kWh"
        case cost = "$"
        
        var displayName: String {
            switch self {
            case .kWh: return "度數 (kWh)"
            case .cost: return "費用 ($)"
            }
        }
    }
    
    @State private var displayMode: DisplayMode = .kWh
    
    private var acValue: Double {
        displayMode == .kWh ? acKWh : acCost
    }
    
    private var dcValue: Double {
        displayMode == .kWh ? dcKWh : dcCost
    }
    
    private var total: Double {
        acValue + dcValue
    }
    
    private var acRatio: Double {
        total > 0 ? acValue / total : 0
    }
    
    private var dcRatio: Double {
        total > 0 ? dcValue / total : 0
    }
    
    private var unit: String {
        displayMode == .kWh ? "kWh" : "元"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 標題列含切換選單
            HStack {
                Text("充電來源分布")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(theme.primaryTextColor)
                
                Spacer()
                
                Picker("顯示模式", selection: $displayMode) {
                    ForEach(DisplayMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .accentColor(AppTheme.accentPurple)
            }
            
            if total == 0 {
                Text("暫無資料")
                    .foregroundColor(theme.secondaryTextColor)
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else {
                HStack(spacing: 20) {
                    // 圓餅圖
                    ZStack {
                        // DC 部分（底層）
                        Circle()
                            .stroke(AppTheme.teslaRed, lineWidth: 20)
                            .frame(width: 80, height: 80)
                        
                        // AC 部分（覆蓋）
                        Circle()
                            .trim(from: 0, to: acRatio)
                            .stroke(Color.green, lineWidth: 20)
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                        
                        // 中心顯示總量
                        VStack(spacing: 2) {
                            Text(displayMode == .kWh ? String(format: "%.0f", total) : String(format: "$%.0f", total))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(theme.primaryTextColor)
                            Text(displayMode == .kWh ? "kWh" : "元")
                                .font(.system(size: 10))
                                .foregroundColor(theme.secondaryTextColor)
                        }
                    }
                    .frame(width: 100, height: 100)
                    
                    // 圖例
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 12, height: 12)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("家充 (AC)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(theme.primaryTextColor)
                                Text(String(format: "%.1f %@ (%.0f%%)", acValue, unit, acRatio * 100))
                                    .font(.system(size: 11))
                                    .foregroundColor(theme.secondaryTextColor)
                            }
                        }
                        
                        HStack(spacing: 8) {
                            Circle()
                                .fill(AppTheme.teslaRed)
                                .frame(width: 12, height: 12)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("超充 (DC)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(theme.primaryTextColor)
                                Text(String(format: "%.1f %@ (%.0f%%)", dcValue, unit, dcRatio * 100))
                                    .font(.system(size: 11))
                                    .foregroundColor(theme.secondaryTextColor)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(theme.cardBackgroundColor)
        .cornerRadius(12)
    }
}

// MARK: - 電耗效率趨勢圖（Time Series）
struct EfficiencyTrendChart: View {
    let data: [(month: String, efficiency: Double)]
    @ObservedObject var theme: AppTheme
    
    // 異常值閾值
    private let lowThreshold: Double = 4.0
    private let highThreshold: Double = 5.5
    
    private var maxEfficiency: Double {
        max(data.map { $0.efficiency }.max() ?? 6.0, 6.0)
    }
    
    private var minEfficiency: Double {
        min(data.map { $0.efficiency }.min() ?? 3.0, 3.0)
    }
    
    private var efficiencyRange: Double {
        maxEfficiency - minEfficiency
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("電耗效率趨勢")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(theme.primaryTextColor)
            
            if data.isEmpty {
                Text("暫無資料")
                    .foregroundColor(theme.secondaryTextColor)
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                GeometryReader { geometry in
                    let chartWidth = geometry.size.width - 50
                    let chartHeight = geometry.size.height - 40
                    
                    ZStack {
                        // 背景網格
                        drawGrid(chartWidth: chartWidth, chartHeight: chartHeight)
                        
                        // 警示線（低於閾值）
                        drawWarningLine(chartWidth: chartWidth, chartHeight: chartHeight)
                        
                        // 折線
                        drawLine(chartWidth: chartWidth, chartHeight: chartHeight)
                        
                        // 資料點（含異常標註）
                        drawPoints(chartWidth: chartWidth, chartHeight: chartHeight)
                        
                        // Y 軸標籤
                        drawYAxisLabels(chartHeight: chartHeight)
                        
                        // X 軸標籤
                        drawXAxisLabels(chartWidth: chartWidth, chartHeight: chartHeight, geometry: geometry)
                    }
                }
                .frame(height: 150)
                
                // 圖例
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(AppTheme.accentPurple)
                            .frame(width: 8, height: 8)
                        Text("電耗 (km/kWh)")
                            .font(.system(size: 10))
                            .foregroundColor(theme.secondaryTextColor)
                    }
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        Text("低於 4.0 警示")
                            .font(.system(size: 10))
                            .foregroundColor(theme.secondaryTextColor)
                    }
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("高於 5.5 優秀")
                            .font(.system(size: 10))
                            .foregroundColor(theme.secondaryTextColor)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(theme.cardBackgroundColor)
        .cornerRadius(12)
    }
    
    private func drawGrid(chartWidth: CGFloat, chartHeight: CGFloat) -> some View {
        Path { path in
            // 水平線
            for i in 0...4 {
                let y = chartHeight * CGFloat(i) / 4
                path.move(to: CGPoint(x: 35, y: 10 + y))
                path.addLine(to: CGPoint(x: 35 + chartWidth, y: 10 + y))
            }
        }
        .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
    }
    
    private func drawWarningLine(chartWidth: CGFloat, chartHeight: CGFloat) -> some View {
        let warningY = 10 + chartHeight - CGFloat((lowThreshold - minEfficiency) / efficiencyRange) * chartHeight
        return Path { path in
            path.move(to: CGPoint(x: 35, y: warningY))
            path.addLine(to: CGPoint(x: 35 + chartWidth, y: warningY))
        }
        .stroke(Color.red.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
    }
    
    private func drawLine(chartWidth: CGFloat, chartHeight: CGFloat) -> some View {
        Path { path in
            for (index, point) in data.enumerated() {
                let x = 35 + chartWidth * CGFloat(index) / CGFloat(max(data.count - 1, 1))
                let y = 10 + chartHeight - CGFloat((point.efficiency - minEfficiency) / efficiencyRange) * chartHeight
                
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
        .stroke(AppTheme.accentPurple, lineWidth: 2)
    }
    
    private func drawPoints(chartWidth: CGFloat, chartHeight: CGFloat) -> some View {
        ForEach(Array(data.enumerated()), id: \.offset) { index, point in
            let x = 35 + chartWidth * CGFloat(index) / CGFloat(max(data.count - 1, 1))
            let y = 10 + chartHeight - CGFloat((point.efficiency - minEfficiency) / efficiencyRange) * chartHeight
            
            Circle()
                .fill(pointColor(for: point.efficiency))
                .frame(width: isAbnormal(point.efficiency) ? 10 : 8, height: isAbnormal(point.efficiency) ? 10 : 8)
                .position(x: x, y: y)
        }
    }
    
    private func drawYAxisLabels(chartHeight: CGFloat) -> some View {
        VStack {
            ForEach(0...4, id: \.self) { i in
                let value = maxEfficiency - (maxEfficiency - minEfficiency) * Double(i) / 4
                Text(String(format: "%.1f", value))
                    .font(.system(size: 9))
                    .foregroundColor(theme.secondaryTextColor)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 30, height: chartHeight)
        .offset(x: -5, y: 10)
    }
    
    private func drawXAxisLabels(chartWidth: CGFloat, chartHeight: CGFloat, geometry: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(data.enumerated()), id: \.offset) { index, point in
                Text(formatMonth(point.month))
                    .font(.system(size: 9))
                    .foregroundColor(theme.secondaryTextColor)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(width: chartWidth)
        .offset(x: 35, y: chartHeight + 20)
    }
    
    private func pointColor(for efficiency: Double) -> Color {
        if efficiency < lowThreshold {
            return .red
        } else if efficiency > highThreshold {
            return .green
        } else {
            return AppTheme.accentPurple
        }
    }
    
    private func isAbnormal(_ efficiency: Double) -> Bool {
        return efficiency < lowThreshold || efficiency > highThreshold
    }
    
    private func formatMonth(_ monthString: String) -> String {
        if monthString.contains("/") {
            return monthString
        } else {
            return "\(monthString)月"
        }
    }
}

// MARK: - 每公里成本趨勢圖（Time Series）
struct CostPerKmTrendChart: View {
    let data: [(month: String, costPerKm: Double)]
    @ObservedObject var theme: AppTheme
    
    private var maxCost: Double {
        max(data.map { $0.costPerKm }.max() ?? 1.0, 1.0)
    }
    
    private var minCost: Double {
        min(data.map { $0.costPerKm }.min() ?? 0, 0)
    }
    
    private var costRange: Double {
        maxCost - minCost
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("每公里成本趨勢")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(theme.primaryTextColor)
            
            if data.isEmpty {
                Text("暫無資料")
                    .foregroundColor(theme.secondaryTextColor)
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                GeometryReader { geometry in
                    let chartWidth = geometry.size.width - 50
                    let chartHeight = geometry.size.height - 40
                    
                    ZStack {
                        // 背景網格
                        drawGrid(chartWidth: chartWidth, chartHeight: chartHeight)
                        
                        // 折線
                        drawLine(chartWidth: chartWidth, chartHeight: chartHeight)
                        
                        // 資料點
                        drawPoints(chartWidth: chartWidth, chartHeight: chartHeight)
                        
                        // Y 軸標籤
                        drawYAxisLabels(chartHeight: chartHeight)
                        
                        // X 軸標籤
                        drawXAxisLabels(chartWidth: chartWidth, chartHeight: chartHeight, geometry: geometry)
                    }
                }
                .frame(height: 150)
                
                // 圖例
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(AppTheme.teslaRed)
                            .frame(width: 8, height: 8)
                        Text("成本 ($/km)")
                            .font(.system(size: 10))
                            .foregroundColor(theme.secondaryTextColor)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(theme.cardBackgroundColor)
        .cornerRadius(12)
    }
    
    private func drawGrid(chartWidth: CGFloat, chartHeight: CGFloat) -> some View {
        Path { path in
            // 水平線
            for i in 0...4 {
                let y = chartHeight * CGFloat(i) / 4
                path.move(to: CGPoint(x: 35, y: 10 + y))
                path.addLine(to: CGPoint(x: 35 + chartWidth, y: 10 + y))
            }
        }
        .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
    }
    
    private func drawLine(chartWidth: CGFloat, chartHeight: CGFloat) -> some View {
        Path { path in
            for (index, point) in data.enumerated() {
                let x = 35 + chartWidth * CGFloat(index) / CGFloat(max(data.count - 1, 1))
                let y = 10 + chartHeight - CGFloat((point.costPerKm - minCost) / costRange) * chartHeight
                
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
        .stroke(AppTheme.teslaRed, lineWidth: 2)
    }
    
    private func drawPoints(chartWidth: CGFloat, chartHeight: CGFloat) -> some View {
        ForEach(Array(data.enumerated()), id: \.offset) { index, point in
            let x = 35 + chartWidth * CGFloat(index) / CGFloat(max(data.count - 1, 1))
            let y = 10 + chartHeight - CGFloat((point.costPerKm - minCost) / costRange) * chartHeight
            
            Circle()
                .fill(AppTheme.teslaRed)
                .frame(width: 8, height: 8)
                .position(x: x, y: y)
        }
    }
    
    private func drawYAxisLabels(chartHeight: CGFloat) -> some View {
        VStack {
            ForEach(0...4, id: \.self) { i in
                let value = maxCost - (maxCost - minCost) * Double(i) / 4
                Text(String(format: "$%.2f", value))
                    .font(.system(size: 9))
                    .foregroundColor(theme.secondaryTextColor)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 35, height: chartHeight)
        .offset(x: -2, y: 10)
    }
    
    private func drawXAxisLabels(chartWidth: CGFloat, chartHeight: CGFloat, geometry: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(data.enumerated()), id: \.offset) { index, point in
                Text(formatMonth(point.month))
                    .font(.system(size: 9))
                    .foregroundColor(theme.secondaryTextColor)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(width: chartWidth)
        .offset(x: 35, y: chartHeight + 20)
    }
    
    private func formatMonth(_ monthString: String) -> String {
        if monthString.contains("/") {
            return monthString
        } else {
            return "\(monthString)月"
        }
    }
}

// MARK: - 統計摘要卡片
struct StatisticsSummaryCard: View {
    let title: String
    let value: String
    let subtitle: String?
    var secondaryValue: String? = nil
    let color: Color
    @ObservedObject var theme: AppTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(theme.secondaryTextColor)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(theme.primaryTextColor)
            
            if let secondaryValue = secondaryValue {
                Text(secondaryValue)
                    .font(.system(size: 12))
                    .foregroundColor(theme.primaryTextColor.opacity(0.8))
            }
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(theme.cardBackgroundColor)
        .cornerRadius(12)
    }
}
