# App 十月进阶课程来源索引

[课程入口](../besideyou-app/README.md#october-series) · [文件指纹](app-october-sources.json) · [复核记录](app-october-validation.md)

取材日期为 2026-10-26，范围为本地 App `2.3.0` 可达历史中的 10 月 9 日至 26 日相关更新，以及读取时的代码与最近 owner。App HEAD 为 `bac983c7ef5041125643acd0cbfbe4a3b3bc4a79`，App 工作树干净；workspace HEAD 为 `bddb92dc16212d1edd4a57517c872b94c8fa89dc`，父工作区有既有变动。本次不修改产品源码。

这些章节按项目难点选题，不认定提交的个人归属。Git 身份、实际协作范围和能力掌握是不同事实，不能把所有案例直接写成个人简历成果。远端 App API 本次未能读取，因此这里明确记录本地快照，不声称已经验证远端分支最新状态。

## 从更新到能力的选题依据

| 更新阶段 | 本地提交线索 | 提炼成的学习问题 |
| --- | --- | --- |
| 10 月 9 日、13 日、23 日 | `da8b88ae0`、`d5f86cd3d`、`690c6845c` | 有限高度、大字号和局部标题栏如何分配空间 |
| 10 月 19 日至 26 日 | `6a5815b74`、`0b346b73d`、`2f9404f0f` | 券、报名、制作、ETA 与播放资格如何分开 |
| 10 月 22 日 | `1e749227b`、`0ba782220` | 新确认不被旧响应回滚，缓存不越过撤销 |
| 10 月 23 日至 25 日 | `d02aaeab6`、`15a6a52b1`、`96f4b339e` | 杀进程后如何恢复原次广告，避免第二笔业务 |
| 10 月 23 日 | `1370d6c8a`、`f6f050109` | 入口额度、优先级和实际可见如何协调 |
| 10 月 21 日至 26 日 | `552601a22`、`414dc2a41` | 场景选曲、播放门禁和多个媒体 owner 如何协作 |

提交用于定位演进，正文描述以读取时的实现为准，不把 commit 标题当作测试结论。日期是项目更新日期，各篇均另外标明阅读日期。

## 使用方法

下列路径相对 App checkout；行号仅供定位，文件 SHA-256 在清单中。先找符号，再读所属方法及清理路径。没有源码权限时仍可通过原创教学例子与离线实验学习，知识库不保存项目源码副本。

<a id="layout"></a>
## 布局约束

[课程](../besideyou-app/08-layout-constraints.md)

| 相对路径 | 搜索符号及首次匹配行 |
| --- | --- |
| `LAYOUT-CONTEXT.md` | `设计与验证证据` L19 |
| `lib/app/widgets/app_adaptive_layout.dart` | `class AppLayoutInfo` L61；`class AppAdaptiveLayout` L159；`class AppFlexibleGaps` L217 |
| `lib/app/besideyou_adaptive_metrics.dart` | `double get tabletFraction` L27 |
| `lib/app/pages/home/home_notification_center_bubble.dart` | `class _HomeNotificationCenterHeader` L277 |
| `test/app/widgets/app_adaptive_layout_test.dart` | `classifies width from available constraints` L6 |
| `TEST.md` | `测试取舍与审查` L15 |

<a id="time"></a>
## 时间与业务权限

[课程](../besideyou-app/09-time-and-capabilities.md)

| 相对路径 | 搜索符号及首次匹配行 |
| --- | --- |
| `lib/app/pawventures/halloween-timing.md` | `时间规则与控制来源` L19 |
| `lib/app/pawventures/README.md` | `报名与制作的接纳边界` L47 |
| `lib/app/pawventures/pawventures_preparation_estimate.dart` | `canEstimate` L28；`readOrStart` L42 |
| `test/app/pawventures/pawventures_preparation_estimate_test.dart` | `production stage transitions retain the first one-hour deadline` L75 |

<a id="async"></a>
## 异步资格与缓存

[课程](../besideyou-app/10-async-identity-and-cache.md)

| 相对路径 | 搜索符号及首次匹配行 |
| --- | --- |
| `lib/app/pawventures/pawventures_controller.dart` | `class PawventuresController` L37；`_checkDetailRevision` L112；`void _accept` L283 |
| `lib/app/pawventures/pawventures_photo_cache.dart` | `class PawventuresPhotoCache` L11 |
| `lib/app/pawventures/README.md` | `结果缓存` L104 |
| `lib/app/widgets/README.md` | `远程图片默认持久缓存` L71 |
| `test/app/pawventures/pawventures_controller_test.dart` | `old list cannot undo a newer used result` L315；`late detail failure cannot replace newer confirmed state with an error` L491 |
| `test/app/pawventures/pawventures_photo_cache_test.dart` | `result identity isolates activities, revisions and photos` L36 |

<a id="recovery"></a>
## 广告持久恢复

[课程](../besideyou-app/11-durable-ad-recovery.md)

| 相对路径 | 搜索符号及首次匹配行 |
| --- | --- |
| `lib/app/gem/README.md` | `## 广告恢复` L125 |
| `lib/app/gem/gem_controller.dart` | `requestReward()` L239；`_recoverReward(` L246；`'display_started': true` L315 |
| `lib/app/gem/gem_operation_store.dart` | `class GemOperationStore` L13；`Future<T> _serial` L60 |
| `test/app/gem/gem_controller_test.dart` | `server verification prevents a second SDK call; late credit is adopted once` L751 |

<a id="popup"></a>
## 弹窗调度

[课程](../besideyou-app/12-popup-scheduling.md)

| 相对路径 | 搜索符号及首次匹配行 |
| --- | --- |
| `lib/app/daily_greeting/README.md` | `冷启动自动弹窗管理` L5 |
| `lib/app/daily_greeting/automatic_popup_request.dart` | `enum AutomaticPopupKind` L5；`entryIdentity` L36 |
| `lib/app/daily_greeting/companion_popup_controller.dart` | `markAutomaticShown` L70；`canContinuePresentation` L53；`_drainPresentation` L167 |
| `test/app/daily_greeting/automatic_popup_budget_test.dart` | `failed or stale candidates leave capacity for the next eligible group` L115 |

<a id="audio"></a>
## 音频场景

[课程](../besideyou-app/13-scene-audio.md)

| 相对路径 | 搜索符号及首次匹配行 |
| --- | --- |
| `lib/app/audio/background_music_scene.dart` | `class BackgroundMusicScene` L11；`didPushNext` L85 |
| `lib/app/audio/background_music_controller.dart` | `setForegroundPlayback` L324；`_syncResource` L225；`_playIfAllowed` L212 |
| `lib/app/pawventures/README.md` | `## 万圣节 BGM` L215 |
| `test/app/audio/background_music_scene_test.dart` | `ordinary pages cover and restore an eligible seasonal scene` L77 |



## 来源限制与官方资料

本索引只记录为课程关键结论读取的文件与片段，不宣称完成模块全量审计。测试文件用于解释反例；产品测试、后端、设备、广告平台和发布状态不由本次阅读证明。旧 owner 中“公告未开放”等历史句子与后续公告接线记录并存，课程不据此判定今天的线上开放状态。

2026-10-26 打开核对以下官方页面，用于基础语义：Flutter [约束](https://docs.flutter.dev/ui/layout/constraints)、[mounted](https://api.flutter.dev/flutter/widgets/State/mounted.html)、[RouteAware](https://api.flutter.dev/flutter/widgets/RouteAware-class.html)、[测试层次](https://docs.flutter.dev/testing/overview)，Dart [异步](https://dart.dev/libraries/async/async-await)、[DateTime](https://api.dart.dev/dart-core/DateTime-class.html)。官网是动态文档，涉及具体 SDK 行为时应再核对项目锁定版本；本系列不据此建议升级依赖。

新清单独立核验：

```sh
python tools/verify_knowledge.py --manifest evidence/app-october-sources.json --source-root /path/to/besideyou-flutter
```

历史 `app-sources.json` 不随这次更新重写。发现漂移后应重读对应旧课程；不能只替换 hash，让历史快照冒充当前状态。
