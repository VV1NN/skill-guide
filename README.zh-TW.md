# skill-guide

**你的 Claude Code 技能說明書 -- 讓你裝了就會用。**

[English](README.md)

---

## 解決什麼問題？

現在 GitHub 上有數十萬個 Claude Code skills，但大多數人裝完之後都會遇到同樣的問題：

- 原始 repo 是英文的，看不懂或不好理解
- README 寫的是「能做什麼」，不是「怎麼用」
- 裝了 10 幾個 skills，不知道從哪裡開始
- 不知道哪些是自動載入的、哪些要手動輸入指令
- 完全不知道這些工具的使用順序

**skill-guide** 就是來解決這件事的。它是一個「導覽員」-- 掃描你已安裝的所有 skills，然後用你的語言告訴你每一個工具怎麼用。

## 功能一覽

| 指令 | 做什麼 |
|------|--------|
| `/guide` | 掃描所有已安裝的 skills 和指令，分類列出並推薦使用順序 |
| `/guide <名稱>` | 深入解釋某個特定 skill -- 用白話說明它做什麼、怎麼用、什麼時候該用 |
| `/guide <你想做的事>` | 描述你的目標，取得一份使用你已安裝 skills 的步驟計劃 |

### 核心特色

- **多語言** -- 你用什麼語言問，它就用什麼語言回答
- **動態掃描** -- 即時讀取你實際安裝的 skills，不是寫死的清單
- **流程導向** -- 不只列功能，還告訴你先做什麼、再做什麼
- **新手友善** -- 用白話和比喻來解釋，不丟專有名詞給你

## 快速安裝

### 方法一：一行搞定

```bash
git clone https://github.com/vv1n/skill-guide.git && cd skill-guide && ./install.sh
```

### 方法二：手動安裝

```bash
# 下載
git clone https://github.com/vv1n/skill-guide.git

# 複製 skill
mkdir -p ~/.claude/skills/skill-guide
cp skill-guide/SKILL.md ~/.claude/skills/skill-guide/SKILL.md

# 複製指令
cp skill-guide/commands/guide.md ~/.claude/commands/guide.md
```

### 確認安裝成功

打開 Claude Code，輸入：

```
/guide
```

你應該會看到所有已安裝 skills 的完整導覽。

## 使用範例

### 全覽模式 -- 「我有哪些工具？」

```
/guide
```

會回傳分類整理過的技能地圖：

```
[準備階段] --> [偵察階段] --> [狩獵階段] --> [驗證階段] --> [產出階段]

Skills:  10 個已安裝（背景知識，自動載入）
Commands: 15 個可用（輸入 /指令名 觸發）

| 工具 | 做什麼 | 什麼時候用 |
|------|--------|-----------|
| /recon | 全面偵察目標 | 開始狩獵前 |
| /hunt  | 主動找漏洞   | 偵察完成後 |
| ...    | ...          | ...       |
```

### 深入解說 -- 「這個怎麼用？」

```
/guide hunt
```

會用白話解釋這個工具：

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
...
```

### 推薦模式 -- 「我想做某件事」

```
/guide 我想找網站的 IDOR 漏洞
```

會根據你的目標，用你已安裝的工具規劃步驟：

```
目標：在目標網站上尋找 IDOR 漏洞

第 1 步：/scope target.com          -- 確認目標在範圍內
第 2 步：/recon target.com          -- 掃描所有端點
第 3 步：/hunt target.com --vuln-class idor  -- 開始找 IDOR
第 4 步：/validate                  -- 驗證發現是否真實
第 5 步：/report                    -- 生成提交報告

你不需要用到的：web3-audit、meme-coin-audit、token-scan
```

## 運作原理

skill-guide 只有兩個檔案：

| 檔案 | 類型 | 作用 |
|------|------|------|
| `SKILL.md` | Skill（自動載入） | 背景知識 -- 當你問到相關問題時，Claude 會自動理解如何導覽 |
| `commands/guide.md` | Slash Command（手動觸發） | `/guide` 指令 -- 需要你輸入 `/guide` 才會執行 |

### Skills 和 Commands 的差別

這是很多人搞混的地方，skill-guide 會幫你解釋：

- **Skills**（`.claude/skills/*/SKILL.md`）= 背景知識。Claude 偵測到相關情境時會自動載入，你什麼都不用做。
- **Commands**（`.claude/commands/*.md`）= 動作指令。你必須輸入 `/指令名` 才會執行。

## 相容性

- 適用於任何來源的 Claude Code skills
- 掃描使用者層級（`~/.claude/`）和專案層級（`.claude/`）的 skills
- 相容 plugin marketplace 的 skills
- 零依賴 -- 就是兩個 markdown 檔案

## 解除安裝

```bash
rm -rf ~/.claude/skills/skill-guide
rm ~/.claude/commands/guide.md
```

## 參與貢獻

歡迎貢獻！以下是一些方向：

- **改善掃描邏輯** -- 處理 skill 偵測的邊界情況
- **新增範例輸出** -- 不同語言的 guide 輸出截圖或錄影
- **測試更多 skill 組合** -- 回報 guide 在不同 skill 集合下的表現
- **翻譯** -- 新增其他語言的 README

## 授權

MIT
