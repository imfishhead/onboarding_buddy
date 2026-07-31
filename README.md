# Onboarding Buddy 🚀

一個現代化的員工入職助手應用，結合任務管理、心情追蹤和 AI 聊天功能，幫助新員工順利適應工作環境。

## ✨ 主要功能

### 🎯 任務管理
- **智能任務分配**：根據員工角色自動分配入職任務
- **進度追蹤**：視覺化進度條顯示完成狀況
- **現代化 UI**：固定高度滾動區域，響應式設計
- **即時更新**：AJAX 任務狀態切換，無需頁面刷新

### 💬 AI 聊天助手
- **智能對話**：基於 LLM 的問答系統
- **美觀氣泡**：漸層背景、陰影效果的聊天氣泡
- **即時回應**：Loading 動畫和流暢的用戶體驗
- **上下文記憶**：保持對話連續性

### 😊 心情追蹤系統
- **呼吸環視覺化**：基於 Valence-Arousal 模型的情緒色彩映射
- **加權平均計算**：使用最近 3 次心情記錄的平滑算法
- **4-6-8 呼吸練習**：整合呼吸訓練功能
- **智能回饋**：個人化建議和資源推薦

### 🎉 幸福點數系統
- **點數累積**：完成任務和心情記錄獲得點數
- **等級系統**：多倍數獎勵機制
- **慶祝動畫**：任務完成時的視覺回饋

## 🛠 技術架構

### 後端技術
- **Ruby on Rails 8.0.2**：現代化 Web 框架
- **SQLite3**：輕量級資料庫
- **Puma**：高效能 Web 伺服器
- **Hotwire**：Turbo + Stimulus 無縫整合

### 前端技術
- **Tailwind CSS**：實用優先的 CSS 框架
- **Google Material Icons**：現代化圖標系統
- **Vanilla JavaScript**：原生 JS 實現互動功能
- **CSS 動畫**：流暢的過渡效果和動畫

### 設計模式
- **MVC 架構**：清晰的關注點分離
- **Service Objects**：業務邏輯封裝
- **Helper Methods**：視圖邏輯抽象
- **AJAX 整合**：無縫的用戶體驗

## 📁 專案結構

```
app/
├── controllers/
│   ├── home_controller.rb          # 主頁控制器
│   ├── my/
│   │   ├── onboarding_controller.rb # 任務管理
│   │   ├── chat_controller.rb      # AI 聊天
│   │   └── mood_checkins_controller.rb # 心情記錄
├── models/
│   ├── user.rb                     # 用戶模型
│   ├── onboarding_task.rb          # 入職任務
│   ├── task_assignment.rb          # 任務分配
│   ├── llm_session.rb             # 聊天會話
│   ├── llm_message.rb              # 聊天訊息
│   ├── mood_checkin.rb             # 心情記錄
│   ├── happiness_wallet.rb         # 幸福錢包
│   └── happiness_transaction.rb    # 幸福交易
├── services/
│   ├── mood/
│   │   └── feedback_service.rb      # 心情回饋服務
│   └── happiness/
│       └── accrual.rb               # 點數累積服務
└── views/
    └── home/
        └── index.html.erb           # 主頁視圖
```

## 🐳 Docker 部署（建議）

### 環境需求

- Docker Engine 24+
- Docker Compose v2

### 第一次部署

1. 建立環境變數檔：

   ```bash
   cp .env.example .env
   openssl rand -hex 64
   ```

2. 將產生的隨機字串填入 `.env` 的 `SECRET_KEY_BASE`。如果 LLM API 不在 Docker host 的 `8000` port，也請一併修改 `LLM_API_BASE_URL`。

3. 建置並在背景啟動：

   ```bash
   docker compose up -d --build
   ```

4. 確認服務狀態：

   ```bash
   docker compose ps
   docker compose logs -f web
   ```

   預設可由 [http://localhost:3000](http://localhost:3000) 開啟。容器啟動時會自動執行 `rails db:prepare`，不需要另外 migrate。

### 更新部署

拉取新版程式後重新建置即可：

```bash
git pull
docker compose up -d --build
```

Compose 使用 named volume `onboarding_buddy_storage` 保存 SQLite 資料庫與本機上傳檔案；重建或替換 `web` 容器不會清除資料。請勿使用 `docker compose down --volumes`，除非確定要刪除所有持久化資料。

### 常用指令

```bash
# 查看狀態與健康檢查結果
docker compose ps

# 查看即時 log
docker compose logs -f web

# 執行 Rails console
docker compose exec web bin/rails console

# 手動執行 migration
docker compose exec web bin/rails db:migrate

# 停止服務（保留資料）
docker compose down
```

### Docker 環境變數

| 變數 | 必填 | 預設值 | 說明 |
| --- | --- | --- | --- |
| `SECRET_KEY_BASE` | 是 | 無 | Rails production session／簽章密鑰，請使用隨機值 |
| `APP_PORT` | 否 | `3000` | 對外開放的 host port |
| `LLM_API_BASE_URL` | 否 | `http://host.docker.internal:8000` | LLM API base URL，不包含 `/route` |
| `RAILS_LOG_LEVEL` | 否 | `info` | Rails log level |

目前 production 使用 SQLite 與單一 web container，適合單機或小型部署。若要水平擴展成多個 application instances，應先改用共享式資料庫與檔案儲存。

## 🚀 本機開發

### 環境需求

- Ruby 3.3.5
- Rails 8.0.2
- Node.js 與 npm
- SQLite3

### 安裝步驟

1. **克隆專案**
   ```bash
   git clone <repository-url>
   cd onboarding_buddy
   ```

2. **安裝依賴**
   ```bash
   bundle install
   npm install
   ```

3. **資料庫設定**
   ```bash
   bin/rails db:prepare
   bin/rails db:seed
   ```

4. **啟動伺服器**
   ```bash
   bin/rails server
   ```

5. **訪問應用**
   打開瀏覽器訪問 `http://localhost:3000`

### 開發模式

```bash
# 啟動開發伺服器
bin/rails server

# 執行測試
bin/rails test

# 程式碼檢查
bundle exec rubocop

# 安全檢查
bundle exec brakeman
```

## 🎨 功能特色

### 響應式設計
- **Mobile First**：優先考慮行動裝置體驗
- **底部導航**：直觀的 Tab 切換
- **固定高度**：任務區域可滾動，聊天區域自適應

### 視覺化設計
- **漸層背景**：現代化的色彩搭配
- **毛玻璃效果**：`backdrop-filter` 創造層次感
- **微互動**：懸停效果和過渡動畫
- **呼吸環**：動態的情緒視覺化

### 用戶體驗
- **即時回饋**：Loading 狀態和成功提示
- **錯誤處理**：優雅的錯誤訊息
- **鍵盤支援**：Enter 鍵發送訊息
- **自動滾動**：聊天自動滾動到最新訊息

## 🔧 配置說明

本機開發預設使用 `storage/development.sqlite3`。Production 的 primary、cache、queue 與 cable SQLite 檔案都位於 `/rails/storage`，Docker Compose 已將該路徑掛載至持久化 volume。

### 路由配置
```ruby
Rails.application.routes.draw do
  root "home#index"
  post "home/message", to: "home#create_message"
  
  namespace :my do
    get "onboarding", to: "onboarding#index"
    patch "onboarding/complete/:id", to: "onboarding#complete"
    resources :mood_checkins, only: [:create]
    resources :chat, only: [:index, :create]
  end
end
```

## 📊 資料模型

### 核心實體
- **User**：用戶基本資訊
- **OnboardingTask**：入職任務模板
- **TaskAssignment**：任務分配記錄
- **LlmSession**：AI 聊天會話
- **MoodCheckin**：心情記錄
- **HappinessWallet**：幸福點數錢包

## 🎯 使用場景

### 新員工入職
1. **任務導覽**：系統自動分配入職任務
2. **進度追蹤**：視覺化完成狀況
3. **即時支援**：AI 助手回答問題
4. **心情關懷**：定期心情記錄和回饋

### HR 管理
1. **任務模板**：預設入職流程
2. **進度監控**：追蹤新員工適應狀況
3. **數據分析**：心情趨勢和完成率統計

## 🤝 貢獻指南

1. Fork 專案
2. 創建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交變更 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 開啟 Pull Request

---

**Onboarding Buddy** - 讓新員工的入職之旅更加順暢！ 🎉
