# my-tesla-app Copilot 指南

- 當需求異動的時候，評估是否調整 #PRD.md or .github/copilot-instructions.md 檔案。

## 專案概覽
- 這是一個使用 SwiftUI 開發的 iOS App，用於管理與瀏覽 Tesla 充電紀錄。
- 主要程式碼位於 `app/my-tesla-app/my-tesla-app/`。
- 重要檔案：
  - `ChargedLogEntry.swift`：充電紀錄資料模型。
  - `ChargedLogService.swift`：充電紀錄資料存取服務（包含讀取、儲存等）。
  - `ChargedLogViewModel.swift`：商業邏輯與狀態管理 ViewModel。
  - `ContentView.swift`：主畫面入口。
  - `my_tesla_appApp.swift`：App 生命週期與根組件。

## 架構與設計模式
- 採用 MVVM（Model-View-ViewModel）架構。
- 資料流：`ChargedLogService`（資料）→ `ChargedLogViewModel`（邏輯/狀態）→ SwiftUI View。
- ViewModel 盡量以依賴注入方式取得 Service。
- 圖片資產依類型/地點分類於 `Assets.xcassets`。

## 開發流程
- **建置與執行：** 請用 Xcode 開啟 `my-tesla-app.xcodeproj` 進行 build 與執行。
- **單元測試：** 於 Xcode 執行 `my-tesla-appTests/` 內測試。
- **UI 測試：** 於 Xcode 執行 `my-tesla-appUITests/` 內測試。
- **範例資料：** 開發/測試可用 `spec/example/` 內的 mock 資料。

## 專案慣例
- Swift 檔案型別名稱用 PascalCase，變數/函式用 camelCase。
- 所有商業邏輯應寫在 ViewModel 或 Service，不放在 View。
- UI 全部採用 SwiftUI，不使用 UIKit。
- 新增圖片資產請放入 `Assets.xcassets`，並以名稱引用。
- 除測試外，所有 app 邏輯皆放於 `my-tesla-app/my-tesla-app/`。

## 整合與外部資源
- 無外部相依（未發現 CocoaPods、SPM、Carthage 等設定）。
- API 範例與端點請參考 `spec/tesla_fleet_api_all_endpoints.postman_collection.json`。
- 產品需求與功能請參考 `spec/PRD.md`。

## 實作範例
- 新增充電紀錄類型：請更新 `ChargedLogEntry.swift`，於 `ChargedLogService.swift` 增加邏輯，並透過 `ChargedLogViewModel.swift` 對外提供。
- 新增 UI 畫面：建立 SwiftUI View，並連結對應 ViewModel。

---

如有不清楚或特殊設計，請參考 `my-tesla-app/my-tesla-app/` 及 `spec/` 內檔案範例與需求。
