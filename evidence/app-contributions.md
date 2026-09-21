# BesideYou App：负责范围与 Git 证据

[App 学习目录](../besideyou-app/README.md) · [来源说明](README.md)

读取日期：2026-09-21。用户明确要求“看 Git，我提交的部分就是我负责的部分”，因此本次以其确认的提交身份 `xtf722` 筛选，再查看文件差异决定课程范围。作者字段是本次约定的检索依据，不推导团队其他成员的分工，也不据此宣称整座 App 由一人开发。

## 本次纳入什么

当前 App HEAD 为 `78a0855fdb44a066ee836bbf3f9cf1e20621e17f`。该 HEAD 可达的 `xtf722` 非 merge 提交共 **5 项**，范围是 Portrait 画幅与背景、触摸教学、教学完成记忆、Home 本机资源准备与 Basic 升级返回，以及本地预览入口隔离。

启动、认证、路由、API、缓存和共享播放器是理解这些改动所需的上下游基础。课程会解释它们怎样传递数据，但不把相关模块的全部实现归为用户独立开发。Frame app 的 Wi-Fi、Moment 和设备更新仍属于原有 Frame 专题。

App 读取时有 4 个未提交文件：`docs/README.md`、`tool/app_harness/checker.dart`、`tool/app_harness/document_support.dart`、`tool/app_harness/self_test.dart`。本次贡献归属依据已提交差异，不把这些工作区改动计入作者贡献；课程来源文件另外记录 SHA-256，避免把 HEAD 当作整个工作区的精确备份。

## App 的 5 项提交

下表日期为 Git 作者日期，供回查使用，不代表需求提出日、上线日或验收日。文件数与增删行是提交差异的定位信息，包含文档、测试和生成文件，不用于衡量工作量。

| 日期 / 提交 | 原提交主题 | 差异范围与课程落点 |
| --- | --- | --- |
| 2026-09-15 · `c722bf202f69705c5587300994f9708ba1e096e2` | `feat(portrait): 添加静态模糊背景与居中圆角画幅` | 10 文件，新增 763 行、删除 123 行。`pet_space_interactive_view.dart`、`pet_space_portrait_stage.dart` 与相关测试：从 active runtime 的 `idleStill` 派生背景；背景、poster、ready dependencies 同批发布；画幅、圆角和触摸投影保持一致；旧图片回调不得覆盖新内容。 |
| 2026-09-17 · `ad9ec9cf09b85156f19d1910c48e6b4a56dbad1d` | `feat(pet-space): 增加 Portrait 长按引导并移除互动页名称` | 16 文件，新增 983 行、删除 22 行，含 4 张引导图片。新增 `pet_space_portrait_guide.dart` 和 `pet_space_portrait_guide_controller.dart`，接入 Host 实际播放观测、500ms Hold 判定及取消分支；互动页移除名称，Free static 名称保持其独立职责。此提交中的“每次进页重教”已被后续账号持久化改动替代。 |
| 2026-09-18 · `78498aae35eac4c87a19e08e601ff301b9e7b3ca` | `fix(debug): 完善本地升级预览并守住正式入口隔离` | 9 文件，新增 54 行、删除 21 行。`main.local.dart` 的 mock loader 使用 `BESIDEYOU_MOCK_FORCE_UPDATE` 选择本地更新 gate；补齐 ready fixture 的 `spaceLifecycle`。讲解依赖注入、编译环境开关和假数据边界，不把它描述为线上更新功能实现。 |
| 2026-09-18 · `f840d78832469d8eef5ce73c1dad064be00ac639` | `feat(home): 完善 Portrait 加载胶囊与 Basic 升级返回链路` | 23 文件，新增 2802 行、删除 91 行。`home_portrait_preparing.dart`、`home_root_page.dart`、`home_tab_shell.dart`、`pet_space_priority_prewarmer.dart` 及对应测试：完整可加载宠物队列、真实可确定进度、逐项完成/Retry、浮层互斥、Basic Paw 分流，以及套餐返回后的同账号/同队列复验。 |
| 2026-09-20 · `78a0855fdb44a066ee836bbf3f9cf1e20621e17f` | `fix(portrait): 按账号持久化教学进度并限定教学期间闻动作` | 10 文件，新增 1123 行、删除 17 行。新增 `pet_space_portrait_guide_progress.dart`，更新 InteractiveView 与 guide controller：按认证 `subjectId` 持久化完成事实；账号内跨宠共享；未读取完成记忆前关闭触摸；教学未完成时选择可播放 `middle.base`；完成后恢复正常分区选择；隔离旧账号读写和旧 source 的成功反馈。 |

表中 `pet_space_*.dart` 位于 `lib/app/pages/pet_space/`，`home_*.dart` 位于 `lib/app/pages/home/`，`pet_space_priority_prewarmer.dart` 位于 `lib/app/space/`。当前行为以课程对应的来源清单及最近 owner 为准，不能把不同日期的规则混用。

## 为什么不能把 `git log --all` 的 10 条都算成贡献

本次 `--all` 的作者筛选结果还包含以下记录：

| 记录 | 处理理由 |
| --- | --- |
| `66e6dc3b17a913f6a921d9fd8e046c36945a0b90` | 另一引用中的账号教学提交。与当前 HEAD `78a0855f...` 的 `git patch-id --stable` 同为 `b660a06d519f8a7a305d840652a32335d3026efa`，属于同一补丁的两个提交身份，本次只保留当前 HEAD 的版本。 |
| `66d046a58adb22b2f8b238bb153f4c548641dba6` | `merge: 同步 main 并合入 Portrait 展示优化`。它在当前 HEAD 历史中，是整合记录；课程从已查看的具体非 merge 差异定位功能，不把该 merge 再加算成一项新功能，也不据此推断其中一定没有冲突处理。 |
| `1215d3ef6eeaae915581a8a31e835145ff92240b` | stash 的工作区保存记录，主题为 `On xtf: codex-preserve-xtf-before-main-sync-20260916`，不是普通交付提交。 |
| `a1f7e834c318a952c1aacdf067194952bb071b96` | 同一 stash 的 index 保存记录。 |
| `90a7e16aa4eaa04cafd49219f2ef832d5b4e3ce4` | 同一 stash 的 untracked files 保存记录。 |

因此本次范围是 **5 项当前 App 功能/修复提交及必要的共享依赖**。这不是用户职业经历或所有分支贡献的总计；没有 fetch、遍历远端服务器或寻找其他作者别名。

## App 课程需要的共享播放器提交

共享包属于 workspace 仓库，读取时 HEAD 为 `f21b1bb0ecb3bc44ed672781c1657ddcdb28cf90`。不要把它们的提交号放进 App 仓库执行 `git show`，也不要把共享包贡献称作 App 私有实现。

| 日期 / workspace 提交 | 原提交主题 | 与本次 App 内容的关系 |
| --- | --- | --- |
| 2026-09-17 · `b236912c276fbea1977e7f50f59273c0f6ffdc80` | `feat(portrait): 提供实际播放观测并处理恢复与跨段中断` | 6 文件，新增 357 行。`LiveSegmentDriver.segmentActivity`、backend 的实际队列/playing 观测和 `PortraitPlayerLiveHost.onInteractionStatusChanged`，为 App 教学区分“已请求 Hold”与“实际正在播 Hold”提供依据；跨段中断与恢复让教学计时及时取消。教学文案和 500ms 规则仍由 App 持有。 |
| 2026-09-20 · `9822bbeed28962faa33687fcc250e6b43d607f43` | `feat(portrait): 支持教学期间覆盖有效触摸动作` | 3 文件，新增 120 行、删除 3 行。Host 新增 `pointerDownBindingOverride`，只重定向已经有效命中的 Down；校验候选可播放后再确认指针归属。App 用它表达教学期间的动作选择，共享 Host 不保存账号完成记录。 |
| 2026-09-20 · `f21b1bb0ecb3bc44ed672781c1657ddcdb28cf90` | `fix(tiny-player): 修复 Android 队列替换导致播放意外结束` | 7 文件，新增 238 行、删除 17 行。`TinyPlayerPlayerHost.handleReplaceUpcoming` 使用队列替换，避免移除旧后继到追加新后继之间的空窗；非末项 `STATE_ENDED` 显式失败。它是 App 与 Frame 共同使用的底层可靠性补充，不证明问题只发生在手机 App。 |

在当前 workspace HEAD 上，对这两个共享包按同一作者筛选，共找到 9 项非 merge 提交。其中另 6 项是 2026-09-11 的共享播放器历史：`175928abc5d04028a37c5c2439e38fbacfbd674c`、`7a656e7b0d017d379b929a3a47e707bcd26f8a59`、`718af6eba469813bea281518e172034366f873b3`、`83d280943edb518e423b2218a110aedb721a9089`、`d4e52a9c088582f8b4477205dc32465922c8f052`、`fd62bb5f4722f9af20cecb06c5c89078c08d6cd4`。本次不把它们合并为 6 项新的 App 功能；原 Frame 课程已有相关共享生命周期讨论。`--all` 另出现的 `b34371c12a63f0929bfdfc91b3c3cd0b8d1d0e0b` 是 untracked files stash 记录，同样排除。

## 在自己的 checkout 里复核

在 App 仓库根目录执行下列只读命令。示例仅输出日期、SHA 和主题，不输出邮箱：

```shell
git rev-parse HEAD
git status --short
git log HEAD --no-merges --author=xtf722 --date=short --format="%H %ad %s"
git log HEAD --merges --author=xtf722 --date=short --format="%H %ad %s"
git log --all --author=xtf722 --date=short --format="%H %ad %s"
git show --format= --stat 78a0855fdb44a066ee836bbf3f9cf1e20621e17f
git show --format= f840d78832469d8eef5ce73c1dad064be00ac639 -- lib/app/pages/home/home_root_page.dart
git show --pretty=format: --no-ext-diff 78a0855fdb44a066ee836bbf3f9cf1e20621e17f | git patch-id --stable
git show --pretty=format: --no-ext-diff 66e6dc3b17a913f6a921d9fd8e046c36945a0b90 | git patch-id --stable
```

共享包在上两级 workspace 仓库中：

```shell
git -C ../.. rev-parse HEAD
git -C ../.. log HEAD --no-merges --author=xtf722 --date=short --format="%H %ad %s" -- packages/besideyou_client_core packages/tiny_player
git -C ../.. show --format= 9822bbeed28962faa33687fcc250e6b43d607f43 -- packages/besideyou_client_core/lib/src/portrait_player/presentation/portrait_player_live_host.dart
```

若自己授权的 checkout 提示 Git ownership 错误，应先确认目录确实可信，再按本机规则处理；公开命令示例不包含个人绝对路径或全局信任配置。

## 证据能证明到哪里

本次执行了只读 Git 查询、查看差异与当前源码取材。提交中已有的测试文件和 owner 中的旧验收记录是阅读线索；本次未重跑产品 Flutter 测试，未构建/安装 App，未调用后端或执行真实购买、账号、设备操作。

Git 差异证明改了哪些文件和逻辑，不能单独证明线上效果、原生播放观感、性能收益或个人工作的全部过程。课程中的时序图、状态表和预测题是基于源码的教学推导；用户可据此练习解释自己的工作，再用实际经历补充发现问题与验收的过程。
