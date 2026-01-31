import SwiftUI

struct StatisticsView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    @ObservedObject var theme: AppTheme
    
    var body: some View {
        VStack(spacing: 20) {
            // 篩選條件
            filterSection
            
            // 提示訊息
            if !viewModel.filterTip.isEmpty {
                Text(viewModel.filterTip)
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal, 2)
                    .transition(.opacity)
            }
            
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Spacer()
                }
                .frame(height: 100)
            } else if let error = viewModel.errorMessage {
                Text("載入失敗：\(error)")
                    .foregroundColor(.red)
                    .padding()
            } else if viewModel.filteredStatistics.isEmpty {
                Text("暫無統計資料")
                    .foregroundColor(theme.secondaryTextColor)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        // 統計摘要卡片
                        summarySection
                        
                        // 月度充電量/費用圖表（支援切換）
                        MonthlyChargedChart(
                            chargedData: viewModel.monthlyChargedData,
                            costData: viewModel.monthlyCostData,
                            theme: theme
                        )
                        
                        // 充電來源分布圓餅圖
                        ChargeSourcePieChart(
                            acKWh: viewModel.chargeSourceStats.acKWh,
                            dcKWh: viewModel.chargeSourceStats.dcKWh,
                            acCost: viewModel.chargeSourceStats.acCost,
                            dcCost: viewModel.chargeSourceStats.dcCost,
                            theme: theme
                        )
                        
                        // 電耗效率趨勢圖（時間序列）
                        EfficiencyTrendChart(data: viewModel.efficiencyTrendData, theme: theme)
                        
                        // 每公里成本趨勢圖（時間序列）
                        CostPerKmTrendChart(data: viewModel.costPerKmTrendData, theme: theme)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            // 自動切換到「全部」+「近六個月」
            if viewModel.selectedYear != "all" {
                viewModel.selectedYear = "all"
            }
            if viewModel.selectedTimeRange != .sixMonths {
                viewModel.selectedTimeRange = .sixMonths
            }
            viewModel.loadStatistics()
        }
    }
    
    private var filterSection: some View {
        HStack(spacing: 12) {
            // 年份選擇器
            if !viewModel.availableYears.isEmpty {
                ZStack {
                    // 透明區塊擴大觸發範圍
                    Rectangle()
                        .foregroundColor(.clear)
                    Picker("年份", selection: $viewModel.selectedYear) {
                        ForEach(viewModel.availableYears, id: \.self) { year in
                            Text(year == "all" ? "全部" : year)
                                .foregroundColor(.white)
                                .tag(year)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: viewModel.selectedYear) { _ in
                        viewModel.loadStatistics()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(theme.cardBackgroundColor)
                .cornerRadius(8)
                .contentShape(Rectangle())
            }
            // 時間範圍選擇器
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                Picker("時間範圍", selection: $viewModel.selectedTimeRange) {
                    ForEach(StatisticsViewModel.TimeRangeFilter.allCases) { range in
                        Text(range.display)
                            .foregroundColor(theme.primaryTextColor)
                            .tag(range)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: viewModel.selectedTimeRange) { _ in
                    viewModel.loadStatistics()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(theme.cardBackgroundColor)
            .cornerRadius(8)
            .contentShape(Rectangle())
        }
        .padding(.horizontal, 2)
    }
    
    private var summarySection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
            StatisticsSummaryCard(
                title: "總充電量",
                value: String(format: "%.1f kWh", viewModel.totalChargedKWh),
                subtitle: "查詢期間累計",
                color: AppTheme.accentPurple,
                theme: theme
            )
            
            StatisticsSummaryCard(
                title: "總費用",
                value: String(format: "$%.0f", viewModel.totalCost),
                subtitle: "查詢期間累計",
                color: AppTheme.teslaRed,
                theme: theme
            )
            
            StatisticsSummaryCard(
                title: "總里程",
                value: String(format: "%.0f km", viewModel.totalMileage),
                subtitle: "查詢期間累計",
                color: Color.green,
                theme: theme
            )
            
            StatisticsSummaryCard(
                title: "平均成本",
                value: String(format: "$%.2f/km", viewModel.averageCostPerKm),
                subtitle: "期間平均值",
                secondaryValue: String(format: "%.2f km/kWh", viewModel.averageEfficiency),
                color: Color.orange,
                theme: theme
            )
        }
        .padding(.horizontal, 2)
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(red: 24/255, green: 26/255, blue: 32/255)
                .ignoresSafeArea()
            StatisticsView(viewModel: StatisticsViewModel(), theme: AppTheme.shared)
                .padding()
        }
        .preferredColorScheme(.dark)
    }
}
