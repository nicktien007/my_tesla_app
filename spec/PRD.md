# Tesla 充電紀錄查詢 App 技術規格書（PRD）

## 1. 產品目標與簡介
本 App 供個人於 iOS 裝置安裝，連接 Google Sheets API 取得 Tesla 充電紀錄，提供資料查詢、統計與圖表視覺化，協助用戶追蹤充電花費、用量與節省成效。

## 2. 主要功能需求
- 連接指定 Google Sheets API，取得充電紀錄資料。
- 支援資料查詢（依日期、地點、充電類型等條件篩選）。
- 顯示統計數據（總充電量、總花費、節省金額等）。
- 圖表視覺化（長條圖、圓餅圖等，參考 Tesla 官方 UI）。
- 支援月/年切換、充電地點分佈、節省金額估算等。
- 支援離線快取最近一次資料。

## 3. API 資料來源與格式
- 參考文檔：
  - https://tw.wfublog.com/2022/05/sheet-api-read-google-spreadsheet-json.html
  - https://developers.google.com/workspace/sheets?hl=zh-tw
- 來源：Google Sheets API
- ChargedLog Endpoint：
  https://sheets.googleapis.com/v4/spreadsheets/1f1yibdEzIu_z_Wvi9p2sU18v-15QQXjtK5DqjG-zOkk/values/ChargedLog?key={{GOOGLE_SHEETS_API_KEY}}
  
  Statistics endpoint：
  https://sheets.googleapis.com/v4/spreadsheets/1f1yibdEzIu_z_Wvi9p2sU18v-15QQXjtK5DqjG-zOkk/values/統計!A:H?key={{GOOGLE_SHEETS_API_KEY}}
  
  統計 example.json：
  ```json
  {
    "range": "'統計'!A1:AA999",
    "majorDimension": "ROWS",
    "values": [
      [
        "日期",
        "年",
        "月",
        "統計階段里程(KM)",
        "統計充電度數",
        "統計平均電耗(km/kwh)",
        "統計平均每度價格",
        "統計總費用"
      ],
      [
        "2025/7",
        "2025",
        "7",
        "1445.138",
        "320.8",
        "4.505",
        "2.323",
        "745.220"
      ]
    ]
  }
  ```
- 回傳格式：JSON，欄位如 ChargedLogExample.json
- 主要欄位：
  - 日期、總里程、階段里程、充電度數、電耗、價格/度、總費用、充電類型

  - 充電類型欄位顯示規則：
    - 若原始值為 Supercharger，顯示「DC」
    - 若原始值為 ACSingleWireCAN，顯示「AC」

## 4. 資料查詢與圖表需求
- 查詢條件：
  - 日期區間、充電類型
- 統計指標：
  - 總充電量（kWh）、總花費、節省金額、各地點/類型佔比
- 圖表類型：
  - 月/年長條圖（充電量、花費）、圓餅圖（地點/類型分佈）、節省金額對比條圖
- UI 參考：見 image.png

## 5. 技術架構建議
- 前端：Swift (SwiftUI) 開發 iOS App
- API 串接：URLSession 直接呼叫 Google Sheets API
- 資料處理：本地快取、JSON 解析
- 圖表：建議用 Swift Charts 或第三方套件（如 Charts）
- 權限：App 僅需網路權限，API Key 嵌入或透過 Proxy 伺服器保護

## 6. 權限與安全性
- Google Sheets API Key 建議設限來源（如僅允許特定 IP 或 referrer）
- 若需寫入功能，需 OAuth 授權流程
- 僅個人使用，資料不對外公開

## 7. 其他注意事項
- UI/UX 需參考 Tesla 官方設計風格
- 支援深色模式
- 預留多語系擴充彈性

---

如有其他需求請補充，或針對細節討論後再進行實作。
