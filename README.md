# Frame 项目学习知识库

从做过的项目里提炼可以解释、复现和迁移的知识。重点学习 **Portrait、Moment、Wi-Fi、App Update**，并沿着具体问题补齐 Dart、Flutter、Android 和网络基础。

这里的目标是：合上文档后，能说清一条链路由谁持有状态、什么时候失效、失败后保留什么，以及下一次先去哪里查。

## 从这里开始

1. [学习地图](learning-map.md)：按问题选择专题，先建立四条链路的联系。
2. [生命周期总览](lifecycle-map.md)：把 Widget、路由、业务 session、App、原生资源和进程分开。
3. 选一篇专题，边读边在源码中搜索文中的 English identifiers。
4. 遇到不懂的概念，跳到对应基础卡；回来完成专题自测。
5. 用 [复习计划](review/plan.md) 和 [复盘模板](review/note-template.md) 记录自己的解释。

## 四个核心专题

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

还有两个不依赖 Flutter 的 [Dart 学习实验](labs/README.md)，用可控顺序观察“旧请求覆盖新状态”和“回包丢失后的同事件重放”。

## 内容与依据

专题是注明日期的**实现学习快照**，不是产品要求或持续更新的验收台账。当前行为回到项目最近的模块 README，当前代码通过 [源码检索索引](evidence/source-map.md) 定位；[来源记录](evidence/README.md) 解释版本、文件哈希与证据限制。

讲解中区分三种内容：**源码事实**说明此次读取到的代码；**教学推导**说明从代码提炼的通用方法；**练习 / 待验证**不代表已经运行或经过硬件验收。

组织方式参考 [zyyziyunying/KnowledgeBase](https://github.com/zyyziyunying/KnowledgeBase)：索引负责导航，专题解释机制，证据记录来源。本文库的讲解和实验围绕 Frame 另行编写，参考版本说明见来源记录。

维护入口：[AGENTS.md](AGENTS.md)。这里不设置自动提醒；复习计划由你自行安排。
