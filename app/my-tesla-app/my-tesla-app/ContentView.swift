enum ChargedLogSortKey: String, CaseIterable {
    case date, chargedKWh, mileage, totalCost
}

enum SortOrder {
    case ascending, descending
    mutating func toggle() { self = self == .ascending ? .descending : .ascending }
}
//
//  ContentView.swift
//  my-tesla-app
//
//  Created by nick on 2025/7/25.
//

import SwiftUI
struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var sortKey: ChargedLogSortKey = .date
    @State private var sortOrder: SortOrder = .descending
    @ObservedObject private var viewModel = ChargedLogViewModel()
    @StateObject private var statisticsViewModel = StatisticsViewModel()
    @State private var selectedTab = 0 // 0: 紀錄, 1: 統計
    @State private var showAddRecordSheet = false // 新增充電紀錄 Sheet

    var body: some View {
        ZStack {
            Color(red: 24/255, green: 26/255, blue: 32/255)
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 18) {
                    headerSection
                    tabSection
                }
                .padding(.bottom, 32)
                .padding(.horizontal, 8)
            }
            
            // FAB 浮動按鈕（僅在紀錄 Tab 顯示）
            if selectedTab == 0 {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showAddRecordSheet = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color(red: 94/255, green: 96/255, blue: 206/255))
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddRecordSheet) {
            AddChargeRecordView(onSuccess: {
                // 成功後重新載入資料
                viewModel.manualRefresh()
            })
        }
        .onAppear {
            viewModel.loadLogs()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                viewModel.refreshIfNeeded()
            }
        }
    }

    private var headerSection: some View {
        HStack {
            Text("MYTESLA")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(red: 232/255, green: 33/255, blue: 39/255))
            Spacer()
            Button(action: {
                viewModel.manualRefresh()
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.blue)
            }
            .padding(.trailing, 8)
            Text("Hi, Nick")
                .foregroundColor(.gray)
                .font(.system(size: 16))
        }
        .padding(.horizontal, 4)
        .padding(.top, 8)
    }


    @State private var showStartPicker = false
    @State private var showEndPicker = false
    @State private var selectedType: ChargeTypeFilter = .all

    enum ChargeTypeFilter: String, CaseIterable, Identifiable {
        case all = "all"
        case ac = "ACSingleWireCAN"
        case dc = "Supercharger"
        var id: String { rawValue }
        var display: String {
            switch self {
            case .all: return "全部"
            case .ac: return "AC"
            case .dc: return "DC"
            }
        }
        var icon: String {
            switch self {
            case .all: return "bolt.fill"
            case .ac: return "bolt.horizontal.fill"
            case .dc: return "bolt.fill.batteryblock"
            }
        }
    }

    private var filterBarSection: some View {
        HStack(spacing: 8) {
            Button(action: { showStartPicker = true }) {
                Text(dateString(viewModel.startDate))
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, minHeight: 38)
                    .background(Color(.systemGray5).opacity(0.2))
                    .cornerRadius(8)
            }
            .sheet(isPresented: $showStartPicker) {
                DatePickerSheet(
                    title: "選擇開始日期",
                    date: $viewModel.startDate,
                    range: Date.distantPast...viewModel.endDate,
                    onSelect: { showStartPicker = false }
                )
            }
            Button(action: { showEndPicker = true }) {
                Text(dateString(viewModel.endDate))
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, minHeight: 38)
                    .background(Color(.systemGray5).opacity(0.2))
                    .cornerRadius(8)
            }
            .sheet(isPresented: $showEndPicker) {
                DatePickerSheet(
                    title: "選擇結束日期",
                    date: $viewModel.endDate,
                    range: viewModel.startDate...Date(),
                    onSelect: { showEndPicker = false }
                )
            }
            Picker(selection: $selectedType, label:
                HStack(spacing: 4) {
                    Image(systemName: selectedType.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    Text(selectedType.display)
                }
                .foregroundColor(Color.blue)
                .frame(maxWidth: .infinity)
            ) {
                ForEach(ChargeTypeFilter.allCases) { type in
                    HStack(spacing: 6) {
                        Image(systemName: type.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 18, height: 18)
                        Text(type.display)
                    }.tag(type)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .frame(maxWidth: .infinity, minHeight: 38)
            .onChange(of: selectedType) { newType in
                viewModel.chargeTypeFilter = newType.rawValue
            }
        }
        .padding(.horizontal, 2)
    }

    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    // ...已移除地點下拉，類型下拉已合併至 filterBarSection...

    private var chartSection1: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("月度充電量")
                .foregroundColor(.gray)
                .font(.system(size: 15))
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 35/255, green: 38/255, blue: 47/255))
                .frame(height: 140)
                .overlay(
                    Text("[Bar Chart Placeholder]")
                        .foregroundColor(Color.gray.opacity(0.5))
                )
        }
        .padding(.horizontal, 2)
    }

    private var chartSection2: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("里程/費用統計")
                .foregroundColor(.gray)
                .font(.system(size: 15))
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 35/255, green: 38/255, blue: 47/255))
                .frame(height: 140)
                .overlay(
                    Text("[Bar Chart Placeholder]")
                        .foregroundColor(Color.gray.opacity(0.5))
                )
        }
        .padding(.horizontal, 2)
    }

    // Tab 切換區塊
    private var tabSection: some View {
        VStack(spacing: 20) {
            // Tab 按鈕
            HStack(spacing: 0) {
                Button(action: { selectedTab = 0 }) {
                    Text("紀錄")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selectedTab == 0 ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedTab == 0 ? Color(red: 94/255, green: 96/255, blue: 206/255) : Color.clear)
                        .cornerRadius(8)
                }
                
                Button(action: { selectedTab = 1 }) {
                    Text("統計")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selectedTab == 1 ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedTab == 1 ? Color(red: 94/255, green: 96/255, blue: 206/255) : Color.clear)
                        .cornerRadius(8)
                }
            }
            .padding(4)
            .background(Color(red: 35/255, green: 38/255, blue: 47/255))
            .cornerRadius(12)
            
            // Tab 內容
            if selectedTab == 0 {
                recordsTabContent
            } else {
                statisticsTabContent
            }
        }
        .padding(.horizontal, 2)
    }
    
    // 紀錄 Tab 內容
    private var recordsTabContent: some View {
        VStack(spacing: 14) {
            // 新增 summary 卡片
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("查詢區間充電度數")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                    Text(String(format: "%.1f kWh", viewModel.currentPeriodKWh))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    Text(viewModel.kWhComparisonText)
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 232/255, green: 33/255, blue: 39/255))
                }
                .padding()
                .background(Color(red: 35/255, green: 38/255, blue: 47/255))
                .cornerRadius(18)
                VStack(alignment: .leading, spacing: 4) {
                    Text("查詢區間充電費用")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                    Text(String(format: "$%.0f", viewModel.currentPeriodCost))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    if let avg = viewModel.currentPeriodAvgCostPerKWh {
                        Text(String(format: "平均 $%.2f / kWh", avg))
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 232/255, green: 33/255, blue: 39/255))
                    } else {
                        Text("—")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 232/255, green: 33/255, blue: 39/255))
                    }
                    Text(viewModel.costComparisonText)
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 232/255, green: 33/255, blue: 39/255))
                }
                .padding()
                .background(Color(red: 35/255, green: 38/255, blue: 47/255))
                .cornerRadius(18)
            }
            filterBarSection
            tableSection
        }
    }
    
    // 統計 Tab 內容
    private var statisticsTabContent: some View {
        StatisticsView(viewModel: statisticsViewModel)
    }

    private var tableSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding()
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else if viewModel.logsFiltered.isEmpty {
                Text("尚無資料")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                GeometryReader { geometry in
                    let totalWidth = geometry.size.width - 16 // 減去 padding
                    let dateWidth = totalWidth * 0.25     // 25% 給日期
                    let numberWidth = totalWidth * 0.18   // 18% 給度數
                    let mileageWidth = totalWidth * 0.18   // 18% 給里程
                    let priceWidth = totalWidth * 0.24     // 24% 給費用
                    let typeWidth = totalWidth * 0.15      // 15% 給類型

                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 0) {
                            sortableHeader(title: "日期", key: .date, width: dateWidth, alignment: .leading)
                            sortableHeader(title: "度數", key: .chargedKWh, width: numberWidth, alignment: .center)
                            sortableHeader(title: "里程", key: .mileage, width: mileageWidth, alignment: .center)
                            sortableHeader(title: "費用", key: .totalCost, width: priceWidth, alignment: .center)
                            Text("類型")
                                .frame(width: typeWidth, alignment: .center)
                        }
                        .foregroundColor(.gray)
                        .font(.system(size: 14, weight: .medium))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                        .background(Color(red: 35/255, green: 38/255, blue: 47/255))

                        ForEach(Array(sortedLogs.enumerated()), id: \.element.id) { i, log in
                            HStack(spacing: 0) {
                                Text(shortDate(log.date))
                                    .frame(width: dateWidth, alignment: .leading)
                                Text(log.chargedKWh ?? "")
                                    .frame(width: numberWidth, alignment: .center)
                                Text(log.mileage ?? "")
                                    .frame(width: mileageWidth, alignment: .center)
                                Text("$\(log.totalCost ?? "")")
                                    .frame(width: priceWidth, alignment: .center)
                                Text(typeDisplayName(log.chargeType))
                                    .frame(width: typeWidth, alignment: .center)
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 8)
                            .background(i % 2 == 0 ? Color(red: 35/255, green: 38/255, blue: 47/255) : Color(red: 27/255, green: 29/255, blue: 35/255))
                        }
                    }
                    .cornerRadius(12)
                }
                .frame(height: CGFloat(sortedLogs.count * 40 + 50)) // 動態高度
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 2)
    }

    private var sortedLogs: [ChargedLogEntry] {
        let dateFormatter = ChargedLogViewModel.dateFormatter
        return viewModel.logsFiltered.sorted { a, b in
            let cmp: ComparisonResult
            switch sortKey {
            case .date:
                let aDate = dateFormatter.date(from: a.date)
                let bDate = dateFormatter.date(from: b.date)
                if let aDate, let bDate {
                    cmp = aDate.compare(bDate)
                } else {
                    cmp = (a.date < b.date) ? .orderedAscending : (a.date > b.date ? .orderedDescending : .orderedSame)
                }
            case .chargedKWh:
                let aVal = Double(a.chargedKWh ?? "") ?? 0
                let bVal = Double(b.chargedKWh ?? "") ?? 0
                cmp = aVal < bVal ? .orderedAscending : (aVal > bVal ? .orderedDescending : .orderedSame)
            case .mileage:
                let aVal = Double(a.mileage ?? "") ?? 0
                let bVal = Double(b.mileage ?? "") ?? 0
                cmp = aVal < bVal ? .orderedAscending : (aVal > bVal ? .orderedDescending : .orderedSame)
            case .totalCost:
                let aVal = Double(a.totalCost ?? "") ?? 0
                let bVal = Double(b.totalCost ?? "") ?? 0
                cmp = aVal < bVal ? .orderedAscending : (aVal > bVal ? .orderedDescending : .orderedSame)
            }
            return sortOrder == .ascending ? cmp == .orderedAscending : cmp == .orderedDescending
        }
    }

    @ViewBuilder
    private func sortableHeader(title: String, key: ChargedLogSortKey, width: CGFloat, alignment: Alignment) -> some View {
        Button(action: {
            if sortKey == key {
                sortOrder.toggle()
            } else {
                sortKey = key
                sortOrder = .descending
            }
        }) {
            HStack(spacing: 2) {
                Text(title)
                Group {
                    if sortKey == key {
                        VStack(spacing: 0) {
                            Image(systemName: "arrowtriangle.up.fill")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(sortOrder == .ascending ? .blue : .gray)
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(sortOrder == .descending ? .blue : .gray)
                        }
                    } else {
                        VStack(spacing: 0) {
                            Image(systemName: "arrowtriangle.up.fill")
                                .font(.system(size: 8, weight: .regular))
                                .foregroundColor(.gray)
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.system(size: 8, weight: .regular))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .frame(width: width, alignment: alignment)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func typeDisplayName(_ raw: String?) -> String {
        switch raw {
        case "Supercharger": return "DC"
        case "ACSingleWireCAN": return "AC"
        default: return raw ?? ""
        }
    }

    private func shortDate(_ dateString: String) -> String {
        if let spaceIdx = dateString.firstIndex(of: " ") {
            return String(dateString[..<spaceIdx])
        }
        return dateString
    }
}

// 自訂 DatePickerSheet，選到日期自動 dismiss
struct DatePickerSheet: View {
    let title: String
    @Binding var date: Date
    var range: ClosedRange<Date>?
    var onSelect: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            DatePicker(title, selection: Binding(
                get: { date },
                set: { newValue in
                    date = newValue
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        onSelect()
                        dismiss()
                    }
                }
            ), in: range ?? Date.distantPast...Date.distantFuture, displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .labelsHidden()
                .padding()
        }
        .presentationDetents([.medium])
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
