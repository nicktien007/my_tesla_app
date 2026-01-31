# CHANGELOG

所有顯著變更都會記錄在此檔案中。

格式基於 [Keep a Changelog](https://keepachangelog.com/zh-TW/1.0.0/)。

---

## [Unreleased]

### Changed
- **手動新增充電紀錄 API 改為 POST**
  - 將 API 請求方法從 GET 改為 POST
  - 使用 JSON body 傳送參數（p, t, method）
  - 設定 Content-Type 為 `text/plain;charset=utf-8` 避免 GAS 跨域 CORS 問題
  - 更新 `AddChargeRecordViewModel.swift` 實作
  - 更新 `手動新增充電紀錄.md` 規格書

---

## [1.4.0] - 2026-02-01

### Added
- **深色/淺色模式切換功能**
  - 新增 `AppTheme.swift` 統一管理主題色彩
  - 首頁右上角新增模式切換按鈕（太陽/月亮圖示）
  - 支援平滑動畫過渡效果
  - 使用 UserDefaults 儲存用戶偏好設定
  - 所有頁面（ContentView、StatisticsView、AddChargeRecordView、ChartViews）套用主題系統

### Documentation
- 新增 `COMMIT_CONVENTION.md` Git commit 訊息規範
- 新增 `dark-light-mode.md` 深淺色模式功能規格書
- 更新 `copilot-instructions.md` 指定 commit 規範參考

---

## [1.3.0] - 2026-01-31

### Added
- **手動新增充電紀錄功能**
  - 新增浮動按鈕（FAB）於充電紀錄列表右下角
  - 支援輸入價格/kWh 與選擇充電類型
  - 整合 Google Apps Script API 寫入 Google Sheets
  - 自動記錄自訂價格至常用選項
  - 新增 `AddChargeRecordView.swift`、`AddChargeRecordViewModel.swift`、`CustomPriceManager.swift`
- **單元測試**：新增手動新增充電紀錄功能的單元測試
- 更新 Copilot 指南，新增測試指令

---

## [1.2.0] - 2025-08-01

### Added
- **統計功能**
  - 新增統計資料模型（`StatisticsEntry.swift`）
  - 新增統計視圖（`StatisticsView.swift`）與視圖模型（`StatisticsViewModel.swift`）
  - 整合至主介面 Tab 切換（紀錄 / 統計）
  - 支援年份與時間範圍篩選（全部 / 近六個月）
  - 連接 Google Sheets API 取得統計數據

### Changed
- 重構 `ContentView`，將 `filterBarSection` 移至紀錄 Tab 內容中
- 改善年份與時間範圍選擇器的觸發範圍
- 選擇變更時自動載入統計資料
- 自動切換年份與時間範圍至「全部」和「近六個月」

---

## [1.1.0] - 2025-07-28 ~ 2025-07-29

### Added
- **查詢區間統計**
  - 顯示查詢區間總充電費用、總充電度數
  - 計算平均每度電費用
  - 與前期數據比較
- **充電類型篩選功能**：支援按 AC / DC / 全部 篩選
- **自動刷新功能**：根據應用程式狀態（前景/背景）自動更新資料
- **手動刷新按鈕**：右上角刷新按鈕，改善使用者互動體驗

### Changed
- 重構 `ChargedLogService` 以從 `Config.plist` 讀取 API 金鑰
- 重構 `ChargedLogViewModel` 日期格式化器為靜態屬性
- 更新 PRD.md 中的 API 端點以使用佔位符
- 新增 `.gitignore` 檔案

### Fixed
- 改善排序邏輯與日期比較

---

## [1.0.0] - 2025-07-25

### Added
- **專案初始化**
  - 建立 Xcode 專案結構（`my-tesla-app.xcodeproj`）
  - 建立 SwiftUI 主視圖（`ContentView.swift`）
  - 新增應用程式圖示（多解析度）
  - 新增測試檔案框架

- **充電紀錄功能**
  - 新增資料模型 `ChargedLogEntry.swift`
  - 新增資料服務 `ChargedLogService.swift`（連接 Google Sheets API）
  - 新增視圖模型 `ChargedLogViewModel.swift`（MVVM 架構）
  - 顯示充電紀錄列表，包含日期、度數、里程、費用、類型

- **篩選與排序**
  - 支援依日期區間篩選
  - 支援依日期、充電度數、里程、費用排序
  - 自訂 `DatePickerSheet` 元件

- **UI/UX**
  - Tab 切換功能（紀錄 / 統計）
  - Tesla 官方風格深色主題
  - 響應式表格佈局（GeometryReader）
  - 載入狀態與錯誤訊息顯示

### Changed
- 調整 `ChargedLogEntry` 結構，移除未使用的欄位（location、note）
- 充電類型顯示規則：Supercharger → DC，ACSingleWireCAN → AC

### Documentation
- 新增 `spec/` 資料夾，存放規格文件
- 新增 `PRD.md` 產品技術規格書
- 新增 `ChargedLogExample.json` 資料範例
- 新增 `prototype.html` UI 原型

---

## 版本說明

- **Major (X.0.0)**：重大功能新增或架構變更
- **Minor (0.X.0)**：新功能或顯著改進
- **Patch (0.0.X)**：Bug 修復或小幅調整

---

## 相關文件

- [PRD.md](PRD.md)：產品技術規格書
- [手動新增充電紀錄.md](feat/手動新增充電紀錄.md)：手動新增充電紀錄功能規格
- [ChargedLogExample.json](example/ChargedLogExample.json)：充電紀錄資料範例
