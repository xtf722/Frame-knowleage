# 负责范围与提交线索

[技术博客目录](../articles/README.md) · [面试准备](../interview/README.md) · [当前阅读来源](blog-source-map.md)

责任范围依据：作者确认，自 2026-08-14 起相框主要模块基本由其负责，包含 Portrait、Moment、Wi-Fi 和更新。本文据此组织案例；具体个人分工、发现问题的过程和验收结果，仍由作者按真实经历补充。

下面是 2026-09-14 从相应仓库读取、并查看相关文件差异后的精选线索。它们证明改动内容，不是用提交作者字段自动推断个人贡献；没有收录姓名、邮箱、私有仓库 URL 或设备日志。

## 精选的技术演进

| 模块 | 仓库 / 提交 / 记录日期 | 差异支持的内容 | 用来回忆什么 |
| --- | --- | --- | --- |
| Portrait | Frame app `a6c92f51cf44` · 2026-09-09 | 路由播放身份移除缓存 phase，Stage 与资源映射补充连续性处理 | 为什么缓存完成不应等于新播放会话 |
| Portrait | workspace `175928abc5d0` · 2026-09-11 | 共享 Host 固定媒体槽位，并通过 AnimatedBuilder.child 保留媒体子树 | 为什么 key 稳定仍要检查实际子树和依赖身份 |
| Moment | Frame app `a94d28c` · 2026-08-24 | 视频配置 generation、启动参数捕获和晚到配置回归 | 用户已经切换，旧异步任务怎么办 |
| Moment | Frame app `6276bc8` · 2026-09-11 | cache-first 队列、媒体身份比较与连续性回归 | 内容没变、来源变化时该保留什么 |
| Wi-Fi | Frame app `25f7018a3970` · 2026-09-03 | 启动准入开关、保存网络恢复观察、宿主边界拆分 | 为什么 Android 恢复网络与业务导航分开 |
| Wi-Fi | Frame app `a6c92f51cf44` · 2026-09-09 | 状态 observer 与对应测试 | 超时后为什么保留 pending、撤销旧显示 |
| 更新 | Frame app `99325758f6a5` · 2026-09-01 | 更新控制器、下载器与 Android host 接入 | 如何把跨层流程拆成可恢复状态 |
| 更新 | Frame app `8519a388fb34` · 2026-09-07 | Kiosk 安装准备失败时保留已下载 APK | 哪种失败应重试准备，而不重新下载 |
| 更新 | Frame app `a6c92f51cf44` · 2026-09-09 | 网络准入、重新回读安装条件、安全 Retry 与不确定提交处理 | 为什么“未知”必须单独表达 |

日期按日志显示，仅用于查找；整合提交可能包含多项工作，不是精确事故发生时间，也不能证明每个相关想法都首次产生于当天。当前文章只讲各行对应的技术切片。

## 在自己的授权 checkout 中回看

以下为只读命令示例。Frame app 是独立仓库，先进入其根目录：

```shell
git log --since=2026-08-14 --date=short --format="%h %ad %s" -- lib/src/features/wifi
git show 25f7018a3970 -- lib/src/features/wifi/frame_wifi_design_page.dart
git show a6c92f51cf44 -- lib/app/route/frame_routes.dart
```

共享 `besideyou_client_core` 的相关提交属于 workspace，从 Frame app 根目录使用：

```shell
git -C ../.. show 175928abc5d0 -- packages/besideyou_client_core/lib/src/portrait_player/presentation/portrait_player_live_host.dart
```

公共知识库只给检索入口，不复制项目源码。源码缺失时仍可读博客，但不能把 hash 或短提交号当作可还原所有工作区内容的备份。

## 把线索补成自己的故事

先找一条自己记得清楚的改动，补三句话：当时观察到什么；自己为什么改这一层；最终怎样确认行为。记录输入和结果比单独列测试数量更容易经受追问。

没有一致条件下的前后测量，就使用能证实的行为描述，例如“旧请求不能再覆盖新选择”“缓存来源更新保留当前计时”，不要补一个看起来好看的性能百分比。
