# skill-guide

> 一個 prompt 驅動的 Claude Code 技能導覽員 -- 掃描你已安裝的 skills，用你的語言解釋給你聽。

**狀態：MVP** -- 已用 10 個 skills + 15 個 commands 測試。核心功能可用。請見[已知限制](#已知限制)。

[English](README.md)

---

## 解決什麼問題？

GitHub 上有數十萬個 Claude Code skills，但大多數人裝完之後都撞同一面牆：

- 原始 repo 是英文的，看不懂或不好理解
- README 寫的是「能做什麼」，不是「怎麼用」
- 裝了 10 幾個 skills，不知道從哪裡開始
- 不知道哪些是自動載入的、哪些要手動輸入指令
- 完全不知道這些工具的使用順序

**skill-guide** 是一個「導覽員」-- 掃描你已安裝的所有 skills，然後用你的語言告訴你每一個工具怎麼用。

## 運作原理

skill-guide **不是傳統程式**。它由兩個 markdown 檔案組成，告訴 Claude 該怎麼表現：

| 檔案 | 類型 | 作用 |
|------|------|------|
| `SKILL.md` | Skill（自動載入） | 背景知識 -- 當你問到相關問題時，Claude 會自動理解如何導覽 |
| `commands/guide.md` | Slash Command（手動觸發） | `/guide` 指令 -- 包含掃描邏輯和輸出格式 |

這意味著：輸出品質取決於 Claude 讀取你的 skill 檔案、理解其內容、並生成有用解釋的能力。實際使用效果不錯，但它是啟發式的，不是確定性的。請見[已知限制](#已知限制)。

### Skills 和 Commands 的差別

這是很多人搞混的地方，skill-guide 會幫你解釋：

- **Skills**（`.claude/skills/*/SKILL.md`）= 背景知識。Claude 偵測到相關情境時會自動載入，你什麼都不用做。
- **Commands**（`.claude/commands/*.md`）= 動作指令。你必須輸入 `/指令名` 才會執行。

## 功能一覽

| 指令 | 做什麼 |
|------|--------|
| `/guide` | 掃描所有已安裝的 skills 和指令，分類列出並推薦使用順序 |
| `/guide <名稱>` | 深入解釋某個特定 skill -- 用白話說明它做什麼、怎麼用、什麼時候該用 |
| `/guide <你想做的事>` | 描述你的目標，取得一份使用你已安裝 skills 的步驟計劃 |
| `/guide --check` | 盡力偵測依賴 -- 從 skill 內容中抽取工具/API 名稱，檢查系統是否已安裝 |
| `/guide --diff <repo>` | 比較你和某個 GitHub repo 的差異。適用於使用標準目錄結構的 skill 套件 |

## 快速安裝

### 方法一：一行搞定

```bash
git clone https://github.com/VV1NN/skill-guide.git && cd skill-guide && ./install.sh
```

### 方法二：手動安裝

```bash
git clone https://github.com/VV1NN/skill-guide.git

mkdir -p ~/.claude/skills/skill-guide
cp skill-guide/SKILL.md ~/.claude/skills/skill-guide/SKILL.md
cp skill-guide/commands/guide.md ~/.claude/commands/guide.md
```

### 確認安裝成功

打開 Claude Code，輸入：

```
/guide
```

你應該會看到所有已安裝 skills 的分類導覽。

## 使用範例

### 全覽模式 -- 「我有哪些工具？」

```
/guide
```

回傳以 Skill 為中心的技能地圖 -- 每個 skill 下面列出相關的指令：

```
10 個 Skills（自動載入）| 15 個 Commands（輸入 /指令名 觸發）

### bug-bounty [SKILL]
完整漏洞挖掘知識庫。

相關指令：
  /scope target.com    -- 確認目標範圍
  /hunt target.com     -- 主動找漏洞
  /chain               -- 串接漏洞

建議流程：/scope -> /hunt -> /chain

### web2-recon [SKILL]
偵察方法論。

相關指令：
  /recon target.com    -- 一鍵跑完整偵察
  /surface target.com  -- 排序攻擊面

建議流程：/recon -> /surface

### General / Utilities
  /guide               -- 技能導覽（就是這個）
  /autopilot target.com -- 全自動一條龍
  ...
```

### 深入解說 -- 「這個怎麼用？」

```
/guide hunt
```

用白話解釋這個工具：

```
## /hunt -- 漏洞獵人

白話說明：主動在目標網站上搜尋安全漏洞。

什麼時候用：
- 你已經跑完偵察，手上有一份端點清單
- 你想針對特定漏洞類型（SSRF、IDOR 等）進行測試

怎麼用：
  /hunt target.com
  /hunt target.com --vuln-class idor

前一步應該做：/recon、/surface
下一步應該做：/validate、/report
```

### 推薦模式 -- 「我想做某件事」

```
/guide 我想找網站的 IDOR 漏洞
```

根據你的目標，用你已安裝的工具規劃步驟：

```
目標：在目標網站上尋找 IDOR 漏洞

第 1 步：/scope target.com                       -- 確認目標在範圍內
第 2 步：/recon target.com                        -- 掃描所有端點
第 3 步：/hunt target.com --vuln-class idor       -- 開始找 IDOR
第 4 步：/validate                                -- 驗證發現是否真實
第 5 步：/report                                  -- 生成提交報告

你不需要用到的：web3-audit、meme-coin-audit、token-scan
```

### 環境檢查 -- 「我準備好了嗎？」

```
/guide --check
```

盡力掃描你的 skills 需要哪些工具和 API：

```
## 環境健康檢查

| 工具       | 狀態          | 哪些 skill 需要      |
|------------|---------------|-----------------------|
| subfinder  | OK (v2.6.3)   | web2-recon, /recon    |
| nuclei     | 缺少          | web2-recon, /recon    |

### 修復方式
- nuclei: `go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest`
```

> 注意：依賴偵測是啟發式的 -- 它從 skill 內容中抽取工具名稱。可能會遺漏未明確提及的依賴，或標記非必要的工具。

### 差異比較 -- 「我還缺什麼？」

```
/guide --diff user/awesome-bb-skills
```

比較你的 skills 和 GitHub repo 的差異：

```
| Skill        | 套件中有 | 你有安裝 | 狀態   |
|--------------|---------|---------|--------|
| bug-bounty   | 有      | 有      | OK     |
| api-testing  | 有      | 沒有    | 缺少   |
```

> 注意：Diff 適用於使用標準 `skills/*/SKILL.md` 和 `commands/*.md` 目錄結構的 repo。非標準結構可能無法完全偵測。

## 測試紀錄

此 skill 已在以下環境中測試：

- **10 個 skills**：bb-methodology、bug-bounty、meme-coin-audit、report-writing、security-arsenal、triage-validation、web2-recon、web2-vuln-classes、web3-audit、skill-guide
- **15 個 slash commands**：autopilot、chain、guide、hunt、intel、recon、remember、report、resume、scope、surface、token-scan、triage、validate、web3-audit
- **Shell**：zsh（macOS 預設）和 bash
- **5 種模式全部測試通過**：全覽、深入解說、推薦、--check、--diff

### 測試中發現並修復的 Bug

| Bug | 原因 | 修復方式 |
|-----|------|---------|
| `${!var}` env var 檢查在 macOS 失敗 | zsh 不支援 bash indirect expansion | 包在 `bash -c` 中執行 |
| Glob 無匹配時報錯 | zsh 將無匹配視為錯誤（bash 不會） | 所有掃描都包在 `bash -c` 中 |

## 使用條件

- Claude Code（CLI、桌面應用、或 IDE 擴充）
- Skills 和 commands 需要有 frontmatter（`name:` 和/或 `description:` 欄位）
- `--diff` 模式需要 `git` 來 clone 遠端 repo
- `--check` 模式需要 `bash`（用於 env var 偵測）

## 已知限制

- **Prompt 驅動，非確定性**：輸出品質取決於 Claude 對你的 skill 檔案的理解。結果是盡力而為的，不同 session 可能略有差異。
- **依賴偵測是啟發式的**：`--check` 從 skill 內容中抽取工具名稱。無法偵測未明確提及的依賴，也可能將非必要工具標記為必要。
- **Diff 需要標準目錄結構**：`--diff` 搜尋 `skills/*/SKILL.md` 和 `commands/*.md`。非標準結構的 repo 可能無法完全掃描。
- **需要 Frontmatter**：沒有 `name:` 或 `description:` 的 skills 會以不完整的資訊顯示。
- **無快取**：每次 `/guide` 都重新掃描檔案系統。這是設計決策（保證資料新鮮），但代表不會有跨 session 的持久狀態。
- **Plugin marketplace skills**：掃描 `~/.claude/plugins/` 路徑有支援，但測試不如使用者層級 skills 充分。

## 相容性

- 適用於任何使用標準 SKILL.md 格式的 Claude Code skills
- 掃描使用者層級（`~/.claude/`）和專案層級（`.claude/`）的 skills
- 相容 plugin marketplace 的 skills（盡力支援）
- Shell 相容：已在 zsh（macOS 預設）和 bash 上測試
- 零依賴 -- 就是兩個 markdown 檔案

## 解除安裝

```bash
rm -rf ~/.claude/skills/skill-guide
rm ~/.claude/commands/guide.md
```

## 參與貢獻

歡迎貢獻！以下是一些方向：

- **用你的 skills 測試** -- 回報 guide 在不同 skill 組合下的表現
- **邊界情況** -- 沒有 frontmatter 的 skills、不尋常的目錄結構
- **截圖** -- 不同語言的真實輸出範例
- **翻譯** -- 新增其他語言的 README

## 授權

MIT
