# Prompt 全紀錄

## 說明

這份檔案逐字記錄了本專案開發過程中，**我（人類）對 AI 下的每一則 prompt 原文**。

它存在的目的，是呈現「人如何驅動 AI 完成一個專案」的完整軌跡：從最初的需求拷問、架構決策，到實作與驗收。讀者可以從中看見每個階段我丟出什麼指令、為什麼丟、以及 AI 因此產出了什麼。

規則：

- 逐字照抄，不摘要、不改寫、不修飾用字（含錯字與口語）。
- 每回合開始工作**之前**先寫入，確保不漏記。
- 只追加，絕不覆寫先前內容。

---

### #0 · 2026-08-25 00:07

**我下的 prompt**

> Follow instructions in #prompt:SKILL.md（grill-with-docs）
>
> ## 背景
> 專案需求在 `docs/require.pdf`，請先完整讀過。這是一個從零開始的 Flutter 專案，目前 repo 除了需求文件之外沒有任何程式碼。
>
> ## 你的角色
> 資深架構師。對我進行嚴厲拷問（Grilling），找出需求的邊界狀況、需求與 API 實際能力之間的衝突，以及那些會在實作後期才爆炸的技術決策。
>
> 規則：
> - **事實是你的工作，不是我的。** 需要確認 API 行為、回傳格式、套件版本、本機工具鏈時，自己去查或派 subagent，不要拿這些來問我。查到的事實要附來源。
> - **決策是我的工作。** 每一輪把當前 frontier 的問題一次問完，每題編號、附選項與你的推薦答案，然後停下來等我回答。
> - 我回答後重算 frontier，進入下一輪。frontier 清空才算結束。
> - 只根據需求文件與 API 的真實行為推導，不要套用任何預設的架構樣板。每個推薦都要說得出「為什麼在這個專案成立」。
> - 結束前不要寫任何實作程式碼。
>
> ## 記錄一：Prompt 全紀錄
> 把**我對你下的每一則 prompt 原文**記錄在 `docs/PROMPT_LOG.md`。這份檔案的讀者是面試官，用途是呈現我如何驅動 AI 完成專案。
>
> - **在你開始處理該回合的工作「之前」就先寫入**，確保不會漏記。
> - **逐字照抄，不要摘要、不要改寫、不要修飾我的用字**（含錯字與口語）。
> - 包含這則初始 prompt，編號為 `#0`。
> - 檔案不存在就建立；已存在就往後追加，絕不覆寫先前內容。
>
> 每則格式：
>
> ```markdown
> ### #<n> · <YYYY-MM-DD HH:mm>
>
> **我下的 prompt**
> > <原文逐字照抄>
>
> **當下意圖（AI 觀察）**
> <一句話：這則 prompt 想達成什麼、把專案推進到哪個階段>
>
> **產出**
> <這一回合實際做了什麼、動到哪些檔案>
> ```
>
> 檔案開頭放一段 `## 說明`，簡述這份紀錄是什麼、為何存在。
>
> ## 記錄二：拷問過程
> 把拷問過程記錄在 `docs/GRILL_LOG.md`。
>
> - **每一輪我回答完就立刻寫入**，不要等到最後才補。
> - 檔案不存在就建立；已存在就往後追加，不要覆寫先前輪次。
>
> 每題格式：
>
> ```markdown
> ### Q<n> — <問題標題>
>
> **問題**
> <問題本體，含各選項 (a)/(b)/(c) 與各自的取捨>
>
> **已查證的事實**
> <為了問這題而查到的 API／環境事實，附來源>
>
> **AI 推薦**
> <推薦哪個選項，一句話理由>
>
> **我的決定**
> <我實際選的選項>
>
> **我的理由**
> <我給的理由；我沒明講時，用一句話覆述你從我的回答推得的理由，並標記「(推論)」讓我校對>
>
> **影響**
> <這個決定關掉了哪些選項、開啟了哪些後續問題>
> ```
>
> 檔案開頭放一個 `## 決策摘要` 表格（Q 編號 / 主題 / 最終決定），每輪同步更新。
>
> ## 開始
> 先把這則 prompt 以 `#0` 寫進 `docs/PROMPT_LOG.md`，接著做一輪事實查證，然後直接開始第一輪拷問。

**當下意圖（AI 觀察）**
在寫任何程式碼之前，先用「事實查證 + 嚴厲拷問」把需求文件裡的模糊地帶與技術衝突逼出來，並建立雙軌記錄機制（prompt 紀錄 + 決策紀錄），把專案推進到「架構決策已定案、可進入實作」的階段。

**產出**
建立 `docs/PROMPT_LOG.md`；用 pypdf 抽出 `docs/require.pdf` 全文與內嵌 UI 示意圖；查證中央氣象署 F-C0032-001 官方 OpenAPI spec（endpoint、必填 `Authorization` query param、22 個 `locationName` enum 全用「臺」、無 response schema）、實測未帶授權碼回 HTTP 401 純文字、確認 pjchender 教學的舊網域 `opendata.cwb.gov.tw` DNS 已失效；查證本機工具鏈（Flutter 3.47.0 / Dart 3.13.0 / Xcode 26.6）與套件版本（flutter_riverpod 3.4.2、dio 5.11.0、freezed 4.0.0 等）；建立 `docs/GRILL_LOG.md` 並提出第 1 輪 7 題拷問。

---

### #1 · 2026-08-25 00:45

**我下的 prompt**

> Q1: d 因為使用上更人性化
> Q2: 面試官要求要使用中央氣象局API，所以他們自己應該也知道怎麼申請KEY
> token具體做法：
> 1. 程式碼只有一個讀取點：`const String.fromEnvironment('WEATHER_API_TOKEN')`，包在 `AppConfig` 裡。`main()` 第一行檢查是否為空，空的話直接丟 `StateError` 並附上 README 指引——設定錯誤要在啟動時爆，不能變成看不懂的 401。
> 2. 本機：`dart_defines/dev.json`（gitignored，放真 token）+ `dart_defines/dev.example.json`（進版控，值留空）。執行用 `flutter run --dart-define-from-file=dart_defines/dev.json`。`.vscode/launch.json` 進版控，它只指向那個被忽略的檔案，本身不含機密。
> 3. CI：token 已存在 GitHub Repository secrets，名稱 `WEATHER_API_TOKEN`。workflow 用 `--dart-define=WEATHER_API_TOKEN=${{ secrets.WEATHER_API_TOKEN }}`。單元測試打 mock、完全不需要真 token，只有真的要打 API 的 job 才傳；secret 對 fork PR 不可見，那種情況該 job 要 skip 而不是 fail。
> 4. README 給 reviewer 兩條路：(a) 到 CWA 開放資料平臺免費申請一組，附步驟；(b) 使用我在繳交信件中另附的臨時 token。token 不放進 repo。
>
> **我知道且接受的限制：`--dart-define` 的值會被編譯進 binary，反編譯就能撈出來。這個做法防的是「token 進入 git 歷史與 public repo」，不是「使用者拿不到 token」。用戶端 app 沒有真正的機密，根治方法是自架 proxy 後端由伺服器持有金鑰，但這次作業不值得為此加一個後端。**
> Q3: (b) + (ii) 需要更詳細的錯誤狀態
> Q4: b 做好基本天氣分類
> Q5: c 可以順利跑demo比較重要
> Q6: a 用官方的實作就好，因為class不多
> Q7: a + c 確保需求核心功能，加上穩定品質和開發流程

**當下意圖（AI 觀察）**
回答第 1 輪全部 7 題，把「輸入處理、機密管理、錯誤模型、資料呈現、Riverpod 寫法、資料模型、專案範圍」七個地基決策一次釘死；其中 Q2 直接給出完整的 token 管理實作規格與已知限制的自我揭露，把這題從「選項題」升級成「已定案的設計」。

**產出**
將第 1 輪 7 題的問題、事實、決定與影響寫入 `docs/GRILL_LOG.md`；建立 `CONTEXT.md` 記錄已定案的領域詞彙；查證 Wx 天氣代碼表與 Riverpod 3 的 `AsyncValue` 狀態數量；展開第 2 輪拷問。

---

### #2 · 2026-08-25 09:38

**我下的 prompt**

> Q8:a 自定義才可以保持任何需求的彈性
> Q9:c 功能層分模組，依賴底下工具類模組
> Q10:1(b)、2(b)、3(a)、4(a) 符合用戶體驗和需求
> Q11:1(a)、2(b) 六類、3(a) Material Icons、4 不做
> Q12:測 ①–⑤、不做 ⑥；mock 用 (a)；CI 用 (c) 同時build Android / iOS
> Q13:推薦 1(a)、2(b)、3 要連 因為要模擬做需求前就先把規格講好給PM確認
> Q14:b 因為要分配任務給其他RD 需要有issue
> Q15:a 考慮周全

**當下意圖（AI 觀察）**
回答第 2 輪全部 8 題，把狀態建模、目錄結構、互動語意、天氣分類、測試與 CI、交付流程一次定案；其中兩處刻意推翻 AI 建議（CI 加上 iOS build、README 問答題提前到實作前處理），理由都是「要模擬真實開發流程」——把規格與需求釐清放在寫程式之前。

**產出**
將第 2 輪 8 題寫入 `docs/GRILL_LOG.md`；建立 `.gitignore` 與 `dart_defines/dev.example.json` 骨架以執行 Q15(a) 的授權碼實測路徑；產出 README 問答題的訪談問題清單；展開第 3 輪拷問。

---

### #3 · 2026-08-25 10:34

**我下的 prompt**

> Q16 (a) + (ii)
> Q17 weather_forecast、com.allenljf、顯示名稱「36 小時天氣預報」、--platforms=android,ios
> Q18 (b) + (iii)
> Q19 1(b)、2 不引入
> Q20 1(a)、2(b)
> Q21 1(b)、2(b)
>
> README 問答題訪談 都先不要幫我做，因為那要結合我kkday實務經驗，我還沒準備好資料
> dev.json填好了，但是需要幫我想如何不把明碼token推上公開github的解決方案

**當下意圖（AI 觀察）**
回答第 3 輪 6 題把 CI 形態、專案識別、競態與逾時、時間呈現、錯誤文案、issue 拆解全部定案；同時把 README 問答題往後推（素材未備齊），並把「明碼 token 絕不能上公開 GitHub」從單一 gitignore 提升為需要正面設計的獨立問題。

**產出**
將第 3 輪 6 題寫入 `docs/GRILL_LOG.md`；用 gitignored 的 `dart_defines/dev.json` 實測 CWA API（token 全程不進對話），解開 F11 與回應真實結構；提出 token 外洩防護的縱深方案；展開第 4 輪拷問。

---

### #4 · 2026-08-25 11:12

**我下的 prompt**

> token問題我不在意了，就推上去吧，反正是免費的，被打爆我也不用付錢，頂多失效，面試官可以用自己的key替換，但是要在README那邊要有一段說明，如果是公司正式專案，token應該要怎麼保護，有幾種做法，包含token放後端的解法
>
> Q22: token不防護了，原因如上，還是以面試官方便測試為主，我的github也沒外人來看
> Q23: (b) + (i)
> Q24: c
> Q25: a
> Q26: a

**當下意圖（AI 觀察）**
在權衡「reviewer 測試便利性」與「憑證保密」之後，明確接受把免費、無金流的授權碼公開，並要求把這個取捨轉化成 README 中一段「正式專案該如何保護 token（含後端 proxy 解法）」的說明——把弱點主動轉成展示知識深度的位置；同時定案資料模型、失敗歸屬、縣市清單來源與請求粒度。

**產出**
將第 4 輪 5 題寫入 `docs/GRILL_LOG.md`；查證 CWA 使用規範中「異常使用」的實際後果；實測並發現 **API 支援 HTTP header 認證**（推翻先前「只能用 query param」的認定）；展開第 5 輪拷問。

---

### #5 · 2026-08-25 11:00

**我下的 prompt**

> Q27 b
> Q28 c + (i) 保留 fail-fast
> Q29 1(c)、2(b)
> Q30 1(c)、2 加、3(b)
> Q31 1(b)、2(b)

**當下意圖（AI 觀察）**
把最後一批技術決策定案：改用 HTTP header 帶授權碼、以獨立設定檔而非原始碼常數的形式公開 token 並保留啟動期 fail-fast、README 安全章節寫到後端 proxy 層級且誠實揭露本專案取捨、靜態分析採嚴格但不氾濫的規則集、視覺採 seed color 並順手補上深色模式。

**產出**
將第 5 輪 5 題寫入 `docs/GRILL_LOG.md`；查證 `pubspec.lock` 的官方版控建議並修正先前 `.gitignore` 的錯誤；展開第 6 輪（收尾）拷問。

---

### #6 · 2026-08-25 11:09

**我下的 prompt**

> Q32 c
> Q33 a
> Q34 a
> Q35 1(b)、2(b)

**當下意圖（AI 觀察）**
清空 frontier 的最後四題——確立 `dart_defines/` 的檔案分工、鎖定 CI 的 Flutter 版本、把 `pubspec.lock` 納入版控、定義初始與讀取中兩個 Widget 的實際內容；全案以「審閱者拿到的必須是我驗證過的東西」為一致的取捨原則收束。

**產出**
將第 6 輪 4 題寫入 `docs/GRILL_LOG.md`；依 Q32／Q34 修正 `.gitignore` 與 `dart_defines/` 檔案佈局；產出全案決策定案摘要供最後確認。

---

### #7 · 2026-08-25 11:15

**我下的 prompt**

> 1.確認 2.開始建 issue

**當下意圖（AI 觀察）**
確認全案 35 項決策無誤，正式結束拷問階段，授權把需求拆解成 GitHub issue——把「規格已談定」轉換成「任務可分配」，這正是問答題第 2 題（如何把需求分配給其他 RD）要展示的動作本身。

**產出**
建立 6 個領域標籤（`area:setup`／`domain`／`data`／`ui`／`ci`／`docs`）；依 Q21 的中粒度原則與 `CONTEXT.md` 的詞彙，把需求拆成 **13 個** 含驗收條件、前置關係與決策引用的 GitHub issue（#1–#13）。仍未撰寫任何實作程式碼。

---

### #8 · 2026-08-25 11:40

**我下的 prompt**

> 接下來要直接開始實作了嗎，原本matt核心流程應該有以下步驟，該如何下prompt逐一完成
> - `/to-spec`：將訪談和討論的共識自動轉化為結構化的規格文件。
> - `/to-tickets`：把規格拆解成適合 AI 單次任務執行的細小任務卡（Tickets）。
> - `/implement`：驅動測試驅動開發（TDD）並按步驟落實程式碼，最後用 `/code-review` 收尾。

**當下意圖（AI 觀察）**
在動工前先確認整條 AI 開發流程的正確接法，避免跳過規格直接實作；同時要求把每一步該怎麼下指令講清楚。

**產出**
讀取 `to-spec`／`to-tickets`／`implement`／`code-review`／`tdd` 五個 skill 原文；指出我建的 #1–#13 是**水平切分**、違反 `/to-tickets` 的 tracer bullet 規則，並提出「補一張端到端最薄票」而非重切的折衷；產出四個步驟的具體 prompt 範本。

---

### #9 · 2026-08-25 11:52

**我下的 prompt**

> 做 Step 0（把實測 fixture 存進 repo）接下來我要繼續都在此session執行嗎，還是需要到新的session繼續
> to-spec會產生什麼文件，接下來實作都會先讀取規格當作參考嗎
> to-ticket會在github上開票嗎，可以模擬分出去給其他RD嗎
> implement碰到可並行的task會幫我在背景開session執行嗎
> code-review是本地review還是用github copilot開PR之後review
> 先不要動作，先回答我你建議怎麼做

**當下意圖（AI 觀察）**
在授權任何動作之前，先把整條流程的**實際機制**問清楚——session 邊界、產出物形式、GitHub 整合程度、並行能力、review 的落點——避免對工具能力有錯誤預期。

**產出**
逐題以 skill 原文回答；澄清 `/implement` **不具備**背景並行能力、且在「不開 PR、直接 commit main」的前提下並行必然衝突；指出 `/code-review` 是純本地、結果不會留在 GitHub 上，因而浮現兩個新決策 Q36（分配標示方式）與 Q37（review 留痕方式）。

---

### #10 · 2026-08-25 13:03

**我下的 prompt**

> Q36 b
> Q37 b
> 現在動 Step 0

**當下意圖（AI 觀察）**
定案「以 issue body 的『建議承接者 + 依據』取代 assignee 欄位來呈現任務分配」與「code review 報告貼成 issue 留痕」，並授權把實測資料轉為測試資產。

**產出**
將 Q36／Q37 寫入 `docs/GRILL_LOG.md`；把六份實測 API 回應存入 `test/fixtures/cwa/`（全部經授權碼比對掃描確認乾淨）；在 issue #6 補上 fixture 出處說明；在 #1–#13 補上「建議承接者」。

---

### #11 · 2026-08-25 13:10

**我下的 prompt**

> 跑 to-spec

**當下意圖（AI 觀察）**
把七輪拷問累積的 37 項決策與實測事實，收斂成一份結構化、可被 `/implement` 與 `/code-review` 引用的正式規格——讓「已達成的共識」從對話紀錄變成交付物的一部分。

**產出**
依 `/to-spec` 流程先攤開並確認五個測試接縫，再產出規格並發佈為 GitHub issue #14，含 Problem Statement／Solution／42 條 User Stories／Implementation Decisions（每條標注來源 Q 編號）／Testing Decisions／Out of Scope／Further Notes（三份文件的分工、已被推翻的早期決定、票的切法說明）。依 Q21 使用 `area:docs` 標籤而非 skill 預設的 triage 標籤。

---

### #12 · 2026-08-25 13:14

**我下的 prompt**

> **Step 2**：建 tracer bullet

**當下意圖（AI 觀察）**
補上水平切票所缺的垂直驗證：用一張「端到端最薄一條線」的票，在寫任何抽象之前先證明上游契約與整條資料流是通的，並把整組票的相依關係從純文字升級為 GitHub 原生的 blocking 邊。

**產出**
建立 issue #15（tracer bullet，明訂其交付物是**知識而非可留存的程式碼**、不要求測試、但必須留言記錄實測與 fixture 的落差）；以 `gh api .../dependencies/blocked_by` 建立 17 條原生相依邊，形成可查詢的 frontier。

---

### #13 · 2026-08-25 13:16

**我下的 prompt**

> 修進 `issue-tracker.md`

**當下意圖（AI 觀察）**
把建相依圖時實際踩到的文件錯誤修回文件本身，避免下一個 session 重複撞同一個坑——讓「踩到的坑」變成資產而不是重複成本。

**產出**
修正 `docs/agents/issue-tracker.md` 的 Blocking 與 Frontier query 兩段：釐清 `issue_dependencies_summary` 是 **REST API** 的欄位名，而 `gh issue list --json` 用的是 **`blockedBy`**（物件形式 `{nodes, totalCount}`），並附上可直接執行的正確指令。修正後實測指令可跑、且確認舊寫法確實回報 `Unknown JSON field`。

---

> **紀錄斷點**：#13 之後到 #14 之間是 #1–#13 的逐票實作 sessions（13:20–23:00 左右）。那些 session 用的都是 `docs/agents/delivery.md` 裡那段交棒 prompt 的填空版，當時沒有逐則存檔，事後也無法逐字還原——依本檔「不改寫、不修飾」的規則，寧可留一個標明的缺口，也不補寫回憶版本。

---

### #14 · 2026-08-25 23:10

**我下的 prompt**

> 規格在 #14，決策脈絡在 docs/GRILL_LOG.md，詞彙在 CONTEXT.md。先讀這三份。
>
> /code-review b8089bd
>
> - 這是 #16：整份交付的一次性 review，先把 #16 讀完，固定點與兩軸的來源都寫在票裡
> - Standards 軸沒有 CODING_STANDARDS.md，也不要補寫一份（Q7）；標準只有
>   Fowler smell baseline、analysis_options.yaml、CONTEXT.md 的詞彙一致性
> - Spec 軸的規格是 #14，特別查 Out of Scope 有沒有被偷偷實作
> - 凡是 flutter analyze 已經把關的，不必再列
>
> 報告出來之後：
>
> 1. 完整貼成 #16 的 comment，兩軸分開，不合併、不跨軸重排
> 2. 逐項標上處置：已修（附 sha）／不修（附撞到的 Q 編號）／待辦（開票附編號）
> 3. 「不修」是正當結論——這個 repo 有 37 項刻意的取捨，把它們當缺陷改掉是最糟的結果
> 4. 修完跑 flutter analyze 與 flutter test，全綠才收
> 5. 順帶把 #16 補進 README「票的執行順序與相依關係」那張 mermaid 圖
> 6. 最後依 docs/agents/delivery.md 交付：commit、push、關 #16

**當下意圖（AI 觀察）**
把「審查」與「照單全改」分開。Prompt 裡份量最重的是第 3 點：先替 AI 設好「不修是正當結論」這個出口，否則一個被要求找問題的 agent 會傾向把 37 項刻意的取捨當成缺陷逐一「修好」，而那正是這個 repo 最禁不起的一種破壞。同時把兩軸的標準來源與範圍先釘死（不補寫 CODING_STANDARDS、不重列 lint 已把關的項目），避免報告被無效發現稀釋。

**產出**
兩軸平行 sub-agent 各跑一次，兩份都回報「幾乎無發現」；逐檔複驗後最終得到 Standards 5 項、Spec 3 項，其中唯一的 hard violation 是 README 首段殘留被 F47 推翻的「12 小時」（`71924bc` 已修）。完整報告貼為 #16 的 comment，兩軸分開；七項「不修」各自附上撞到的 Q 編號；待辦 0 項。順帶把 #16 補進 README 的相依圖與執行順序。收尾時 `flutter analyze` No issues found、`flutter test` 86 tests all passed，push 後關閉 #16。

過程中另外實測出 F49：`flutter analyze` 會自動把 `analysis_options.yaml` 的平台排除行寫回去，所以那四行不是贅字而是工具鏈托管的區段。

---

### #15 · 2026-08-25 23:36

**我下的 prompt**

> 幫我把code review結果更新在文件上

**當下意圖（AI 觀察）**
Review 的結果當時只存在於 #16 這一則 issue comment 裡，而 repo 的三份文件（拷問紀錄、規格、票）各有分工。這則 prompt 要的是把 review 期間新得到的**事實與限制**，按 `docs/agents/delivery.md`「當現實推翻決定」那條規則落回各自該去的地方，而不是把報告全文再貼一份——後者正是 #14 Further Notes 警告過的互相抄寫。

**產出**
`docs/GRILL_LOG.md`：Q30 新增「實作期修正二」記下 F49（含決定不變的結論）、全案矛盾稽核表補第 10、11 兩列、Q37 補上「#16 執行完畢」的實作期補記（三件事：唯一的 hard violation 出在敘述而非程式碼、七項不修各自撞到哪個編號、平行 sub-agent 首輪雙雙看漏）。`analysis_options.yaml`：`exclude:` 上方加一行註解說明刪了會被寫回（實測註解本身會被保留）。本檔補上 #14、#15 兩則，並標明 #13 之後的逐票實作 sessions 是已知缺口。
