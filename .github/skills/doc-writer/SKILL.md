---
name: doc-writer
description: '自動分析程式碼專案並產出標準化技術文件，必備包含：使用方法、安裝方法（含本地打包）、技術細節、系統架構與代碼對應解釋。當使用者要求撰寫技術文檔、專案架構文件、代碼走讀或 README 時使用。'
user-invocable: true
argument-hint: '[目標檔案或模組路徑，例如 docs/TECHNICAL_DESIGN.md 或 README.md]'
---

# Technical Document Writer (doc-writer)

協助開發團隊自動分析目標專案程式碼，逆向推導架構，並產出結構嚴謹、可維護且資訊完整的五大核心技術文件章節。

## 核心產出規範

產出的技術文件必須嚴格涵蓋以下五大面向，不得省略任一區塊：

1. **使用方法（Usage Guide）**：快速上手指南、典型使用情境、CLI 指令參數說明、API 介面呼叫範例及預期輸出。
2. **安裝方法與本地打包（Installation & Local Packaging）**：
   - 執行與開發先決條件（Prerequisites）。
   - **本地打包完整步驟**：針對專案技術堆疊（如 Node/npm pack、Python/wheel、Go/build、.NET/publish、Rust/cargo package、PowerShell 模組或離線封裝），提供無對外網路連線亦可重現的本地封裝指令、產物目錄結構與 SHA256 驗證方式。
   - 本地安裝與導入方式（個人環境全域安裝 vs 單一專案安裝）。
3. **技術細節（Technical Details）**：資料規格、狀態機、配置設定參數表、邊界條件、並發與非同步處理、安全性防護與錯誤處理機制。
4. **系統架構（System Architecture）**：
   - 模組分層架構圖（使用 Mermaid `flowchart TD` 或 `graph TD`）。
   - 核心流程與時序循序圖（使用 Mermaid `sequenceDiagram`）。
   - 元件邊界與責任分工（Responsibility Matrix）。
5. **代碼對應解釋（Code Mapping & Implementation Deep-Dive）**：
   - 專案檔案結構樹狀圖與職責說明。
   - 關鍵檔案、類別、函式與型別符號走讀對照表（包含檔案路徑、符號名稱、業務職責）。
   - 核心程式碼片段逐行拆解與業務邏輯對應解說。

---

## 執行流程

### Step 1: 專案指紋與環境盤點 (Project Fingerprinting)
1. 偵測專案根目錄與設定檔（例如 `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `*.csproj`, `*.psd1`）。
2. 識別目前使用的技術棧、主要進入點（Entrypoints）、CLI 命令與公開 API。
3. 盤點專案既有依賴項，區分正式依賴與開發建置依賴。

### Step 2: 模組層次與架構逆向工程 (Architecture Reverse-Engineering)
1. 探索目錄組織，識別分層架構（如 Presentation / Business Logic / Data Access / Utilities）。
2. 分析資料流向與生命週期：從請求輸入、中介處理、核心演算法到輸出產物。
3. 繪製 Mermaid 分層架構圖與關鍵流程之時序循序圖。避免複雜語法，確保 Mermaid 節點名稱使用雙引號包覆。

### Step 3: 本地打包與建置策略生成 (Local Packaging & Build Engineering)
1. 針對專案語言設計「離線/本地打包」指令，不依賴遠端 Registry 推送：
   - **Node.js**: `npm pack` 或 `pnpm pack` 產出 `.tgz`
   - **Python**: `python -m build --sdist --wheel` 產出 `.whl`
   - **.NET**: `dotnet pack -c Release -o ./dist` 產出 `.nupkg`
   - **Go**: `go build -o ./bin/app` 封裝獨立二進制
   - **PowerShell / Scripts**: 透過 PowerShell 腳本封裝為含版本與 Manifest 的 `.zip` 套件
2. 提供產物校驗（如 `Get-FileHash -Algorithm SHA256` 或 `sha256sum`）。
3. 說明解包驗證與本機部署步驟。

### Step 4: 代碼走讀與符號映射 (Code Walkthrough & Symbol Mapping)
1. 盤點核心原始碼檔案清單。
2. 針對核心邏輯建立「符號對應表」：
   - 欄位：檔案路徑、符號名稱（函式/類別/結構體）、存取權限、主要功能、呼叫端與依賴。
3. 擷取關鍵程式碼片段，以逐段註解方式說明控制流、分支條件防禦、錯誤攔截與回傳值設計。

### Step 5: 技術細節與邊界規格化 (Technical Specifications)
1. 整理系統常數、環境變數與配置項表格（預設值、必填與否、說明）。
2. 說明安全設計界線（例如路徑跳脫防護、輸入驗證、認證金鑰保護等）。
3. 記錄錯誤碼（Error Code）或例外處理分類清單。

### Step 6: 格式審查與交付 (Review & Delivery)
1. 確保所有檔案連結使用標準 Markdown 語法（例如 `[file.ext](path/to/file.ext)`）。
2. 確保 Mermaid 圖表在主流 Markdown 預覽器相容。
3. 預設先產出文件草稿或修改工作目錄中的文件檔案，不進行未經許可的 git commit 或 push。

---

## 標準章節範本與撰寫規則

撰寫技術文件時，請遵循以下章節框架展開內容：

```markdown
# [專案/模組名稱] 技術文件

## 1. 使用方法 (Usage Guide)
- 快速入門範例 (Getting Started)
- CLI / API 完整呼叫語法與參數清單
- 典型場景實例 (範例輸入與輸出展示)

## 2. 安裝方法與本地打包 (Installation & Local Packaging)
- 環境需求 (Prerequisites)
- 本地打包建置流程 (Local Packaging Step-by-Step)
  - 打包指令 (Build / Package Command)
  - 打包產物規格與目錄結構 (Artifacts & Output Structure)
  - 產物質量與雜湊校驗 (Integrity & Checksum Verification)
- 本地安裝與部署 (Local Installation & Setup)

## 3. 技術細節 (Technical Details)
- 設定參數與環境變數表 (Configuration & Environment Variables)
- 核心演算法與資料結構 (Data Structures & Core Algorithms)
- 狀態轉換與生命週期 (State Machine & Lifecycle)
- 錯誤處理與安全保護機制 (Error Handling & Security Boundaries)

## 4. 系統架構 (System Architecture)
- 模組分層圖 (Layered Architecture Diagram - Mermaid)
- 核心呼叫時序圖 (Interaction Sequence Diagram - Mermaid)
- 模組責任矩陣 (Module Responsibility Matrix)

## 5. 代碼對應解釋 (Code Map & Component Deep-Dive)
- 目錄樹與模組映射 (Directory Tree Mapping)
- 核心類別 / 函式符號對照表 (Key Symbols Breakdown)
- 關鍵程式碼逐步解構 (Core Implementation Walkthrough)
```

---

## 隨附工具與腳本

本 skill 隨附以下輔助模板與腳本：

1. **本地打包腳本**：`scripts/package-skill.ps1`
   - 功能：自動將單一或多個 Skill 本地封裝為含 `manifest.json` 與 SHA256 驗證的 `.zip` 封裝包。
2. **技術文件範本**：`templates/TECHNICAL_DOCUMENTATION_TEMPLATE.md`
   - 功能：提供現成開箱即用的五大章節 Markdown 模板。
3. **專案盤點腳本**：`scripts/scaffold-doc.ps1`
   - 功能：掃描當前專案目錄結構、檔案類型、Git 狀態，自動生成初稿骨架。
