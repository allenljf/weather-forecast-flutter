# 拷問紀錄（Grill Log）

這份檔案記錄本專案在動工之前，AI（資深架構師角色）對我進行的嚴厲拷問過程：每一個被逼出來的邊界狀況、每一個「需求 vs API 實際能力」的衝突，以及我對每個技術決策所做的選擇與理由。

## 決策摘要

| Q | 主題 | 最終決定 |
| --- | --- | --- |
| Q1 | 使用者輸入 vs API 的 22 個固定縣市 | **(d)** 自由輸入 + 本地正規化白名單 + 即時自動完成建議 |
| Q2 | API 授權碼在公開 repo 的處理方式 | **(b)+(d)** `--dart-define` 單一讀取點 + 啟動時 fail-fast + `dart_defines/*.json`（真檔 gitignored）+ CI secret + README 兩條路 |
| Q3 | 錯誤分類法與四種狀態的邊界 | **(b) + (ii)** sealed 失敗型別窮舉六種案例、維持四個 Widget、嚴格解析 |
| Q4 | 顯示區塊要呈現多少資料 | **(b)** 三個時段全列，並額外做基本天氣分類 |
| Q5 | Riverpod 3.x 與是否採用 codegen | **(c)** codegen + 產生檔一併 commit |
| Q6 | 資料模型是否用 freezed | **(a)** 不用 freezed，用 `json_serializable` + Dart 原生 sealed class |
| Q7 | 功能範圍紀律 | **(a)+(c)** 嚴格只做需求，另加測試與 CI，不加產品功能 |
| Q8 | 四個 Widget 的狀態建模 | **(a)** 自訂 sealed 四態，不使用 `AsyncValue` |
| Q9 | 檔案與目錄切法 | **(c)** 依技術層切：`core` / `domain` / `data` / `presentation` |
| Q10 | 自動完成的互動語意 | **1(b)** contains 比對、**2(b)** 至少 1 字才建議、**3(a)** 選取只填入仍需按確認、**4(a)** 空輸入時確認鈕 disabled |
| Q11 | 天氣分類的依據、粒度、圖示 | **1(a)** 用官方分類代碼、**2(b)** 六類、**3(a)** Material Icons、**4** 不做日夜變體 |
| Q12 | 測試與 CI 範圍 | 測 ①–⑤ 不做 golden；mock 用 **(a)**；CI 用 **(c)** 且 **Android 與 iOS 都要 build** |
| Q13 | README 問答題的處理 | **1(a)** 現在就處理、**2(b)** AI 先出訪談清單、**3** README 連到兩份紀錄 |
| Q14 | 交付流程 | **(b)** 開 issues 追蹤 + 直接 commit 到 `main`，不開 PR |
| Q15 | 如何解開 F11 | **(a)** 由我建立 gitignored 的 token 檔，AI 讀檔實測、不接觸 token 內容 |
| Q16 | CI 是否需要 secret、iOS job 形式 | **(a)** CI 完全不碰 secret + **(ii)** `flutter build ios --simulator` |
| Q17 | 專案識別 | `weather_forecast`／`com.allenljf`／顯示名稱「36 小時天氣預報」／`--platforms=android,ios` |
| Q18 | 競態與逾時 | **(b)** request id 丟棄過期回應 + **(iii)** 逾時 15s／15s |
| Q19 | 時間呈現 | **1(b)** 今日／明日／後天 + 時間、**2** 不引入 `intl` |
| Q20 | 錯誤文案與技術細節 | **1(a)** 每種失敗各自文案與動作、**2(b)** 技術細節收在可展開區塊 |
| Q21 | issue 粒度與標籤 | **1(b)** 中粒度 8–12 個、**2(b)** 自訂領域標籤，不用 triage 標籤 |
| Q22 | token 外洩防護層級 | **不防護**：授權碼公開推上 repo，改以 README 說明取捨與正式做法 |
| Q23 | 資料模型與嚴格解析程度 | **(b)** 收斂成領域模型 + **(i)** 五要素缺任一即 `malformedResponse` |
| Q24 | 白名單命中但 API 回空陣列的歸屬 | **(c)** 獨立一種失敗「上游查無此縣市」 |
| Q25 | 22 縣市清單來源 | **(a)** 寫死為 Dart 常數，來源為官方 spec enum |
| Q26 | 一次抓一個縣市或全部 | **(a)** 每次查詢帶 `locationName` |
| Q27 | 認證方式 | **(b)** HTTP header（原始 token，**無 `Bearer` 前綴**） |
| Q28 | token 以什麼形式進 repo | **(c)** commit `dart_defines/reviewer.json` + **(i)** 保留啟動期 fail-fast |
| Q29 | README 安全說明的深度與誠實度 | **1(c)** 寫到後端 proxy 層級、**2(b)** 明寫本專案取捨 |
| Q30 | 靜態分析嚴格度 | **1(c)** `flutter_lints` + 手選規則 + `strict-casts`、**2** 加 `riverpod_lint`（實作期修正：改用 analyzer plugin、移除 `custom_lint`，並**接受 CI 不把關 riverpod 規則**）、**3(b)** 產生覆蓋率報告但不卡門檻 |
| Q31 | 主題色與深色模式 | **1(b)** `ColorScheme.fromSeed`、**2(b)** 同時提供 `darkTheme` 跟隨系統 |
| Q32 | `dart_defines/` 檔案佈局 | **(c)** 留 `reviewer.json`（committed）+ `dev.example.json`（committed），刪除 `dev.json` |
| Q33 | CI 的 Flutter 版本 | **(a)** 鎖定 3.47.0 |
| Q34 | `pubspec.lock` 是否進版控 | **(a)** commit（修正 AI 先前寫錯的 `.gitignore`） |
| Q35 | 初始／讀取中 Widget 的內容 | **1(b)** 圖示 + 引導文字、**2(b)** spinner + 「查詢中…」文字 |
| Q36 | 任務分配如何呈現 | **(b)** issue body 寫「建議承接者 + 依據」，不用 assignee 欄位 |
| Q37 | code review 結果如何留痕 | **(b)** 報告貼成 GitHub issue，含「發現什麼 → 怎麼修」 |

---

## 第 1 輪

### 共通事實（本輪查證所得）

| # | 事實 | 來源 |
| --- | --- | --- |
| F1 | Endpoint 為 `https://opendata.cwa.gov.tw/api/v1/rest/datastore/F-C0032-001`（spec 的 `basePath` 為 `/api`，`schemes` 為 `https`/`http`） | 官方 OpenAPI spec <https://opendata.cwa.gov.tw/apidoc/v1> |
| F2 | `Authorization` 是 **required 的 query parameter**，不是 HTTP header | 同上 |
| F3 | 未帶授權碼時回應為 **HTTP 401**，body 是**純文字** `401 Forbidden: Authorization key is not correct.`，`Content-Type: application/octet-stream`——**不是 JSON** | 實測 `curl -s -w '%{http_code}'`（2026-08-25） |
| F4 | `locationName` 的 enum 是**恰好 22 個縣市**，且**全部使用「臺」**：宜蘭縣、花蓮縣、臺東縣、澎湖縣、金門縣、連江縣、臺北市、新北市、桃園市、臺中市、臺南市、高雄市、基隆市、新竹縣、新竹市、苗栗縣、彰化縣、南投縣、雲林縣、嘉義縣、嘉義市、屏東縣。**沒有鄉鎮區**，型別為 `array`（可重複帶） | 官方 OpenAPI spec <https://opendata.cwa.gov.tw/apidoc/v1> |
| F5 | `elementName` 的 enum 為 `Wx`、`PoP`、`CI`、`MinT`、`MaxT`；另有 `format`(JSON/XML)、`sort`(time)、`limit`、`offset`、`startTime`、`timeFrom`、`timeTo` | 同上 |
| F6 | 官方 spec 只宣告 `200 OK`，且**完全沒有定義 response schema**（`responses.200` 只有 `description: OK`）。回傳結構在官方文件中屬於未定義狀態 | 同上 |
| F7 | 需求文件連結的 pjchender 教學使用舊網域 `opendata.cwb.gov.tw`，該網域**目前 DNS 已無法解析**（`curl: (6) Could not resolve host`）——照抄教學會直接失敗 | 實測（2026-08-25）；教學出處 <https://pjchender.dev/react-bootcamp/docs/book/ch5/5-1/> |
| F8 | 本機工具鏈：Flutter **3.47.0** stable、Dart **3.13.0**、Xcode **26.6**；已連線裝置：Android emulator（API 37）、iOS 實機（26.6.1）、macOS、Chrome | 實測 `flutter --version` / `flutter devices` |
| F9 | 套件現況：`flutter_riverpod` **3.4.2**、`riverpod_generator` **4.0.8**、`riverpod_annotation` **4.0.6**、`dio` **5.11.0**、`freezed` **4.0.0**、`json_serializable` **6.14.1**、`build_runner` **2.16.0** | pub.dev（2026-08-25） |
| F10 | 需求 PDF 內附的 UI 示意圖明確畫出：上方「請輸入城市名稱」輸入框 + 「確認」按鈕，下方一個「顯示區塊」；顯示區塊有四種狀態：未輸入 → Loading → 成功 / 失敗 | `docs/require.pdf` 內嵌圖 |
| F11 | **未查證**：帶合法授權碼但 `locationName` 不在 enum 內時的實際行為（200 + 空 `location[]`？還是 4xx？）。此事實需要一組有效授權碼才能實測 | — |

---

### Q1 — 使用者自由輸入 vs API 只吃 22 個寫死的縣市

**問題**

需求說「用戶輸入 locationName（城市名字）」而且要「處理用戶輸入的搜索條件無效」，但 API 只接受 22 個固定字串，而且是「臺北市」不是「台北市」。使用者輸入「台北市」「台北」「Taipei」全部會失敗，必須決定失敗發生在哪一層。

- **(a)** 純自由文字，完全交給 API 判定：最少程式碼，但會把使用者的打字習慣誤判成「查無資料」。
- **(b)** 自由文字 + 本地正規化（去空白、`台→臺`、「台北」補成「臺北市」）+ 本地 22 縣市白名單；沒命中直接進 error state。代價是 repo 內有一份可能與 API 脫鉤的清單，好處是「無效」這個判定終於有地方成立。
- **(c)** 改成下拉選單、不給自由打字：可用性最好，但違反需求圖，且需求 3.b 沒東西可處理。
- **(d)** (b) + 即時自動完成建議：仍可自由打字，下方列出符合的縣市；可用性最佳且保留無效輸入路徑，成本是多一個 widget。

**已查證的事實**

見本輪 F4：官方 OpenAPI spec 的 `locationName` enum 恰好 22 個縣市，**全部使用「臺」**（臺北市／臺中市／臺南市／臺東縣），沒有「台」字版本，也不含鄉鎮區。來源：<https://opendata.cwa.gov.tw/apidoc/v1>

**AI 推薦**

(b)——需求 3.b 要求判定「無效」，只有本地白名單能產生這個判定；(d) 是 (b) 的超集。

**我的決定**

(d)

**我的理由**

使用上更人性化。

**影響**

- 關掉了 (a)（把判定推給 API）與 (c)（放棄自由輸入）。
- 確立 repo 內必須存在一份「22 縣市 + 別名」的靜態資料，且正規化必須是可單元測試的純邏輯。
- 開啟後續問題：自動完成的比對規則（prefix vs contains）、選取建議後是否自動送出、以及沒選建議直接按確認時的行為。

---

### Q2 — 授權碼要怎麼進一個要交出去的公開 GitHub repo

**問題**

授權碼是 query parameter，代表在 client 端本質上無法保密。選項為 (a) 直接 commit、(b) `--dart-define` + `String.fromEnvironment`、(c) `flutter_dotenv` + `.env`、(d) (b) 加上 README 另附臨時授權碼。取捨在於「面試官能不能跑起來」與「有沒有把機密寫進版控」之間。

**已查證的事實**

- F2：`Authorization` 是官方 spec 中 `required: true` 的 **query parameter**，不是 header。來源：<https://opendata.cwa.gov.tw/apidoc/v1>
- F3：未帶授權碼時回 **HTTP 401**，body 為純文字 `401 Forbidden: Authorization key is not correct.`，`Content-Type: application/octet-stream`。實測（2026-08-25）。
- Flutter 3.47.0 的 `flutter run` / `flutter build` 均支援 `--dart-define-from-file=<*.json|.env>`，且「`--dart-define` 的同名鍵優先於檔案中的項目」。實測 `flutter run --help`。

**AI 推薦**

(b) + (d) 的 README 附碼——client 端無法真正保密，(c) 多花成本卻沒換到安全性。

**我的決定**

(b) + (d)，並直接給出完整實作規格：

1. 程式碼只有一個讀取點 `const String.fromEnvironment('WEATHER_API_TOKEN')`，包在 `AppConfig` 裡；`main()` 第一行檢查是否為空，空則丟 `StateError` 並附 README 指引。
2. 本機用 `dart_defines/dev.json`（gitignored，放真 token）+ `dart_defines/dev.example.json`（進版控、值留空），以 `--dart-define-from-file` 執行；`.vscode/launch.json` 進版控且本身不含機密。
3. CI 用 GitHub Repository secret `WEATHER_API_TOKEN`；單元測試打 mock 不需真 token，只有真的打 API 的 job 才傳；fork PR 拿不到 secret 時該 job 應 **skip 而非 fail**。
4. README 給 reviewer 兩條路：自行免費申請，或使用繳交信件中另附的臨時 token。token 不進 repo。

**我的理由**

「我知道且接受的限制：`--dart-define` 的值會被編譯進 binary，反編譯就能撈出來。這個做法防的是『token 進入 git 歷史與 public repo』，不是『使用者拿不到 token』。用戶端 app 沒有真正的機密，根治方法是自架 proxy 後端由伺服器持有金鑰，但這次作業不值得為此加一個後端。」

**影響**

- 關掉了 (a)、(c)，也關掉了「加一層 proxy 後端」這個分支（明確評估後放棄）。
- 新增一個啟動期失敗模式（設定缺失 → `StateError`），它**不屬於**四個 Widget 的任何一個，而是在 app 啟動前就爆——這把 401 從「執行期錯誤畫面」降級成「幾乎不該發生的情況」。
- 開啟後續問題：CI workflow 的 job 切分與 fork PR 的條件式 skip 寫法。
- **F11 仍未解**：我手上沒有可用的授權碼，因此「不合法 `locationName` 的實際回應」尚未實測。

---

### Q3 — 錯誤分類法，以及解析要多嚴格

**問題**

需求只給四個 Widget、只列兩種錯誤，但實際失敗模式至少六種：① 輸入不在白名單 ② 授權碼缺失／錯誤 ③ 網路不可達／timeout ④ HTTP 5xx ⑤ 200 但 body 非合法 JSON 或結構不符 ⑥ 200 且結構正確但 `records.location` 為空。選項為 (a) 扁平字串錯誤、(b) sealed 錯誤型別窮舉、(c) (b) + 把「查無資料」獨立成第五個 empty state。子問題：解析採 (i) 寬鬆 或 (ii) 嚴格。

**已查證的事實**

- F3：401 的 body 是純文字而非 JSON——錯誤處理不能假設「失敗時也會拿到 JSON」。實測。
- F6：官方 spec 的 `responses.200` 只有 `description: OK`，**完全沒有 response schema**。回傳結構在官方文件中屬未定義狀態。來源：<https://opendata.cwa.gov.tw/apidoc/v1>

**AI 推薦**

(b) + (ii)——把 ⑥ 歸為 error 的一個 case 以維持嚴格四個 Widget；寬鬆解析會讓需求 3.a「偵測資料格式不正確」永遠無法被示範。

**我的決定**

(b) + (ii)

**我的理由**

需要更詳細的錯誤狀態。

**影響**

- 關掉了 (a) 與 (c)：維持嚴格四個 Widget，「查無資料」是 error 底下的一個 case。
- 確立解析層必須有明確的 schema 檢查並能丟出 `malformedResponse`，這同時成為單元測試的主要標的。
- 開啟後續問題：Riverpod 3 的 `AsyncValue` 只有三個子型別，與需求的四態不相容——狀態該怎麼建模（見第 2 輪 Q8）。

---

### Q4 — 顯示區塊要呈現多少資料

**問題**

API 回 3 個 12 小時時段 × 5 個要素（Wx／PoP／MinT／MaxT／CI）。選項為 (a) 只顯示最近一個時段、(b) 三個時段全列、(c) (b) + 依 Wx 代碼對應圖示。

**已查證的事實**

- F5：`elementName` enum 為 `Wx`、`PoP`、`CI`、`MinT`、`MaxT`。來源：<https://opendata.cwa.gov.tw/apidoc/v1>
- 題目名稱即「今明 **36 小時**天氣預報」，3 × 12 小時 = 36 小時。

**AI 推薦**

(b)，且 Wx 直接顯示 API 已給好的中文 `parameterName`，不自建代碼對照表。

**我的決定**

(b)，並要求「做好基本天氣分類」。

**我的理由**

（推論）三個時段全列才對得上「36 小時」這個題目名稱；而天氣要有粗分類才能給出視覺辨識度，不能只是一行中文字。請校對。

**影響**

- 關掉了 (a)。
- 推翻了 AI 原本「完全不做代碼對照」的建議：必須建立一套 Wx 代碼 → 粗分類的映射。
- 開啟後續問題：分類的依據（官方分類代碼 vs 中文關鍵字比對）、分類粒度、以及圖示來源（見第 2 輪 Q11）。

**實作期修正（2026-08-25，#15 實測、#14 收尾稽核時補記）**

| # | 事實 | 來源 |
| --- | --- | --- |
| F47 | 三個時段的**長度不固定**。查詢時間 14:2x 時第一段為 12:00–18:00（6 小時）、合計 30 小時；查詢時間 20:11 時第一段為 18:00–06:00（12 小時）、合計 36 小時。第二、三段恆對齊 06:00／18:00 邊界，被截短的只有第一段 | 實測上游（#15，2026-08-25 14:2x）；實測上游（#14 收尾稽核，2026-08-25 20:11） |
| F48 | `test/fixtures/cwa/forecast_single_location.json` 的三段恰為整齊的 12 小時，是**擷取時機造成的誤導性樣本**，不是反例 | 讀 fixture |

上游一天發布四次（05／11／17／23 時），而時段邊界固定在 06:00／18:00，因此第一段是「當前 12 小時區塊的剩餘部分」——長度隨查詢時間變動，總涉蓋時數隨之落在 24–36 小時之間。**「36 小時」是上限，不是恆等式；恆為真的只有「恰好三段」。**

Q4 的決定（三個時段全列）**不受影響**，理由也仍成立：全列仍然是唯一能涵蓋到明天的選項。上面「3 × 12 小時 = 36 小時」那句推論實際上只在一半的發布時段成立，但它推到的結論正確，因此只改敘述用語，不改決定。

**修正的影響**

- `CONTEXT.md` 的「預報時段」詞條刪去「每段 12 小時」。
- `lib/domain/forecast_slot.dart` 的類別註解同步更正。
- #14 規格的 Solution、User Story 17 與「呈現」段不再宣稱時段等長。
- **程式邏輯無需更動**：`ForecastSlot` 帶明確的 `startTime`／`endTime`，相對日以日曆日相減，解析依名稱查找——全案沒有任何一處假設時段等長（已於 #14 收尾稽核以全案 grep 確認）。這也是這個缺陷能潛伏到最後的原因：它只存在於敘述，不在行為裡。

---

### Q5 — Riverpod 的寫法：codegen 還是手寫

**問題**

選項為 (a) 手寫 provider 不裝 build_runner、(b) `riverpod_generator` codegen、(c) (b) + 把產生檔一併 commit。

**已查證的事實**

- F9：`flutter_riverpod` 3.4.2、`riverpod_generator` 4.0.8、`riverpod_annotation` 4.0.6（皆為 2026-07-30 發布）。來源：pub.dev。
- Riverpod 3 中 `StateProvider`／`StateNotifierProvider`／`ChangeNotifierProvider` 已被移到 `package:riverpod/legacy.dart`，官方明示「不再推薦」。來源：<https://riverpod.dev/docs/3.0_migration>

**AI 推薦**

(c)——官方推薦寫法，且 commit 產生檔是針對「reviewer 會 clone 來跑」這個具體情境的必要妥協。

**我的決定**

(c)

**我的理由**

可以順利跑 demo 比較重要。

**影響**

- 確立 `build_runner` 進 dev_dependencies，`.gitignore` **不**排除 `*.g.dart`。
- 開啟後續問題：CI 需要驗證「產生檔與原始碼同步」（跑一次 build_runner 後 `git diff` 必須為空），否則 commit 產生檔反而會變成腐爛來源。

**實作期修正（2026-08-25，#11 實作時實測）**

| # | 事實 | 來源 |
| --- | --- | --- |
| F45 | `build_runner` 2.16.0 已移除 `--delete-conflicting-outputs`。帶上去不會失敗，只會印一行 `These options have been removed and were ignored` | 實測 `dart run build_runner build --help`／`build`（2026-08-25） |
| F46 | 本 repo 的 `forecast_controller.g.dart` 在 #11 之前就已與原始碼脫節（riverpod 的 provider hash 不符），因為 #9／#10 改了原始碼卻沒重跑產生器 | 實測 `dart run build_runner build` 後 `git diff` |

F46 正是 Q5 影響欄預言的腐爛，而且在**沒有人刻意製造**的情況下發生——這條 CI 檢查在被寫下的當天就抓到了第一個真實案例。它同時也是「產生檔進版控」這個決定的代價的實證：決定本身不變（理由仍成立），但代價需要一道自動檢查來償還。

**影響**

- #11 的 `codegen-check` job 指令改為 `dart run build_runner build`，不帶已移除的旗標。
- 隨 #11 一併修正脫節的產生檔。

---

### Q6 — 資料模型：freezed 還是不要

**問題**

選項為 (a) `json_serializable` + Dart 原生 sealed class、(b) `freezed` 4.0.0、(c) `freezed` 鎖 3.x。

**已查證的事實**

- F9：`freezed` 4.0.0 於 **2026-08-23** 發布，距今僅 2 天。來源：pub.dev。
- 本機 Dart 為 **3.13.0**，語言層原生支援 `sealed class` 與 exhaustive `switch`。實測 `dart --version`。

**AI 推薦**

(a)——唯一需要 freezed 的地方（sealed union）Dart 語言本身已內建，不值得為它扛一個兩天大的套件。

**我的決定**

(a)

**我的理由**

用官方的實作就好，因為 class 不多。

**影響**

- 關掉了 (b)、(c)，`freezed` 完全不進依賴。
- `copyWith` 若真的需要就手寫；Q3 的失敗型別直接用 Dart 原生 `sealed class`。

---

### Q7 — 範圍紀律：只做需求，還是加分

**問題**

選項為 (a) 嚴格只做需求、(b) 加產品功能（搜尋歷史、深色模式、i18n）、(c) 加工程品質（單元測試、widget 測試、CI）。

**已查證的事實**

需求 PDF 的評估標準為五條：代碼的清晰度和整潔度／應用程式的可用性／用戶界面的易用性／需求理解程度／需求完成度。**沒有任何一條是「功能豐富度」**。來源：`docs/require.pdf`。

**AI 推薦**

(a) + (c)，明確不做 (b)——加產品功能會稀釋「需求理解程度」的訊號，加測試會強化「清晰整潔」的訊號。

**我的決定**

(a) + (c)

**我的理由**

確保需求核心功能，加上穩定品質和開發流程。

**影響**

- 關掉了 (b)：搜尋歷史、深色模式、i18n、多縣市比較等一律不做。
- 確立 CI 是交付物的一部分，且需要決定跑哪些 job（見第 2 輪 Q12）。

---

## 第 2 輪

### 共通事實（本輪查證所得）

| # | 事實 | 來源 |
| --- | --- | --- |
| F12 | **官方 Wx 代碼表已取得**：`預報 XML 產品預報因子欄位中文說明表`（14 頁 PDF），第 4–14 頁為「預報產品天氣描述代碼表」，三欄為 **中文描述｜英文描述｜分類代碼**。已下載並完整解析 | <https://opendata.cwa.gov.tw/opendatadoc/MFC/D0047.pdf> |
| F13 | `parameterValue` **本身就是官方的粗分類代碼**：數百句中文描述收斂成 **41 個代碼（1–42，其中 40 不存在）**。例如代碼 `18` 底下掛 18 句描述、代碼 `32` 掛 41 句。我們不需要自行歸納分類 | 同 F12（實際解析結果） |
| F14 | 社群廣為流傳的 pjchender 分類表**與官方表不符**（把不存在的代碼 40 也算進去） | 比對 F12 與 <https://pjchender.dev/react-bootcamp/docs/book/ch6/6-1/> |
| F15 | `AsyncValue` 是 `sealed`，**恰好三個**子型別 `AsyncData`/`AsyncLoading`/`AsyncError`，**沒有 idle／尚未開始**的狀態 | <https://riverpod.dev/docs/whats_new>（Other changes → AsyncValue） |
| F16 | Riverpod 3 新增 `Mutation`（**實驗性**），狀態恰好四個：`MutationIdle`/`MutationPending`/`MutationError`/`MutationSuccess`。官方明文：「experimental and not yet stable… the API may change in breaking ways **without a major version bump**」 | 同上（Mutations (experimental)） |
| F17 | **自動重試預設開啟**：provider 初始化失敗會自動重試，指數退避 200ms→400ms→…→6.4s，直到成功或被 dispose | 同上（Automatic retry）／<https://riverpod.dev/docs/3.0_migration> |
| F18 | provider 拋出的例外會被包進 `ProviderException`（`AsyncValue.error` 與 `ProviderObserver` 不受影響） | <https://riverpod.dev/docs/3.0_migration> |
| F19 | 不可見的 provider 會被自動暫停（依 `TickerMode`）；測試工具改為 `ProviderContainer.test()`（自動 dispose），另有 `WidgetTester.container()` | <https://riverpod.dev/docs/whats_new> |
| F20 | `http_mock_adapter` 最後發版為 **2024-08（2 年前）**，而 `dio` 目前為 5.11.0，相容性未知 | pub.dev |
| F21 | Repo remote 為 `git@github.com:allenljf/weather-forecast-flutter.git`，**PUBLIC**，`main` 尚無任何 commit；`gh` 已登入 `allenljf`，token scopes 含 `repo`、`workflow` | 實測 `git remote -v` / `gh auth status` / `gh repo view` |

---

### Q8 — 四個 Widget 要怎麼建模：Riverpod 給三態，需求要四態

**問題**

`AsyncValue` 只有三個子型別且沒有「尚未開始」，但需求要四個 Widget。選項為 (a) 自訂 sealed 四態、(b) `AsyncValue` + 查詢字串 provider（null 表初始）、(c) 用 Riverpod 3 實驗性的 `Mutation`。

**已查證的事實**

F15、F16、F17、F18（見上表）。特別是 F17：若讓 provider 的 `build()` 拋錯來表達失敗，一個「查無此縣市」會被自動重試到 6.4 秒才顯示錯誤畫面，期間打了 5 次 API。

**AI 推薦**

(a)——只有自訂 sealed state 能讓四態收斂成單一 exhaustive `switch`，且讓 F17／F18 兩個新預設行為完全碰不到本專案。

**我的決定**

(a)

**我的理由**

自訂才可以保持任何需求的彈性。

**影響**

- 關掉了 (b) 與 (c)，`AsyncValue` 與 `Mutation` 都不進這個專案。
- 因為 provider 的 `build()` 永不拋錯，**Riverpod 3 的自動重試與 `ProviderException` 包裹在本專案完全不會被觸發**——不需要在 `ProviderScope` 上關掉 `retry`。
- 開啟後續問題：狀態轉移由 `search()` 手動驅動，代表「查詢中再次送出」的競態必須自己處理（見第 3 輪）。

---

### Q9 — 檔案要怎麼切

**問題**

已承諾五個可測試接縫（正規化、解析器、失敗映射、API client、狀態 Notifier）。選項為 (a) 扁平、(b) 依領域概念切、(c) 依技術層切、(d) feature-first + Clean Architecture（含 usecase 層）。

**已查證的事實**

需求範圍只有**一個功能、一個畫面、一個 endpoint**（`docs/require.pdf`），因此 (d) 的 `features/` 底下永遠只有一個孩子，usecase 層只會是純轉發。

**AI 推薦**

(c)——讓「這個資料夾整個都能單測、不需要 Flutter binding」成為目錄層級的保證，直接支撐 Q7 的測試承諾。

**我的決定**

(c)

**我的理由**

功能層分模組，依賴底下工具類模組。

**影響**

- 關掉了 (a)、(b)、(d)：不做 usecase 層，但**保留 repository 抽象介面**（Q12 的 mock 邊界）。
- `domain` 必須是純 Dart、零 Flutter 依賴，這是可被 CI 驗證的約束。

---

### Q10 — 自動完成的互動語意

**問題**

四個子決定：① 比對規則（prefix vs contains）② 建議何時出現 ③ 點選建議後是否自動送出 ④ 空輸入按確認的行為。

**已查證的事實**

- F4：22 個縣市中有 4 個以「臺」開頭（臺北市／臺中市／臺南市／臺東縣），因此 prefix 比對會讓使用者打「南」時找不到臺南市。
- 需求原文為「用戶應該可以…輸入 locationName…然後**點擊確認後**從 API 獲取數據」，需求圖亦畫有確認按鈕。來源：`docs/require.pdf`。

**AI 推薦**

1(b) contains、2(b) 至少 1 字、3(a) 選取只填入仍需按確認、4(a) 空輸入時 disabled。

**我的決定**

1(b)、2(b)、3(a)、4(a)

**我的理由**

符合用戶體驗和需求。

**影響**

- 確立「空輸入」不是無效查詢，不進錯誤狀態——錯誤狀態的語意維持乾淨。
- 確認按鈕的 enabled/disabled 成為一個需要被 widget test 覆蓋的行為。

---

### Q11 — 天氣分類：依據、粒度、圖示

**問題**

① 分類依據（官方分類代碼 vs 中文關鍵字比對）② 粒度（4 類／6 類／更細）③ 圖示來源（Material Icons vs 自製 asset）④ 是否做日夜變體。

**已查證的事實**

- F12、F13：官方已把數百句描述收斂成 41 個分類代碼；自己用中文關鍵字再歸納一次是重工且更易錯。
- F14：社群流傳的分類表與官方不符。
- 官方代碼中「霧」（24–28、31、32、35、36、38、39、41）與「雪」（23、37、42）有清楚的獨立群組邊界。來源：F12 解析結果。
- 官方代碼**不含日夜資訊**，日夜要靠預報時段的起訖時間自行判斷。來源：F12。

**AI 推薦**

1(a)、2(b) 六類、3(a) Material Icons、4 不做。

**我的決定**

1(a)、2(b) 六類、3(a) Material Icons、4 不做

**我的理由**

（推論）官方代碼是既有且穩定的分類依據，六類是代碼邊界自然給出的切點；Material Icons 讓加圖示的成本趨近於零，不會反過來吃掉需求本身的工。請校對。

**影響**

- 六類確定為：晴／多雲陰／雨／雷雨／霧／雪。
- 需要一份「41 個代碼 → 6 類」的靜態映射，且該映射必須以官方 PDF 為唯一來源、不採用社群版本。
- 關掉了日夜圖示分支。

---

### Q12 — 測試與 CI 的具體範圍

**問題**

測什麼（①正規化 ②解析器 ③失敗映射 ④Notifier 狀態轉移 ⑤四種 Widget ⑥golden）、怎麼 mock（自寫 fake vs `http_mock_adapter`）、CI 跑什麼（單 job／三 job／加 codegen 同步檢查）、iOS 要不要進 CI。

**已查證的事實**

- F20：`http_mock_adapter` 兩年未更新，與 dio 5.11.0 相容性未知。
- Q5 已決定把 `.g.dart` commit 進 repo——若無同步檢查，產生檔遲早與原始碼脫節。
- iOS build 需要 macOS runner，明顯較慢且較貴。

**AI 推薦**

測 ①–⑤、不做 ⑥；mock 用自寫 fake + `mocktail`；CI 用 (c) 但**只 build Android**。

**我的決定**

測 ①–⑤、不做 ⑥；mock 用 (a)；CI 用 (c)，**且 Android 與 iOS 都要 build**。

**我的理由**

（推論）需求明文要求「在 Android 和 iOS 模擬器上可以運作」，只在本機驗證 iOS 等於這條需求沒有任何自動化證據；CI 同時 build 兩個平台才能持續證明它成立。請校對。

**影響**

- 推翻了 AI 的成本考量：CI 需要一個 macOS runner job。
- 開啟後續問題：iOS job 的細節（runner 版本、是否 `--no-codesign`），以及一個前提修正——**build 階段其實不需要真 token**（`String.fromEnvironment` 沒有定義時回空字串，編譯照樣通過；token 只有在執行期才會被檢查）。這會影響 Q2 第 3 點中「哪些 job 需要 secret」的判斷。

---

### Q13 — README 兩題問答與 AI 使用說明

**問題**

① 時機（現在處理 vs 技術做完再處理）② 做法（口述後整理／AI 先出訪談清單／自己寫）③ 是否在 README 的 AI 章節連到 `PROMPT_LOG.md` 與 `GRILL_LOG.md`。

**已查證的事實**

需求要求 README 需包含兩題問答的回答，以及「你是用哪一家的 AI 和如何在專案中使用」。來源：`docs/require.pdf`。

**AI 推薦**

1(b) 技術做完再處理、2(b) AI 先出訪談清單、3 要連。

**我的決定**

1(a) 現在就處理、2(b)、3 要連

**我的理由**

因為要模擬做需求前就先把規格講好給 PM 確認。

**影響**

- 推翻了 AI 的排程建議：README 的敘事部分被拉到實作之前，與「規格先確認再動工」的立場一致。
- 確立兩份紀錄檔從「額外負擔」轉為交付物的一部分，會被 README 直接引用。
- AI 的識別需在 README 中據實說明：GitHub Copilot，模型 Claude Opus 5。

---

### Q14 — 交付流程：要留下多少「開發流程」的痕跡

**問題**

(a) 不開 issue、(b) 開 issues + 直接 commit 到 `main`、(c) issues + feature branch + PR。

**已查證的事實**

- F21：repo 為 PUBLIC、尚無 commit，`gh` 已登入且具 `repo` 與 `workflow` scope。
- `AGENTS.md` 與 `docs/agents/issue-tracker.md` 已指定 issue 一律走 GitHub Issues + `gh` CLI；`docs/agents/triage-labels.md` 定義了五個 triage 標籤。

**AI 推薦**

(b)——issues 軌跡正好替問答題第 2 題提供實物證據，而單人 PR 的 review 欄位空白反而暴露走過場。

**我的決定**

(b)

**我的理由**

因為要分配任務給其他 RD 需要有 issue。

**影響**

- 關掉了 (c)：不開 PR。
- 確立 issue 是「需求拆解」的載體，而非事後補的紀錄——拆解必須在實作之前完成。
- 開啟後續問題：issue 的拆解粒度與標籤用法。

---

### Q15 — F11 這個事實怎麼解

**問題**

「帶合法授權碼但 `locationName` 不合法時 API 回什麼」尚未查證，而授權碼是只有人類能取得的憑證，且不應經過 AI 的對話內容。選項為 (a) 由人建立 gitignored 的 token 檔、AI 讀檔實測但不印出 token、(b) 人自己跑 curl 貼結果、(c) 不查、直接假設。

**已查證的事實**

F3：未帶授權碼時回 HTTP 401 且 body 為純文字。合法授權碼下的行為無法由外部推得。

**AI 推薦**

(a)——一石二鳥：拿到事實，同時把 Q2 決定的 `dart_defines/` 結構實際建立並驗證一次。

**我的決定**

(a)

**我的理由**

考慮周全。

**影響**

- 立即產出 `.gitignore` 與 `dart_defines/dev.example.json` 骨架。
- 解開 F11 後，可一併實測回應的真實結構（`success` 的型別、`PoP` 是否可能為空值等），這些事實會回頭影響 Q3 決定的嚴格解析規則。

---

## 第 3 輪

### 共通事實（本輪查證所得）

| # | 事實 | 來源 |
| --- | --- | --- |
| F22 | `flutter build ios --simulator` 存在於 3.47.0，說明為「Build for the iOS simulator instead of the device. This changes the default build mode to debug」；`--no-codesign` 只在 device build 可用 | 實測 `flutter build ios --help` |
| F23 | **CI 的 build job 不需要真 token**：`String.fromEnvironment` 未定義時回空字串，編譯照樣通過；Q2 的檢查在 `main()` 執行期才發生 | Dart 語言語意 + Q2 設計 |
| F24 | `.gitignore` 規則經實測驗證：`git check-ignore -v dart_defines/dev.json` 命中 `dart_defines/*.json`；`git add -An dart_defines/` 只列出 `dev.example.json` | 實測（2026-08-25） |

---

### Q16 — CI 到底需不需要那個 secret

**問題**

Q12 已決定測試全走 mock，而 F23 顯示 build 不需要 token，因此原規劃的所有 job 都不需要 secret。選項為 (a) CI 完全不碰 secret、(b) 加一個真的打 API 的 smoke test job、(c) smoke test 只跑手動或排程。iOS job 形式為 (i) `--no-codesign` device build 或 (ii) `--simulator`。

**已查證的事實**

F22、F23（見上表）。需求原文為「使用 Flutter 在 Android 和 **iOS 模擬器**上可以運作」。來源：`docs/require.pdf`。

**AI 推薦**

(a) + (ii)——CI 的職責是驗證程式碼而非監控第三方服務；`--simulator` 剛好是需求原文的字面驗證。

**我的決定**

(a) + (ii)

**我的理由**

（推論）不把氣象署的可用性接進交付物的 CI，避免無關的紅燈；iOS 用 simulator build 對應需求字面。請校對。

**影響**

- 已設定的 GitHub secret `WEATHER_API_TOKEN` 在 CI 中**不會被使用**——這件事需要在 README 中明說，否則會被讀成疏漏。
- 關掉了「CI 監控 API 可用性」這條分支。
- fork PR 的 skip 邏輯不再需要，CI workflow 因此更簡單。

---

### Q17 — 專案識別

**問題**

`flutter create` 的四個參數：套件名稱、org／bundle id、App 顯示名稱、平台裁切。這些值一旦生成就散落在 `pubspec.yaml`、Gradle、`Info.plist`、Xcode project 中，事後修改成本高。

**已查證的事實**

`flutter create` 預設 org 為 `com.example`，預設會生成 android／ios／web／macos／windows／linux 六個平台目錄。評估標準第 1 條為「代碼的清晰度和整潔度」。

**AI 推薦**

`weather_forecast`／`com.allenljf`／「36 小時天氣預報」／`--platforms=android,ios`。

**我的決定**

同推薦，全數採納。

**我的理由**

（推論）改掉 `com.example` 成本為零但訊號明確；砍掉四個永不編譯的平台目錄直接對應整潔度評分。請校對。

**影響**

- 專案骨架的建立指令因此固定下來，成為第一個 issue 的內容。
- Repo 中不會出現 web／desktop 相關檔案。

---

### Q18 — 競態與逾時

**問題**

Q8 選了手動驅動的狀態轉移，因此「查詢中再次送出、先發後到」的競態必須自行處理。選項為 (a) loading 期間 disable 按鈕、(b) request id 丟棄過期回應、(c) `CancelToken`。逾時值選項為 5/5、5/10、15/15、不設。

**已查證的事實**

Q8 決定不使用 `AsyncValue`，代表 Riverpod 不會替我們處理過期回應；Q7 已承諾要寫測試，而 (a) 這種「靠 UI 記得 disable」的做法無法被單元測試覆蓋。

**AI 推薦**

(b) + (ii) 5s/10s。

**我的決定**

(b) + (iii) 15s / 15s

**我的理由**

（推論）採用 request id 讓正確性可被單測；逾時放寬到 15 秒，寧可多等也不要在網路較慢時誤判為失敗。請校對。

**影響**

- 推翻了 AI 的逾時建議（5s/10s → 15s/15s）：loading 狀態最長可能持續 15 秒，因此 loading 畫面的設計要能撐住較長的等待，不能只是一個沒有說明的轉圈。
- 「逾時」成為 Q3 六種失敗中一個可觸發、可測的案例。
- 確立測試項目之一：「舊回應晚到不得覆蓋新狀態」。

---

### Q19 — 時間怎麼顯示

**問題**

API 回傳本地時間、無時區標記的字串。選項為 (a) 原樣、(b) 今日／明日／後天相對日、(c) 短日期；以及是否引入 `intl`。

**已查證的事實**

三個時段共 36 小時，實測時段對齊 06:00／18:00（見第 4 輪 F27），因此相對日**最多只會用到「今日／明日／後天」三個詞**，是有界問題。

**AI 推薦**

1(b)、2 不引入。

**我的決定**

1(b)、2 不引入

**我的理由**

（推論）相對日對使用者最好讀，且因為有界所以手寫成本極低，`intl` 的 locale 初始化成本沒有回報。請校對。

**影響**

- 需要一個「以查詢當下時間為基準，把時段起訖轉成今日／明日／後天」的純函式，且它可被單元測試（含跨日邊界）。
- 依賴清單維持精簡，不含 `intl`。

---

### Q20 — 錯誤畫面要說什麼、要不要給重試

**問題**

① 每種失敗各自文案與動作，或統一文案一律重試。② 是否露出技術細節（HTTP 狀態碼、原始錯誤）。

**已查證的事實**

評估標準第 3 條為「用戶界面的易用性」；Q3 已定義六種失敗。若六種最後都顯示同一句話，該分類在 UI 上不產生任何可見價值。

**AI 推薦**

1(a)、2(b)。

**我的決定**

1(a)、2(b)

**我的理由**

（推論）差異化文案與「有無重試按鈕」是錯誤分類的可見證據；技術細節預設收合，兼顧一般使用者與技術審閱者。請校對。

**影響**

- 每一種失敗都必須配一組（文案 + 是否可重試），這組對應關係本身成為一個可單測的純函式。
- 錯誤 Widget 需要一個可展開的「詳細資訊」區塊，且失敗型別必須攜帶原始錯誤資訊（狀態碼、訊息）而不只是一個列舉值。

---

### Q21 — issue 要拆多細、標籤怎麼用

**問題**

① 粒度（粗 4–5 個／中 8–12 個／細 20+ 個）② 標籤（沿用 repo 既有的 triage 標籤／另建領域標籤／不用標籤）。

**已查證的事實**

`docs/agents/triage-labels.md` 的五個標籤（`needs-triage`／`needs-info`／`ready-for-agent`／`ready-for-human`／`wontfix`）語意是「收到外部回報後的分流」，與「自己拆解自己的需求」不符。

**AI 推薦**

1(b) 中粒度、2(b) 自訂領域標籤。

**我的決定**

1(b)、2(b)

**我的理由**

（推論）issue 必須是「可以獨立交給一個人做完」的大小才符合「分配任務給其他 RD」的用途；triage 標籤語意不成立，硬套反而顯示沒讀懂。請校對。

**影響**

- 需要在 repo 建立一組領域標籤（`area:*`／`type:*`），這是實作前的準備工作之一。
- issue 拆解必須在寫任何程式碼之前完成。

---

## 第 4 輪

### 共通事實（本輪實測所得）

用 gitignored 的 `dart_defines/dev.json` 實測七種輸入。腳本只印出 `prefix=CWA- length=40`，並將 token 從所有回應內容中洗除——**授權碼的值從未進入對話紀錄**。

| # | 事實 | 來源 |
| --- | --- | --- |
| **F11** | **已解**：`locationName` 不合法時回 **HTTP 200 + `success:"true"` + `records.location: []`**。`台北市`（台）、`火星` 皆如此。**API 從不告知輸入錯誤** | 實測（2026-08-25） |
| F25 | `elementName` 不合法時同樣回 200，但 `weatherElement: []`；不帶 `locationName` 或帶空值皆回 22 筆（46KB）；帶兩個 `locationName` 回 2 筆 | 實測 |
| F26 | `success` 是**字串** `"true"`，不是布林 | 實測 |
| F27 | `location[i]` 只有 `locationName` 與 `weatherElement` 兩個鍵——**沒有 `lat`/`lon`**（社群文件宣稱有，實際沒有）。`location` 陣列順序**不是** spec enum 順序（實測第一筆為嘉義縣） | 實測 |
| F28 | `weatherElement` 順序 22/22 皆為 `Wx, PoP, MinT, CI, MaxT`——**`MaxT` 在 `CI` 之後，不與 `MinT` 相鄰**。每個要素恰好 3 個時段，對齊 06:00／18:00 | 實測 |
| F29 | **`parameter` 的鍵形狀因要素而異**：`Wx` 為 `parameterName`+`parameterValue`（無 unit）；`PoP` 為 `parameterName`+`parameterUnit`(`百分比`)（無 value）；`MinT`/`MaxT` 為 `parameterName`+`parameterUnit`(`C`)；**`CI` 只有 `parameterName`**。數值一律以字串放在 `parameterName` | 實測 |
| F30 | 本次快照 22 縣市 × 5 要素 × 3 時段 = 330 個 parameter，**零個空值或缺鍵** | 實測 |
| F31 | 帶 `locationName` 回 2.5KB，不帶回 46KB（18 倍差距） | 實測 |

---

### Q22 — token 防護要做到幾層

**問題**

選項為 (a) 只靠 `.gitignore`、(b) 加自寫 pre-commit hook（涵蓋明碼與 base64）、(c) 加 `gitleaks`、(d) 改架構避免需要 token。

**已查證的事實**

- GitHub secret scanning 對 public repo **免費自動執行**，且 push protection for users 預設開啟會擋住往 public repo 推送 secret——**但只認得合作夥伴已註冊的格式**，自訂樣式需付費的 GitHub Secret Protection 且僅限 organization repo。CWA 授權碼不在其中。來源：<https://docs.github.com/en/code-security/secret-scanning/introduction/about-push-protection>
- Flutter 會把 `--dart-define` 的內容以 **base64** 寫入 `ios/Flutter/Generated.xcconfig` 的 `DART_DEFINES=`，使純文字 grep 防護失效（該檔已在 `.gitignore`）。
- F24：現有 `.gitignore` 規則已實測有效。

**AI 推薦**

(b) + README 不得出現 token 範例 + 明訂撤換計畫。

**我的決定**

**不防護**。授權碼直接公開推上 repo。

**我的理由**

「反正是免費的，被打爆我也不用付錢，頂多失效，面試官可以用自己的 key 替換」「還是以面試官方便測試為主，我的 github 也沒外人來看」。並要求在 README 加一段說明：正式專案應如何保護 token，有哪幾種做法，包含把 token 放後端的解法。

**影響**

- 推翻了 Q2 決定中「token 不放進 repo」的核心；`.gitignore` 的 `dart_defines/*.json` 規則需要開一個例外。
- **把弱點轉為展示位置**：README 的安全章節從「附帶說明」升格為主動論述——這也是唯一能讓「明碼 token」不被讀成疏忽的方式。
- 開啟後續問題：token 以什麼形式進 repo（原始碼常數／獨立設定檔／`defaultValue`）、README 那段說明的深度與是否誠實揭露本專案取捨。

---

### Q23 — 模型長什麼樣、嚴格解析到底嚴格到哪

**問題**

① 模型形狀：(a) 忠實映射 API 的 `WeatherParameter{name, value?, unit?}` vs (b) 收斂成領域模型 `ForecastSlot`。② 嚴格度：(i) 五要素缺任一即 malformed vs (ii) 只有 `Wx` 與時間必要、其餘缺失顯示「—」。

**已查證的事實**

F29（`parameter` 鍵形狀異質、數值以字串藏在 `parameterName`）、F30（實測 330 個 parameter 零缺失）、F28（`MaxT` 位置反直覺、順序不可依賴）。

**AI 推薦**

(b) + (i)——`CONTEXT.md` 已把「預報時段」定義為領域概念；而實測顯示正常情況 100% 齊全，缺任一即代表異常，正是需求 3.a 要偵測的對象。

**我的決定**

(b) + (i)

**我的理由**

（推論）不讓 API 的怪異形狀洩漏進 UI；既然正常情況下資料必定齊全，就該把缺失視為異常而非容忍。請校對。

**影響**

- 解析層必須依 `elementName` / `locationName` **查找**而非依索引取值（F28 證明順序不可依賴，且依索引的錯誤是靜默的）。
- 數值轉型失敗（`int.parse` 失敗）也必須歸入 `malformedResponse`。
- 領域模型不得出現 `parameterName` / `parameterValue` 這類 API 詞彙，須使用 `CONTEXT.md` 的語彙。

---

### Q24 — 「空陣列」到底是誰的錯

**問題**

白名單命中（輸入是合法縣市）但 API 回空陣列，代表本地清單與上游脫鉤。選項為 (a) 與「查無資料」不分、(b) 視為 `malformedResponse`、(c) 獨立一種失敗。

**已查證的事實**

F11：API 對不合法 `locationName` 回 200 + 空陣列，不提供任何錯誤訊號。因此「空陣列」是唯一可觀察的訊號，但它同時對應兩種完全不同的成因。

**AI 推薦**

(c)——sealed 失敗型別的全部價值就在於「誰的錯」不同時要能分開。

**我的決定**

(c)

**我的理由**

（推論）文案要對使用者誠實（是氣象署沒資料，不是你打錯字），而「本地清單可能過期」這個診斷資訊應留在 Q20 的可展開技術細節中。請校對。

**影響**

- **更正**：這不是新增第七種失敗，而是把 Q3 原列的第 ⑥ 種（200 但 `location` 為空陣列）**精確命名並給它專屬文案**。失敗總數維持六種。因為 Q1 的本地白名單擋在前面，能走到 API 的輸入必定是合法縣市，所以「空陣列」在本專案中只有一個成因：本地清單與上游脫鉤。
- 這是 Q20 選 2(b)（技術細節可展開）的第一個實際用途——把「本地清單可能過期」這個診斷資訊留在展開區塊裡。

---

### Q25 — 22 個縣市的清單從哪來

**問題**

(a) 寫死為 Dart 常數（來源為官方 spec enum）、(b) 啟動時打一次無參數請求動態取得、(c) (a) + 比對測試。

**已查證的事實**

- F31：不帶 `locationName` 回 22 筆、46KB。
- 需求定義初始狀態為「使用者尚未輸入」，(b) 會讓初始狀態變成「正在載入縣市清單」。
- Q16 已決定 CI 不碰外部服務，(c) 的比對測試只能本機手動跑。

**AI 推薦**

(a)，並在常數旁註明來源 URL 與取得日期。

**我的決定**

(a)

**我的理由**

（推論）行政區劃的變動頻率以十年計，不值得用一次網路往返換即時性，且 (b) 直接違反需求對初始狀態的定義。請校對。

**影響**

- 縣市清單成為 `domain` 層的靜態常數，可離線、零延遲。
- 與上游脫鉤的風險由 Q24(c) 的失敗型別接住。

---

### Q26 — 一次抓一個縣市，還是一次抓 22 個

**問題**

(a) 每次查詢帶 `locationName`（2.5KB）vs (b) 首次抓全部 22 縣市快取（46KB），之後切換縣市不再打 API。

**已查證的事實**

- F31：兩者資料量差 18 倍。
- 需求原文為「點擊確認後**從 API 獲取數據**」，且「讀取中」是需求點名要實作的四個 Widget 之一。

**AI 推薦**

(a)——選 (b) 會讓 loading 狀態在第二次查詢之後幾乎閃不出來，等於把需求指定的交付物做成看不見的東西。

**我的決定**

(a)

**我的理由**

（推論）維持每次查詢都真實打 API，讓讀取中狀態實際可見，對應需求語意與「需求完成度」評分。請校對。

**影響**

- 關掉了任何快取層，資料流保持單向且簡單。
- 每次查詢都會經過完整的四態轉移，widget test 可以覆蓋真實路徑。

---

## 第 5 輪

### 共通事實（本輪查證所得）

| # | 事實 | 來源 |
| --- | --- | --- |
| **F32** | **API 支援 HTTP header 認證——推翻 F2**。實測：`Authorization: CWA-xxxx`（**原始 token，無 `Bearer` 前綴**）→ 200 + 資料；加 `Bearer` 前綴 → **401**；錯誤 token → 401 + 純文字。官方原文：「(2) 在 HTTP header 裡設定屬性 Authorization 的值為會員授權碼」「若同時使用兩種認證方式，則以 HTTP header 的認證為主」 | 實測（2026-08-25）；<https://opendata.cwa.gov.tw/devManual/insrtuction> |
| F33 | CWA 使用規範八(二)：「若發現會員異常使用行為嚴重影響本平臺服務、網路或伺服器，經通知後無改善者，本署將保留隨時終止**會員資格**及使用各項服務資格的權利」——後果不是「token 失效」而是終止會員資格，但有「經通知後無改善」的緩衝 | <https://opendata.cwa.gov.tw/about/rules> |
| F34 | GitHub 的 public events API（`https://api.github.com/events`）即時廣播所有公開 repo 的 push 事件，任何人可訂閱——「沒人來看我的 repo」不等於沒人看得到 | GitHub REST API |
| F35 | 官方授權碼格式範例為 `CWA-1234ABCD-78EF-GH90-12XY-IJKL12345678`（`CWA-` + 8-4-4-4-12，共 40 字元） | <https://opendata.cwa.gov.tw/devManual/insrtuction> |

---

### Q27 — 認證用 header 還是 query param

**問題**

(a) query param（與所有教學、spec、官方範例一致，但 token 進入 URL）、(b) HTTP header（token 不進 URL）、(c) 兩者都送。

**已查證的事實**

F32（見上表）。關鍵推論：Q20 已決定把技術細節（含失敗的 URL）顯示在可展開區塊中——若採 query param，**這個功能會把授權碼印在 app 畫面上**。

**AI 推薦**

(b)——免費拿到的正確性，且讓 README 安全章節有一件「本專案實際做到的事」。

**我的決定**

(b)

**我的理由**

（推論）避免授權碼進入 URL、log 與錯誤畫面，是零成本的正確做法。請校對。

**影響**

- 推翻 F2（「`Authorization` 只能是 query parameter」）。
- Dio 需要以 `BaseOptions.headers` 或 interceptor 帶 token，**且絕不能加 `Bearer` 前綴**（實測會 401）——這是必須寫進註解的反直覺點。
- 錯誤畫面的技術細節可以安心顯示完整請求 URL。

---

### Q28 — token 以什麼形式進 repo

**問題**

Q22 已決定公開授權碼，但「公開」有四種形狀：(a) 硬寫進 Dart 原始碼常數、(b) `AppConfig` 給 `defaultValue`、(c) commit 一個 `dart_defines/reviewer.json`、(d) (c)+(b)。子問題：啟動期 fail-fast 檢查是否保留。

**已查證的事實**

F33（後果可能是終止會員資格，非僅 token 失效）、F34（public repo 的 push 會被即時廣播）。並注意：Q29 將在 README 寫一段「正式專案應如何保護 token」——(a)/(b) 會讓那段文字與原始碼中的明碼憑證直接矛盾。

**AI 推薦**

(c) + (i)——程式碼本體零明碼，架構本身仍是正確的，只是刻意 commit 一個「已知公開、可拋棄」的設定檔。

**我的決定**

(c) + (i) 保留 fail-fast

**我的理由**

（推論）讓「公開 token」是一個可以被指名的取捨，而不是滲透進原始碼的懶惰；保留 fail-fast 則讓設定錯誤在啟動時就以可行動的訊息爆出來。請校對。

**影響**

- `.gitignore` 需加一條例外 `!dart_defines/reviewer.json`。
- fail-fast 的錯誤訊息必須包含**完整的正確執行指令**，讓「爆掉」本身就是說明書。
- 需提供 `.vscode/launch.json`，讓 VS Code 使用者按 F5 即可執行。
- 開啟後續問題：`dart_defines/` 到底要幾個檔（`dev.json` 已成冗餘？）。

---

### Q29 — README 安全說明要寫多深、要多誠實

**問題**

① 深度：(a) 5 條 bullet、(b) 分層論述（本機開發／CI／發佈產物／根本限制）、(c) (b) + 後端 proxy 具體架構。② 誠實度：(a) 只寫理想做法、(b) 明寫本專案取捨。

**已查證的事實**

需求要求 README 須說明 AI 使用方式（`docs/require.pdf`）；評估標準含「需求理解程度」。F32 提供了一個「本專案實際做到的安全措施」（header 認證）可寫進該章節。

**AI 推薦**

1(c)、2(b)，控制在 300–500 字。

**我的決定**

1(c)、2(b)

**我的理由**

（推論）後端解法是我原本就想展示的重點；而不提自身取捨的安全章節讀起來像抄來的。請校對。

**影響**

- README 需新增一個安全章節，內容含：`--dart-define` 是版控衛生而非安全機制、client 端沒有真正的機密、後端 proxy（BFF 持有金鑰、伺服器端 rate limit 與快取、金鑰輪替）、以及本專案刻意公開授權碼的理由與限制。
- 這使 Q22 的決定從「破綻」轉為「可被陳述的取捨」。

---

### Q30 — 靜態分析要多嚴格

**問題**

① 規則集：(a) 預設 `flutter_lints`、(b) `very_good_analysis`、(c) `flutter_lints` + 手選規則 + `strict-casts`/`strict-raw-types`。② 是否加 `riverpod_lint` + `custom_lint`。③ 覆蓋率：(a) 不碰、(b) 產報告不卡、(c) 設門檻。

**已查證的事實**

- F9：`riverpod_lint` 3.1.8、`custom_lint` 0.8.1（2025-09 發版）。
- `very_good_analysis` 含強制 public member 文件註解等風格規則，在十來個檔案的專案中會產生大量與需求無關的噪音。
- Q23 決定嚴格解析，`strict-casts` 是它在型別層面的直接證據。

**AI 推薦**

1(c)、2 加、3(b)。

**我的決定**

1(c)、2 加、3(b)

**我的理由**

（推論）嚴格但不泛濫；既然選了 codegen 就該用官方配套的檢查；覆蓋率報告是展示，門檻會變成為了數字寫測試。請校對。

**影響**

- `analysis_options.yaml` 需自訂，並 exclude codegen 產生的 `*.g.dart`。
- ~~CI 需多一個 `dart run custom_lint` 步驟。~~ 見下方實作期修正。
- CI 需產生 coverage 報告（但不影響成敗）。

**實作期修正（2026-08-25，#1 實作時實測）**

決定 2 的「加 `riverpod_lint` + `custom_lint`」在動手時發現已不可行，修正如下。

| # | 事實 | 來源 |
| --- | --- | --- |
| F41 | `riverpod_lint` 3.1.8 依賴 `analysis_server_plugin` ^0.3.0 與 `analyzer_plugin` ^0.14.0；`custom_lint` 最新版 0.8.1 依賴 `analyzer_plugin` ^0.13.0。兩者版本互斥，`flutter pub get` 直接解析失敗 | 實測 `flutter pub get`；pub.dev API（2026-08-25） |
| F42 | `riverpod_lint` 3.x 已改由 `analysis_options.yaml` 的**頂層 `plugins:` 區塊**安裝，官方 README 不再提及 `custom_lint` | <https://pub.dev/packages/riverpod_lint> |
| F43 | `riverpod_lint` 的規則全部以 `registerWarningRule` 註冊，屬 warning 而非 lint，因此預設即啟用，不需要 `diagnostics:` 區塊逐條開啟 | 讀 `riverpod_lint-3.1.8/lib/main.dart` |
| F44 | **本機工具鏈的 `flutter analyze` 不執行 analyzer plugin**。以缺少 `ProviderScope` 的 `main.dart` 測 `missing_provider_scope` 不報；把 plugin 名稱換成不存在的套件也毫無錯誤，代表整個 `plugins:` 區塊在 CLI 被靜默忽略 | 實測 Flutter 3.47.0／Dart 3.13.0（2026-08-25） |

**修正後的決定**

保留 `riverpod_lint`，改以頂層 `plugins:` 區塊安裝；移除 `custom_lint`。

**理由**

`custom_lint` 不是目的，riverpod 的規則才是；既然上游已經換了安裝機制，跟著換比把 `riverpod_lint` 降版鎖死在舊機制上更合理。

**F44 的缺口要不要補？**

riverpod 規則在 CLI 不生效，選項為 (a) 接受缺口、CI 不把關；(b) 把 `riverpod_lint` 降版鎖回 custom_lint 機制換取 CI 能跑；(c) 自寫檢查步驟模擬。

**我的決定**

(a) 接受缺口，**CI 不把關 riverpod 規則**。

**我的理由**

（推論）riverpod_lint 擋的是「寫錯 Riverpod 用法」這類問題，而這類問題在 IDE 即時回報就會被修掉，排不到需要 CI 再攜一道網；為了這層重複保護而把一個主要套件鎖在已被上游放棄的機制上，代價遠高於收益。請校對。

**影響**

- 取代原「CI 多一個 `dart run custom_lint` 步驟」：CI 的 `analyze` job 只跑 `flutter analyze`。
- **riverpod 規則只在 IDE 生效是已知且已接受的缺口**，不是疏失。理由與實測寫在 `analysis_options.yaml` 的註解裡；若日後 SDK 支援 CLI plugin，不需改設定就會自動補上。
- 連帶修改 #1 的驗收條件（刪去 `dart run custom_lint` 一條）與 #11 的 `analyze` job。

---

### Q31 — 視覺：主題色與深色模式

**問題**

① 主題：(a) `ThemeData()` 完全預設、(b) `ColorScheme.fromSeed`、(c) 完整自訂設計系統。② 深色模式：(a) 明確鎖定亮色、(b) 同時給 `darkTheme` 跟隨系統、(c) 不指定放著。

**已查證的事實**

評估標準第 3 條為「用戶界面的易用性」。Q7 原本排除了「深色模式」這個功能，但使用 `ColorScheme.fromSeed` 時，支援深色僅需多一行。

**AI 推薦**

1(b)、2(b)，並明確指出這是對 Q7 邊界的一次修正。

**我的決定**

1(b)、2(b)

**我的理由**

（推論）一行的成本換來「有人想過配色」的觀感；而不處理深色模式的下場是審閱者的模擬器若開著深色，app 會看起來像沒測過。請校對。

**影響**

- **修正了 Q7 的邊界**：深色模式不再算「額外功能」，而是「把已經做的事做完」。i18n、搜尋歷史等仍然排除。
- 四個 Widget 的 widget test 需確保在兩種亮度下都不會出現硬編碼的顏色。

---

## 第 6 輪（收尾）

### 全案矛盾稽核

在進入最後一輪之前，AI 翻查了 Q1–Q31 並找出六處已被後續決定推翻或需修正之處（第 7 列起為實作期補記）：

| # | 原決定 | 現況 |
| --- | --- | --- |
| 1 | Q2「token 不放進 repo，README 給兩條路」 | 被 Q22／Q28 推翻 → README 改為「token 就在 repo，可換自己的」 |
| 2 | Q2「只有打 API 的 job 傳 secret、fork PR skip」 | 被 Q16 推翻 → CI 完全不碰 secret，skip 邏輯不需要 |
| 3 | F2「`Authorization` 只能是 query param」 | 被 F32 實測推翻 → 改用 HTTP header |
| 4 | Q7「不做深色模式」 | 被 Q31 修正 → 重新歸類為「把已做的事做完」 |
| 5 | Q24 影響欄「失敗由六種變七種」 | **AI 寫錯**，已更正：Q24 是精確命名第 ⑥ 種，總數維持六種 |
| 6 | AI 建立的 `.gitignore` 排除了 `pubspec.lock` | **AI 寫錯**，見 Q34 |
| 7 | Q30「加 `custom_lint`，CI 跑 `dart run custom_lint`」 | 被實作期實測推翻（F41–F44）→ 改用 analyzer plugin 機制，移除 `custom_lint`；見 Q30 的實作期修正 |
| 8 | #11 原文的 `build_runner build --delete-conflicting-outputs` | 被實作期實測推翻（F45）→ 該旗標在 build_runner 2.16.0 已移除；見 Q5 的實作期修正 |
| 9 | Q4／`CONTEXT.md`「三個時段各 12 小時、合計恆為 36 小時」 | 被實作期實測推翻（F47）→ 只有第二、三段是 12 小時，第一段隨查詢時間被截短；36 小時是上限而非恆等式，恆為真的只有「恰好三段」。見 Q4 的實作期修正 |

### 共通事實（本輪查證所得）

| # | 事實 | 來源 |
| --- | --- | --- |
| F36 | Dart 官方：「If your package is an **application package**, you will typically check this into source control. For regular (library) packages, you usually won't.」——本專案是 application package | <https://dart.dev/resources/glossary#lockfile> |

---

### Q32 — `dart_defines/` 到底要幾個檔

**問題**

Q28 選 (c) 之後出現三個語意重疊的候選檔：`dev.json`（gitignored、含真 token）、`dev.example.json`（committed、值留空）、`reviewer.json`（committed、含公開 token）。而 `dev.json` 與 `reviewer.json` 裝的是同一個 token。選項為 (a) 三個都留、(b) 只留 `reviewer.json`、(c) 留 `reviewer.json` + `dev.example.json`。

**已查證的事實**

F24：`.gitignore` 的 `dart_defines/*.json` + `!` 例外規則已實測有效。若刪光 `dev.json` 這類檔案，該規則將無實際守護對象。

**AI 推薦**

(c)——唯一讓三個角色各有不可替代用途的組合：`reviewer.json` 是「跑起來」、`dev.example.json` 是「換成自己的」、`.gitignore` 規則因此是活的。

**我的決定**

(c)

**我的理由**

（推論）保留一個真正在運作的機密守護機制，並讓公開的授權碼成為該機制上一個可被指名的例外。請校對。

**影響**

- 刪除 `dart_defines/dev.json`，新增 `dart_defines/reviewer.json`（進版控）。
- `.gitignore` 需加 `!dart_defines/reviewer.json` 例外。
- README 的執行指令一律指向 `dart_defines/reviewer.json`。

---

### Q33 — CI 要鎖 Flutter 版本嗎

**問題**

(a) 鎖 `3.47.0`、(b) 用 `channel: stable`、(c) 鎖版本並在 `pubspec.yaml` 宣告下限。

**已查證的事實**

F8：本機為 Flutter 3.47.0 stable / Dart 3.13.0。本專案是一次性交付物，不是持續維護的產品——(b) 的好處（自動取得新版）沒有回報，壞處（在無人看管時因上游變動而變紅）卻直接命中交付目的。

**AI 推薦**

(a)。

**我的決定**

(a)

**我的理由**

（推論）這個 repo 的價值在於「被打開來看的那一刻是綠的」，可重現優先於追新。請校對。

**影響**

- CI workflow 明確指定 Flutter 3.47.0。
- README 註明「以 Flutter 3.47.0 開發與驗證」，把版本從隱含變成明示。

---

### Q34 — `pubspec.lock` 要不要進版控

**問題**

AI 先前建立的 `.gitignore` 排除了 `pubspec.lock`，這與官方對 application package 的建議相反。選項為 (a) commit、(b) 維持 ignore。

**已查證的事實**

F36（見上表）。並注意一致性：Q5 已決定 commit codegen 產生檔、Q33 已決定鎖 Flutter 版本，理由都是「審閱者拿到的必須是我驗證過的東西」。

**AI 推薦**

(a)，並移除 `.gitignore` 中的該行。

**我的決定**

(a)

**我的理由**

（推論）與 Q5、Q33 同一條可重現性原則；留著 ignore 是這條線上唯一的破口。請校對。

**影響**

- `.gitignore` 移除 `pubspec.lock`。
- 全案的可重現性策略至此一致：鎖 Flutter 版本、鎖依賴版本、commit 產生檔。

---

### Q35 — 「初始」與「讀取中」兩個 Widget 具體長什麼樣

**問題**

① 初始狀態：(a) 完全空白（忠於需求線框）／(b) 圖示 + 引導文字。② 讀取中：(a) 置中 spinner／(b) spinner + 「查詢中…」文字／(c) skeleton 骨架屏。

**已查證的事實**

- Q18 把逾時放寬到 **15 秒**，「讀取中」可能持續很久。
- 需求要求四個狀態是**可分辨**的四個 Widget；skeleton 會讓「讀取中」與「氣象資料」在視覺上趨同。
- 需求 PDF 內的圖為線框示意，非視覺規格。

**AI 推薦**

1(b)、2(b)。

**我的決定**

1(b)、2(b)

**我的理由**

（推論）空白初始畫面對第一次開啟的使用者是零資訊，引導使用者做出第一個動作正是易用性的核心；15 秒的等待需要文字說明系統仍在運作。請校對。

**影響**

- 初始 Widget 需要一段引導文案與一個圖示。
- 讀取中 Widget 需要文字，且必須是 inline 而非 Dialog（需求明文）。
- 四個 Widget 在視覺上維持明顯可分辨，widget test 可用文字 finder 區分。

---

## 結束

第 6 輪回答完畢後，frontier 清空。唯一未決的是 README 兩題問答與 AI 使用說明的**內容素材**（需結合 kkday 實務經驗，另行處理），該項不阻擋實作。

---

## 第 7 輪（流程補遺）

在確認 Matt Pocock skill 流程（`/to-spec` → `/to-tickets` → `/implement` → `/code-review`）的實際機制時，浮現兩個先前沒被問到的決策。

### 共通事實（本輪查證所得）

| # | 事實 | 來源 |
| --- | --- | --- |
| F37 | `/to-spec` **不產生檔案**，它把規格發佈成一則 GitHub issue（依 `docs/agents/issue-tracker.md` 的「publish to the issue tracker → Create a GitHub issue」）。模板七段：Problem Statement／Solution／User Stories／Implementation Decisions／Testing Decisions／Out of Scope／Further Notes，且明令不得包含檔案路徑與程式碼片段 | `~/.agents/skills/to-spec/SKILL.md` |
| F38 | `/to-tickets` 要求票是**垂直 tracer bullet**：「Each slice cuts a narrow but COMPLETE path through every layer… vertical, **NOT a horizontal slice of one layer**」，且「sized to fit in a single fresh context window」。`/tdd` 也把水平切分列為明確反模式 | `~/.agents/skills/to-tickets/SKILL.md`、`~/.agents/skills/tdd/SKILL.md` |
| F39 | `/implement` 的 SKILL.md 僅六行，**不具備任何並行或背景執行機制**；且 subagent 工具本身也是同步的（「Agents do not run async or in the background」） | `~/.agents/skills/implement/SKILL.md` |
| F40 | `/code-review` 是**純本地**：跑 `git diff <fixed-point>...HEAD`，派兩個平行 sub-agent（Standards 軸帶 Fowler 12 個 code smell 基準、Spec 軸比對規格），把兩份報告印在對話中。**不開 PR、不寫入 GitHub** | `~/.agents/skills/code-review/SKILL.md` |
| F41 | GitHub 的 assignee 只能指派**真實具 repo 權限的帳號**，無法指派虛構的團隊成員 | `docs/agents/issue-tracker.md`（`gh issue edit <n> --add-assignee @me`） |

**同時發現一個我自己造成的問題**：依 F38，我建立的 #1–#13 是水平分層（domain／data／ui），違反 tracer bullet 規則。原因是我照 Q14／Q21 的意圖（展示人類團隊的任務分配）優化，而 `/to-tickets` 優化的是另一個目標（單一 AI agent 在 fresh context window 中工作）。處置：**不重切，改在 #1 之後插入一張端到端最薄的 tracer bullet 票**，用一張票的成本換掉「整合問題留到最後才發現」的風險。

---

### Q36 — 任務分配要怎麼呈現

**問題**

Q14 開 issue 的目的是展示「如何把需求分配給其他 RD」，但 F41 顯示 GitHub 的 assignee 無法指派虛構成員。選項為 (a) 全部 assign 給自己、(b) 在 issue body 寫「建議承接者 + 依據」、(c) 用 milestone／Project 看板分欄。

**已查證的事實**

F41（見上表）。並注意需求問答題 2 的原文是「請舉一個實際發生過的例子，展現你**如何**把需求分配給別的 RD 來實作」——問的是分配的**依據**。

**AI 推薦**

(b)——(a) 的 assignee 欄清一色是自己，等於明說這是單人專案，分配痕跡歸零；而 body 裡的依據才是評審真正要讀的判斷。

**我的決定**

(b)

**我的理由**

（推論）分配的價值在於說得出「為什麼給這個人」，而不是 GitHub 欄位裡的一個名字。請校對。

**影響**

- #1–#13 每張票需補一段「建議承接者」與其依據（風險高低／模組邊界／是否適合熟悉 codebase）。
- assignee 欄位一律留空。

---

### Q37 — code review 的結果要怎麼留痕

**問題**

F40 顯示 `/code-review` 純本地、不寫入 GitHub，而 Q14 已決定不開 PR——因此審查結果只存在於對話視窗，審閱者完全看不到。選項為 (a) 不留痕、(b) 貼成 GitHub issue、(c) 推翻 Q14 開一個 PR 承載、(d) 寫成 `docs/CODE_REVIEW.md`。

**已查證的事實**

F40（見上表）。Q14 已決定不開 PR，理由是單人 PR 的空白 review 欄位反而暴露走過場。

**AI 推薦**

(b)——不推翻 Q14、留在與 #1–#13 同一條 issue 軌跡上，且「審出問題並修掉」的紀錄比「審查通過」更有說服力。

**我的決定**

(b)

**我的理由**

（推論）維持既有的 issue 軌跡一致性，並讓審查的價值以「發現 → 修正」的形式被看見。請校對。

**影響**

- 完成實作後需開一則 `area:docs` issue 承載 review 報告，內容含 Standards 軸與 Spec 軸的發現，以及每一項的處置。
- 維持 Q14（不開 PR）不變。
- 注意：本 repo 沒有 `CODING_STANDARDS.md`／`CONTRIBUTING.md`，Standards 軸將只能依 Fowler smell 基準 + `analysis_options.yaml` + `CONTEXT.md` 的詞彙一致性。依 Q7 的範圍紀律，不另外補寫標準文件。







