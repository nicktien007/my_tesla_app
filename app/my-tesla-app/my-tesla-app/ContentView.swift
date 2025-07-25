//
//  ContentView.swift
//  my-tesla-app
//
//  Created by nick on 2025/7/25.
//

import SwiftUI
struct ContentView: View {
    @StateObject private var viewModel = ChargedLogViewModel()

    var body: some View {
        ZStack {
            Color(red: 24/255, green: 26/255, blue: 32/255)
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 18) {
                    headerSection
                    cardsSection
                    filterBarSection
                    chartSection1
                    chartSection2
                    tableSection
                }
                .padding(.bottom, 32)
                .padding(.horizontal, 8)
            }
        }
        .onAppear {
            viewModel.loadLogs()
        }
    }

    private var headerSection: some View {
        HStack {
            Text("TESLA")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(red: 232/255, green: 33/255, blue: 39/255))
            Spacer()
            Text("Hi, Nick")
                .foregroundColor(.gray)
                .font(.system(size: 16))
        }
        .padding(.horizontal, 4)
        .padding(.top, 8)
    }

    private var cardsSection: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("本月充電度數")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                Text("120.5 kWh")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                Text("較上月 +8%")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 232/255, green: 33/255, blue: 39/255))
            }
            .padding()
            .background(Color(red: 35/255, green: 38/255, blue: 47/255))
            .cornerRadius(18)
            VStack(alignment: .leading, spacing: 4) {
                Text("本月充電費用")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                Text("$2520")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                Text("平均 $2.1 / kWh")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 232/255, green: 33/255, blue: 39/255))
            }
            .padding()
            .background(Color(red: 35/255, green: 38/255, blue: 47/255))
            .cornerRadius(18)
        }
    }

    @State private var showStartPicker = false
    @State private var showEndPicker = false

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
            Picker(selection: .constant(0), label:
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    Text("類型")
                }
                .foregroundColor(Color.blue)
                .frame(maxWidth: .infinity)
            ) {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 18)
                    Text("類型")
                }.tag(0)
                HStack(spacing: 6) {
                    Image(systemName: "bolt.horizontal.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 18)
                    Text("AC")
                }.tag(1)
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill.batteryblock")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 18)
                    Text("DC")
                }.tag(2)
            }
            .pickerStyle(MenuPickerStyle())
            .frame(maxWidth: .infinity, minHeight: 38)
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

    private var tableSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("充電紀錄")
                .foregroundColor(.gray)
                .font(.system(size: 15))
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
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("日期").frame(width: 100)
                            Text("度數").frame(width: 60)
                            Text("費用").frame(width: 70)
                            Text("類型").frame(width: 60)
                            Text("備註").frame(width: 80)
                        }
                        .foregroundColor(.gray)
                        .font(.system(size: 14, weight: .medium))
                        .padding(.vertical, 4)
                        .background(Color(red: 35/255, green: 38/255, blue: 47/255))
                        ForEach(Array(viewModel.logsFiltered.enumerated()), id: \.element.id) { i, log in
                            HStack {
                                Text(log.date).frame(width: 100)
                                Text(log.chargedKWh ?? "").frame(width: 60)
                                Text("$\(log.totalCost ?? "")").frame(width: 70)
                                Text(typeDisplayName(log.chargeType)).frame(width: 60)
                                Text(log.note ?? "").frame(width: 80)
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .background(i % 2 == 0 ? Color(red: 35/255, green: 38/255, blue: 47/255) : Color(red: 27/255, green: 29/255, blue: 35/255))
                        }
                    }
                }
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 2)
    }

    private func typeDisplayName(_ raw: String?) -> String {
        switch raw {
        case "Supercharger": return "DC"
        case "ACSingleWireCAN": return "AC"
        default: return raw ?? ""
        }
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
