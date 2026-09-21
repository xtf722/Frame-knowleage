# Frame 与 BesideYou App 项目学习知识库

从做过的项目里提炼可以解释、复现和迁移的知识。Frame 重点学习 **Portrait、Moment、Wi-Fi、App Update**；手机端 BesideYou App 按自己的提交整理 **Home、Portrait 展示、触摸教学与本地预览**，并沿着具体问题补齐 Dart、Flutter、Android 和网络基础。

这里的目标是：合上文档后，能说清一条链路由谁持有状态、什么时候失效、失败后保留什么，以及下一次先去哪里查。

## 从这里开始

学习自己负责的手机端开发，进入 [BesideYou App 专题](besideyou-app/README.md)：从基础写法和数据流开始，再追 Home 加载与升级返回、Portrait 舞台、长按教学和 Mock 隔离。负责范围由独立的 [App 提交证据](evidence/app-contributions.md)说明。

准备把项目经历讲成技术博客或面试案例，可以直接进入 [技术博客系列](articles/README.md) 和 [面试准备](interview/README.md)：围绕真实问题讲清实现、取舍、失败恢复与验证。

如果 `async/await`、回调、State、泛型等写法本身也不熟，从 [自学课程](beginner/README.md) 开始。每课都有短例子、逐句解释、预测题、折叠答案和修改练习；可以连续自学，不需要每答一题等 AI 回复。

1. [自学课程](beginner/README.md)：先读懂写法，再理解页面，最后一次只追一个 Frame 动作。
2. [学习地图](learning-map.md)：按自己当前的问题选择课程、短导读或原模块专题。
3. [生命周期总览](lifecycle-map.md)：学完基础生命周期后，再比较跨模块的六种生存期。
4. [练习运行方法](labs/beginner/README.md)：运行完整示例；文档里的方法片段则按标注位置阅读。
5. 用 [复习计划](review/plan.md) 和 [复盘模板](review/note-template.md) 记录自己的解释，不按固定天数赶进度。

## Frame 四个核心专题

| 专题 | 主要练习的问题 | 入口 |
| --- | --- | --- |
| Portrait | 如何保持播放连续，又让旧异步任务失去修改新画面的资格？ | [实现与生命周期](modules/portrait.md) |
| Moment | 内容同步、缓存、图片计时和视频播放如何组成一条链？ | [实现与生命周期](modules/moment.md) |
| Wi-Fi | 扫描、连接、网络状态和服务可达性怎样分别判断？ | [实现与生命周期](modules/wifi.md) |
| App Update | 下载、安装、进程替换和事件回报怎样恢复并安全重试？ | [实现与生命周期](modules/app-update.md) |

`Portrait` 是代码中的拼写；检索时不要使用 `potrait`。Moment 的产品名与源码名映射在其专题开头说明。

## 查漏补缺

| 不熟悉的知识 | 基础卡 |
| --- | --- |
| `Future`、`await`、State、Key、generation、dispose | [异步与生命周期](foundations/async-lifecycle.md) |
| 播放器、Surface、首帧、合成、性能证据 | [媒体与渲染](foundations/media-rendering.md) |
| SSID、网络分层、权限、Device Owner、MethodChannel | [网络与 Android 边界](foundations/networking-android.md) |
| identity、revision、缓存、Range、提交资格 | [缓存与数据身份](foundations/storage-identity.md) |
| hash、签名、安装 session、幂等、ACK 丢失 | [更新与跨系统一致性](foundations/updates-trust.md) |

基础写法还可以查 [语法桌](beginner/syntax-desk.md)。[Dart 学习实验](labs/README.md) 包括入门练习与旧结果、事件重放的进阶实验，按课程入口选择即可。

## 内容与依据

专题是注明日期的**实现学习快照**，不是产品要求或持续更新的验收台账。当前行为回到项目最近的模块 README，当前代码通过 [源码检索索引](evidence/source-map.md) 定位；[来源记录](evidence/README.md) 解释版本、文件哈希与证据限制。

讲解中区分三种内容：**源码事实**说明此次读取到的代码；**教学推导**说明从代码提炼的通用方法；**练习 / 待验证**不代表已经运行或经过硬件验收。

组织方式参考 [zyyziyunying/KnowledgeBase](https://github.com/zyyziyunying/KnowledgeBase)：索引负责导航，专题解释机制，证据记录来源。本文库的讲解和实验围绕项目另行编写，参考版本说明见来源记录。

维护入口：[AGENTS.md](AGENTS.md)。这里不设置自动提醒；复习计划由你自行安排。
