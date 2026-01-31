# Git Commit 訊息規範

本專案遵循 [Conventional Commits](https://www.conventionalcommits.org/) 規範。

---

## Commit 訊息格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 範例

```
feat(充電紀錄): 新增手動新增充電紀錄功能

- 新增浮動按鈕（FAB）於列表右下角
- 整合 Google Apps Script API
- 支援自訂價格儲存

Closes #123
```

---

## Type（類型）

| Type | 說明 | Emoji |
|------|------|-------|
| `feat` | 新功能 | ✨ |
| `fix` | Bug 修復 | 🐛 |
| `docs` | 文件變更 | 📝 |
| `style` | 程式碼格式（不影響邏輯） | 💄 |
| `refactor` | 重構（非新功能、非修復） | ♻️ |
| `perf` | 效能優化 | ⚡️ |
| `test` | 測試相關 | ✅ |
| `chore` | 建置/工具/設定變更 | 🔧 |
| `ci` | CI/CD 相關 | 👷 |
| `revert` | 還原先前 commit | ⏪ |

---

## Scope（範圍）- 選填

常用 scope：

| Scope | 說明 |
|-------|------|
| `充電紀錄` | ChargedLog 相關功能 |
| `統計` | Statistics 相關功能 |
| `UI` | 介面相關調整 |
| `主題` | 深淺色模式、主題色彩 |
| `API` | API 串接相關 |
| `設定` | Config、Settings 相關 |
| `測試` | 測試相關 |
| `文件` | 文件、規格書 |

---

## Subject（主旨）

- 使用繁體中文
- 簡潔描述變更內容
- 不超過 50 字元
- 不加句號結尾
- 使用祈使語氣（如：新增、修復、調整、移除）

### 常用動詞

| 動詞 | 使用情境 |
|------|---------|
| 新增 | 新功能、新檔案 |
| 修復 | Bug 修復 |
| 調整 | 小幅修改、優化 |
| 重構 | 程式碼重構 |
| 移除 | 刪除功能、檔案 |
| 更新 | 更新相依、文件 |
| 修正 | 錯字、格式修正 |

---

## Body（內文）- 選填

- 說明「為什麼」做這個變更
- 說明「如何」實作
- 與之前行為的差異
- 每行不超過 72 字元

---

## Footer（頁尾）- 選填

- `Closes #issue_number`：關聯 Issue
- `BREAKING CHANGE:`：重大變更說明
- `Refs #issue_number`：參考相關 Issue

---

## 完整範例

### 新功能

```
feat(主題): 新增深色/淺色模式切換功能

- 新增 AppTheme.swift 統一管理主題色彩
- 首頁右上角新增切換按鈕
- 使用 UserDefaults 儲存偏好設定
- 支援平滑動畫過渡

Closes #45
```

### Bug 修復

```
fix(充電紀錄): 修復日期篩選結果不正確問題

日期比較未考慮時區，導致跨日資料顯示錯誤。
改用 Calendar 進行日期比較。

Closes #67
```

### 文件更新

```
docs(文件): 新增 CHANGELOG.md 與 commit 規範
```

### 重構

```
refactor(UI): 重構 ContentView 抽取 headerSection 為獨立 View
```

### 多項變更

```
chore: 更新專案設定與文件

- 新增 COMMIT_CONVENTION.md
- 更新 copilot-instructions.md
- 新增 CHANGELOG.md
```

---

## 注意事項

1. **一個 commit 做一件事**：避免混合不相關的變更
2. **先寫測試**：新功能盡量先寫測試再實作
3. **保持原子性**：每個 commit 應可獨立編譯執行
4. **經常 commit**：小步快跑，避免大型 commit

---

## 相關文件

- [CHANGELOG.md](CHANGELOG.md)：版本變更紀錄
- [PRD.md](PRD.md)：產品技術規格書
