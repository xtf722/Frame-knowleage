# 09 从活动等待页理解时间与业务权限

[课程入口](README.md) · [本期来源](../evidence/app-october-source-map.md#time) · [上一期](08-layout-constraints.md) · [下一期](10-async-identity-and-cache.md)

阅读快照：2026-10-26。案例覆盖 10 月 19 日至 26 日活动券、报名、制作和预估时间的演进。本期学习：把服务端事实、页面展示和动作权限分别建模，避免一个 `isReady` 承担所有含义。

先修：[类型与空值](../beginner/04-types-nullability.md)。核心问题：**页面显示的时间到了，为什么仍不能直接开始播放？**

## 同一个活动有多种独立事实

用户拿到券，说明拥有报名凭证；用券成功，说明报名成立；后台进入制作，说明正在生成；媒体 ready，说明交付状态满足一项条件。它们并不在同一瞬间发生。

| 事实 | 在本案例中的作用 | 不能据此推导 |
| --- | --- | --- |
| 原券 available | 可能允许使用原券 | 已完成报名 |
| 原券 used | 报名记录成立 | 后台已开始制作 |
| `preparation_stage` | 解释具体等待或制作阶段 | 视频一定能在某时刻完成 |
| `estimated_ready_at` | 服务端提供的展示预估 | 可以绕过 `can_play` |
| `match_due_at` | 匹配阶段的时间 | 视频制作完成时间 |
| `can_play` 与有效交付清单 | Start 前核验的播放依据 | 照片也已 ready |

项目的 `PawventuresController` 管流程并返回意图，不直接导航或弹窗；模型保留未知枚举并限制操作。这样的分层让 Widget 使用已解释的状态，不在 `build` 中临时拼出报名或播放规则。

## 10 月 26 日新增预估该怎样理解

没有有效服务端 ETA 时，成功页可在首次观察到实际制作阶段后建立本地一小时预估。五宠流程识别 `preparing_images`、`generating`、`postprocessing`；旧模板依据明确的 delivery preparing。collecting、matching、queued 和人工处理不能启动这份预估。

`PawventuresPreparationEstimateStore` 按环境、账号、活动、原券 ID 保存截止时刻。制作阶段切换、刷新和重开复用原时刻；到期就不显示兜底，损坏或存储失败也不显示。服务端 ETA 优先。

这是一项**展示策略**，既不是后台 SLA，也不是播放授权。它使用设备时间计算本地显示预估，因此也不能借它宣称具有服务端校时的可信度。真实权限继续由服务端能力与完整媒体合同决定。

| 教学时序 | 本地截止时刻 | 能否据此播放 |
| --- | --- | --- |
| 10:00 首次观察到 generating | 保存 11:00 | 不能 |
| 10:20 刷新或重开 | 仍为 11:00 | 不能 |
| 10:40 进入 postprocessing | 仍为 11:00 | 不能 |
| 11:00 还未完成 | 隐藏兜底，不改成 12:00 | 不能 |
| 服务端确认可播且完整清单有效 | 使用正式播放条件 | 可进入 Start 核验流程 |

若每次 `build` 都算 `now + 1h`，等待越久预估越往后移，用户永远等不到。把截止时刻保存下来，才使预估具有稳定含义。

## 时间表示也需要明确边界

Unix 秒代表绝对时刻；“账号当地某日零点”还需要时区。Dart `DateTime` 直接表示 UTC 或运行设备本地时间，不能仅靠 `DateTime.parse('2026-10-29')` 就表达任意账号 IANA 时区的零点。[DateTime 官方文档](https://api.dart.dev/dart-core/DateTime-class.html)

本案例在服务端冻结用券时区对应的 `play_available_at`、获券时区对应的 `pass_expires_at`。修改手机时区不能据此延长原券。窗口采用包含起点、不包含终点的约定，终点恰好相等时已不在窗口内。

下面是完整的教学函数，只计算给定 UTC 窗口；不读取设备，不表达任意地区日历，也不替代服务端授权。

```dart
bool insideWindow(int nowSeconds, int startSeconds, int endSeconds) {
  return nowSeconds >= startSeconds && nowSeconds < endSeconds;
}
```

`>=` 包含开始时刻，`<` 排除结束时刻。秒转 `DateTime.fromMillisecondsSinceEpoch` 时需乘 1000，并按用途显式指定 `isUtc`；单位写进变量名能减少三位数量级错误。

## 最少源码阅读顺序

1. `lib/app/pawventures/halloween-timing.md` 的规则表：只比较下载、报名、主题、本人播放四项。
2. `lib/app/pawventures/README.md` 的报名与制作边界：看 ETA 优先级和 Start 条件。
3. `pawventures_preparation_estimate.dart`：读 `canEstimate`、`readOrStart`，跟踪首次写入和过期分支。

停止点：能说清“哪个时间用于什么决策”，不继续展开后台生成服务。owner 中旧测试环境快照有自己的核验日期，不能当作今天在线配置。

## 预测题与反例

本地截止已到，服务端仍返回 `can_play=false`；应该开放按钮、延后一小时，还是隐藏兜底并保留真实等待状态？

<details>
<summary>展开答案与理由</summary>

隐藏兜底并保留真实等待状态。开放按钮会把估算升级成权限，延后一小时会重新定义已经给出的预估。两者都改变了模型含义。回看“展示策略”及首次保存的时序表。

</details>

后端返回未知阶段，同时给出一个看似合理的时间，客户端能否推断为 ready？

<details>
<summary>展开答案与理由</summary>

不能。解析到一个字段不等于拥有动作能力；未知阶段应沿不可操作或明确降级路径处理，不能用时间填补未知权限。

</details>

## 练习与完成标准

运行[离线实验](../labs/app-october/README.md)中的时间场景，再把假时钟推进到恰好一小时、晚一秒和重新进入三种输入。观察同一身份是否保持原截止，以及过期后是否保持为空。

额外纸面练习：为下载、报名、主题、播放各写一行“时间来源＋资格来源＋失败行为”。完成标准是能独立反驳“到点就能播放”和“有券等于报名成功”，并说明哪些状态可由客户端估算，哪些必须服从服务端。

可迁移的经验：订单配送、内容生成、上传处理都应分开“估计什么时候完成”和“是否真的完成”。这是 Flutter 业务状态建模能力，不依赖采用哪一种状态管理库。
