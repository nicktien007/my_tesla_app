//
//  AppTheme.swift
//  my-tesla-app
//
//  統一管理主題色彩與深淺色模式切換
//

import SwiftUI

// MARK: - 主題模式列舉
enum AppThemeMode: String {
    case dark
    case light
}

// MARK: - 主題管理器
class AppTheme: ObservableObject {
    static let shared = AppTheme()
    
    @Published var mode: AppThemeMode {
        didSet {
            UserDefaults.standard.set(mode.rawValue, forKey: "appThemeMode")
        }
    }
    
    init() {
        let savedMode = UserDefaults.standard.string(forKey: "appThemeMode") ?? "dark"
        self.mode = AppThemeMode(rawValue: savedMode) ?? .dark
    }
    
    // MARK: - 背景色
    var backgroundColor: Color {
        switch mode {
        case .dark:
            return Color(red: 24/255, green: 26/255, blue: 32/255)
        case .light:
            return Color(red: 245/255, green: 245/255, blue: 250/255)
        }
    }
    
    // MARK: - 卡片底色
    var cardBackgroundColor: Color {
        switch mode {
        case .dark:
            return Color(red: 35/255, green: 38/255, blue: 47/255)
        case .light:
            return Color.white
        }
    }
    
    // MARK: - 表格交替行底色
    var tableAlternateRowColor: Color {
        switch mode {
        case .dark:
            return Color(red: 27/255, green: 29/255, blue: 35/255)
        case .light:
            return Color(red: 248/255, green: 248/255, blue: 250/255)
        }
    }
    
    // MARK: - 主要文字色
    var primaryTextColor: Color {
        switch mode {
        case .dark:
            return .white
        case .light:
            return Color(red: 28/255, green: 28/255, blue: 30/255)
        }
    }
    
    // MARK: - 次要文字色
    var secondaryTextColor: Color {
        switch mode {
        case .dark:
            return .gray
        case .light:
            return Color(red: 142/255, green: 142/255, blue: 147/255)
        }
    }
    
    // MARK: - 輸入框背景色
    var inputBackgroundColor: Color {
        switch mode {
        case .dark:
            return Color(red: 35/255, green: 38/255, blue: 47/255)
        case .light:
            return Color.white
        }
    }
    
    // MARK: - 輸入框邊框色
    var inputBorderColor: Color {
        switch mode {
        case .dark:
            return Color.clear
        case .light:
            return Color(red: 200/255, green: 200/255, blue: 205/255)
        }
    }
    
    // MARK: - Placeholder 色彩
    var placeholderColor: Color {
        switch mode {
        case .dark:
            return Color.gray
        case .light:
            return Color(red: 150/255, green: 150/255, blue: 155/255) // Darkened from 180
        }
    }
    
    // MARK: - Segmented Control Track 色彩
    var segmentedTrackColor: Color {
        switch mode {
        case .dark:
            return Color(red: 20/255, green: 20/255, blue: 25/255) // Darker than card
        case .light:
            return Color(red: 235/255, green: 235/255, blue: 240/255) // Safe light gray
        }
    }
    
    // MARK: - 常用固定色彩
    static let teslaRed = Color(red: 232/255, green: 33/255, blue: 39/255)
    static let accentPurple = Color(red: 94/255, green: 96/255, blue: 206/255)
    
    // MARK: - 切換模式
    func toggle() {
        mode = mode == .dark ? .light : .dark
    }
    
    // MARK: - 切換按鈕圖示
    var toggleIcon: String {
        switch mode {
        case .dark:
            return "sun.max.fill"
        case .light:
            return "moon.fill"
        }
    }
    
    // MARK: - 切換按鈕顏色
    var toggleIconColor: Color {
        switch mode {
        case .dark:
            return .orange
        case .light:
            return .indigo
        }
    }
}
