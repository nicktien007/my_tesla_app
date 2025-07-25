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
                    // Header
                    HStack {
                        Text("TESLA")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(red: 232/255, green: 33/255, blue: 39/255))
                        Spacer()
                        Text("Hi, User")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 8)

                    // Cards
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

                    // Filter Bar
                    HStack(spacing: 8) {
                        DatePicker("", selection: .constant(Date()), displayedComponents: .date)
                            .labelsHidden()
                            .frame(maxWidth: 120)
                        DatePicker("", selection: .constant(Date()), displayedComponents: .date)
                            .labelsHidden()
                            .frame(maxWidth: 120)
                    }
                    .padding(.horizontal, 2)

                    HStack(spacing: 20) {
                        Picker(selection: .constant(0), label:
                            HStack(spacing: 4) {
                                Image(systemName: "mappin.and.ellipse")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                Text("地點")
                            }
                            .foregroundColor(Color.blue)
                        ) {
                            HStack(spacing: 6) {
                                Image(systemName: "mappin.and.ellipse")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 18, height: 18)
                                Text("地點")
                            }.tag(0)
                            HStack(spacing: 6) {
                                Image(systemName: "house.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 18, height: 18)
                                Text("家用充電")
                            }.tag(1)
                            HStack(spacing: 6) {
                                Image(systemName: "bolt.car")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 18, height: 18)
                                Text("超充站")
                            }.tag(2)
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: 120)
                        Picker(selection: .constant(0), label:
                            HStack(spacing: 4) {
                                Image(systemName: "bolt.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                Text("類型")
                            }
                            .foregroundColor(Color.blue)
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
                        .frame(maxWidth: 120)
                    }
                    .padding(.horizontal, 2)

                    // Chart Section 1
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

                    // Chart Section 2
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

                    // Table Section
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
                        } else if viewModel.logs.isEmpty {
                            Text("尚無資料")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack {
                                        Text("日期").frame(width: 80)
                                        Text("度數").frame(width: 60)
                                        Text("費用").frame(width: 70)
                                        Text("地點").frame(width: 80)
                                        Text("類型").frame(width: 60)
                                        Text("備註").frame(width: 80)
                                    }
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.vertical, 4)
                                    .background(Color(red: 35/255, green: 38/255, blue: 47/255))
                                    ForEach(viewModel.logs.indices, id: \.self) { i in
                                        let log = viewModel.logs[i]
                                        HStack {
                                            Text(log.date).frame(width: 80)
                                            Text(log.chargedKWh ?? "").frame(width: 60)
                                            Text("$\(log.totalCost ?? "")").frame(width: 70)
                                            Text(log.location ?? "").frame(width: 80)
                                            Text(log.chargeType ?? "").frame(width: 60)
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
                .padding(.bottom, 32)
                .padding(.horizontal, 8)
            }
        }
        .onAppear {
            viewModel.loadLogs()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
