import SwiftUI

struct StatisticsView: View {
    @ObservedObject private var viewModel = StatisticsViewModel()
    
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
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        // 統計摘要卡片
                        summarySection
                        
                        // 月度充電量圖表
                        MonthlyChargedChart(data: viewModel.monthlyChargedData)
                        
                        // 效率與費用趨勢圖
                        EfficiencyVsCostChart(data: viewModel.efficiencyVsCostData)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            viewModel.loadStatistics()
        }
    }
    
    private var filterSection: some View {
        HStack(spacing: 12) {
            // 年份選擇器
            if !viewModel.availableYears.isEmpty {
                Picker("年份", selection: $viewModel.selectedYear) {
                    ForEach(viewModel.availableYears, id: \.self) { year in
                        Text(year == "all" ? "全部" : year)
                            .foregroundColor(.white)
                            .tag(year)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(red: 35/255, green: 38/255, blue: 47/255))
                .cornerRadius(8)
            }
            
            // 時間範圍選擇器
            Picker("時間範圍", selection: $viewModel.selectedTimeRange) {
                ForEach(StatisticsViewModel.TimeRangeFilter.allCases) { range in
                    Text(range.display)
                        .foregroundColor(.white)
                        .tag(range)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(red: 35/255, green: 38/255, blue: 47/255))
            .cornerRadius(8)
        }
        .padding(.horizontal, 2)
    }
    
    private var summarySection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
            StatisticsSummaryCard(
                title: "總充電量",
                value: String(format: "%.1f kWh", viewModel.totalChargedKWh),
                subtitle: "查詢期間累計",
                color: Color(red: 94/255, green: 96/255, blue: 206/255)
            )
            
            StatisticsSummaryCard(
                title: "總費用",
                value: String(format: "$%.0f", viewModel.totalCost),
                subtitle: "查詢期間累計",
                color: Color(red: 232/255, green: 33/255, blue: 39/255)
            )
            
            StatisticsSummaryCard(
                title: "總里程",
                value: String(format: "%.0f km", viewModel.totalMileage),
                subtitle: "查詢期間累計",
                color: Color.green
            )
            
            StatisticsSummaryCard(
                title: "平均電耗",
                value: String(format: "%.2f km/kWh", viewModel.averageEfficiency),
                subtitle: "期間平均值",
                color: Color.orange
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
            StatisticsView()
                .padding()
        }
        .preferredColorScheme(.dark)
    }
}
