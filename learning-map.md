# 先学什么：从症状倒查知识

[返回首页](README.md)

已有项目经验、想整理技术亮点与面试案例时，走 [技术博客](articles/README.md) → [面试准备](interview/README.md)。需要补写法时再回到基础课。

先选择合适的阅读层级。写法不熟时先做小例子；能够读懂一个方法后，再追模块调用链。

## 根据起点进入

| 现在的困难 | 入口 | 这次做到哪里就停 |
| --- | --- | --- |
| 回调、await、尖括号和问号也不熟 | [01–04 基础写法](beginner/README.md) | 预测一个短程序并改动一行 |
| 不知道 State、build、参数变化怎样配合 | [05–08 Flutter 页面](beginner/05-widget-state.md) | 解释一次按钮点击和等待后的显示 |
| 单个方法能看，但跨文件容易迷路 | [11 只追一个动作](beginner/11-source-reading.md) | 找到一个入口、一个分支、一个结果 |
| 基础写法已能运用，想理解模块难点 | 下方专题地图 | 只追一条正常路径和一个失败分支 |

## 基础能够运用后的专题顺序

```mermaid
flowchart TD
  A[生命周期总览] --> B[异步与生命周期基础]
  B --> C[Portrait 专题]
  B --> D[Wi-Fi 专题]
  C --> E[媒体与渲染基础]
  C --> F[Moment 专题]
  F --> G[缓存与数据身份基础]
  D --> H[网络与 Android 基础]
  H --> I[App Update 专题]
  I --> J[更新与跨系统一致性基础]
  J --> K[跨模块故障推演与复习]
  G --> K
```

这张图用于专题阶段，不是初学第一天的任务。先通过 [自学课程](beginner/README.md) 的相关练习，再读 [生命周期总览](lifecycle-map.md)。进入模块之前可选对应的 [短导读](beginner/README.md)，一次只看一个行为。

## 根据问题选择阅读入口

| 我解释不清的问题 | 先读专题 | 再补基础 | 合上文档后的产物 |
| --- | --- | --- | --- |
| 为什么只是切设置回来，视频可能被重建？ | [Portrait](modules/portrait.md) | [异步与生命周期](foundations/async-lifecycle.md) | 画出页面、session、native surface 的不同生存期 |
| 为什么播放状态是 playing，画面仍可能没出来？ | [Portrait](modules/portrait.md) | [媒体与渲染](foundations/media-rendering.md) | 区分逻辑信号与可见帧证据 |
| 为什么有网、有缓存，仍不能显示指定宠物？ | [Moment](modules/moment.md) | [缓存与身份](foundations/storage-identity.md) | 列出授权身份与资源可用性的独立条件 |
| Gallery 的列表和自动播放列表为什么不同？ | [Moment](modules/moment.md) | [缓存与身份](foundations/storage-identity.md) | 用输入、过滤、输出解释两个读模型 |
| Wi-Fi 图标连接了，为什么后端请求仍失败？ | [Wi-Fi](modules/wifi.md) | [网络与 Android](foundations/networking-android.md) | 给每一层证据写一句“能证明 / 不能证明” |
| 页面退出后，为什么迟到的读取还会影响新状态？ | [Wi-Fi](modules/wifi.md) | [异步与生命周期](foundations/async-lifecycle.md) | 用 generation 复现并拦截旧结果 |
| 更新下载完了，为什么还不能说安装成功？ | [App Update](modules/app-update.md) | [更新与一致性](foundations/updates-trust.md) | 画出下载、校验、commit、回执、身份回读 |
| Retry 为什么不能统一“重新再来一次”？ | [App Update](modules/app-update.md) | [更新与一致性](foundations/updates-trust.md) | 分清确定失败和结果未知 |

## 如何知道自己卡在哪一层

1. **看不懂语法**：先解释 `await`、closure、枚举、Stream、nullable 的语义，再回源码。
2. **认得类名但串不起来**：只追一个用户动作，写 5–8 个节点，不遍历整个目录。
3. **知道正常流程但不会排障**：选一个 `await`，假设在等待期间切宠物、离开页面或断网。
4. **会修当前 bug 但不能迁移**：把宠物替换为搜索词，把 APK 安装替换为支付提交，检查哪些不变量仍成立。

## 优先内化的四个问题

每读完一篇，口头回答：

- 谁拥有这个状态，谁只有读取权？
- 哪个事件会使旧结果失去提交资格？
- 失败后哪些数据保留，哪些事实要重新读取？
- 这项证据到底证明到了哪一层？

继续：[复习计划](review/plan.md) · [个人复盘模板](review/note-template.md)
