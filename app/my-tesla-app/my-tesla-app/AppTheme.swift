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
            return Color(red: 242/255, green: 242/255, blue: 247/255)
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
