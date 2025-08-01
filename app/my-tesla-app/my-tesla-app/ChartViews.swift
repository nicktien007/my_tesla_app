import SwiftUI

// 月度充電量條狀圖
struct MonthlyChargedChart: View {
    let data: [(month: String, value: Double)]
    
    private var maxValue: Double {
        data.map { $0.value }.max() ?? 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("月度充電量")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            if data.isEmpty {
                Text("暫無資料")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .bottom, spacing: 6) {
                        ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                            VStack(spacing: 4) {
                                // 數值標籤
                                Text(String(format: "%.1f", item.value))
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                                
                                // 條狀圖
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 94/255, green: 96/255, blue: 206/255),
                                            Color(red: 150/255, green: 152/255, blue: 255/255)
                                        ]),
                                        startPoint: .bottom,
                                        endPoint: .top
                                    ))
                                    .frame(width: 24, height: max(4, (item.value / maxValue) * 80))
                                
                                // 月份標籤
                                Text(formatMonth(item.month))
                                    .font(.system(size: 9))
                                    .foregroundColor(.gray)
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
        .background(Color(red: 35/255, green: 38/255, blue: 47/255))
        .cornerRadius(12)
    }
    
    private func formatMonth(_ monthString: String) -> String {
        // 直接顯示完整的月份字串（已包含年份或僅月份）
        if monthString.contains("/") {
            // 如果是 "24/7" 格式，顯示為 "24/7"
            return monthString
        } else {
            // 如果只是月份數字，加上"月"
            return "\(monthString)月"
        }
    }
}

// 效率與費用散點圖
struct EfficiencyVsCostChart: View {
    let data: [(efficiency: Double, cost: Double, month: String)]
    
    private var maxEfficiency: Double {
        data.map { $0.efficiency }.max() ?? 1
    }
    
    private var maxCost: Double {
        data.map { $0.cost }.max() ?? 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("電耗效率 vs 費用趨勢")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            if data.isEmpty {
                Text("暫無資料")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                GeometryReader { geometry in
                    let chartWidth = geometry.size.width - 40
                    let chartHeight = geometry.size.height - 40
                    
                    ZStack {
                        // 背景網格
                        Path { path in
                            // 水平線
                            for i in 0...4 {
                                let y = chartHeight * CGFloat(i) / 4
                                path.move(to: CGPoint(x: 20, y: 20 + y))
                                path.addLine(to: CGPoint(x: 20 + chartWidth, y: 20 + y))
                            }
                            // 垂直線
                            for i in 0...4 {
                                let x = chartWidth * CGFloat(i) / 4
                                path.move(to: CGPoint(x: 20 + x, y: 20))
                                path.addLine(to: CGPoint(x: 20 + x, y: 20 + chartHeight))
                            }
                        }
                        .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                        
                        // 資料點和連線
                        if data.count > 1 {
                            // 連線（以電耗為主軸）
                            Path { path in
                                let sortedByEfficiency = data.sorted { $0.efficiency < $1.efficiency }
                                for (index, point) in sortedByEfficiency.enumerated() {
                                    let x = 20 + (point.efficiency / maxEfficiency) * chartWidth
                                    let y = 20 + chartHeight - (point.cost / maxCost) * chartHeight
                                    
                                    if index == 0 {
                                        path.move(to: CGPoint(x: x, y: y))
                                    } else {
                                        path.addLine(to: CGPoint(x: x, y: y))
                                    }
                                }
                            }
                            .stroke(Color(red: 232/255, green: 33/255, blue: 39/255), lineWidth: 2)
                        }
                        
                        // 資料點
                        ForEach(Array(data.enumerated()), id: \.offset) { index, point in
                            let x = 20 + (point.efficiency / maxEfficiency) * chartWidth
                            let y = 20 + chartHeight - (point.cost / maxCost) * chartHeight
                            
                            Circle()
                                .fill(Color(red: 94/255, green: 96/255, blue: 206/255))
                                .frame(width: 8, height: 8)
                                .position(x: x, y: y)
                                .overlay(
                                    Text(formatMonth(point.month))
                                        .font(.system(size: 8))
                                        .foregroundColor(.white)
                                        .offset(x: x < chartWidth / 2 ? 15 : -15, y: -10)
                                        .position(x: x, y: y)
                                )
                        }
                        
                        // Y軸標籤（費用）
                        VStack {
                            ForEach(0...4, id: \.self) { i in
                                let value = maxCost * Double(4 - i) / 4
                                Text(String(format: "%.0f", value))
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                                    .frame(maxHeight: .infinity)
                            }
                        }
                        .frame(width: 15, height: chartHeight)
                        .position(x: 10, y: 20 + chartHeight / 2)
                        
                        // X軸標籤（電耗）
                        HStack {
                            ForEach(0...4, id: \.self) { i in
                                let value = maxEfficiency * Double(i) / 4
                                Text(String(format: "%.1f", value))
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(width: chartWidth, height: 15)
                        .position(x: 20 + chartWidth / 2, y: geometry.size.height - 10)
                    }
                }
                .frame(height: 140)
                
                // 圖例
                HStack {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(red: 94/255, green: 96/255, blue: 206/255))
                            .frame(width: 8, height: 8)
                        Text("電耗效率 (km/kWh)")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(Color(red: 232/255, green: 33/255, blue: 39/255))
                            .frame(width: 12, height: 2)
                        Text("費用 ($)")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(red: 35/255, green: 38/255, blue: 47/255))
        .cornerRadius(12)
    }
    
    private func formatMonth(_ monthString: String) -> String {
        // 直接顯示完整的月份字串（已包含年份或僅月份）
        return monthString
    }
}

// 統計摘要卡片
struct StatisticsSummaryCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(red: 35/255, green: 38/255, blue: 47/255))
        .cornerRadius(12)
    }
}
