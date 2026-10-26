# 来源与复核

App 进阶六期使用独立的 [2026-10-26 来源索引](app-october-source-map.md)、[来源清单](app-october-sources.json)和[复核记录](app-october-validation.md)。这是后续项目更新的学习快照，不覆盖下面的历史采集记录，也不扩张个人贡献范围。

手机端课程单独进入 [App 来源索引](app-source-map.md)、[App 清单](app-sources.json)、[负责范围与 Git 证据](app-contributions.md)和 [App 复核记录](app-validation.md)。它与下述 Frame 快照分开维护，使用自己的 App 源码根目录。

2026-09-14 的技术博客使用独立的 [来源索引](blog-source-map.md)、[清单](blog-sources.json)、[提交线索](contribution-history.md) 和 [验证记录](blog-validation.md)。下面继续说明原专题快照，不能把两次取材日期合并。

[返回首页](../README.md) · [源码检索索引](source-map.md) · [来源清单](sources.json) · [首次专题验证](validation.md) · [入门课程验证](beginner-validation.md)

## 这份快照代表什么

专题取材于 2026-09-09 的 Frame 源码工作区和相关共享包。源项目当时有未提交改动，所以 **HEAD commit 不能单独重建此次读取内容**。sources.json 保存各文件的 SHA-256，便于以后检查漂移；它不保存、也不能还原文件内容。

因此来源记录提供的是路径、内容指纹和取材关系。若本地旧内容已丢失且未提交，只有 hash 无法恢复历史文件。需要严格历史重建时，应由源项目自己的版本管理保存经审查的源码版本。

公开知识库不携带项目源码。正文中的源码链接进入 source-map，告诉你在已有授权的项目 checkout 中打开哪个相对文件、搜索哪些符号；这些链接不会假装在公共 GitHub 上可以直接看到私有源码。

## 来源分工

| 来源 | 用途 | 边界 |
| --- | --- | --- |
| 当前项目源码 | 解释本次读取的实现 | 不证明已安装 APK 或真实服务行为 |
| 最近模块 README / owner | 定位当前行为与验证入口 | 历史段落不能自动升级为当前结果 |
| 现有测试文件 | 阅读反例、输入和断言 | 测试存在不表示本轮执行通过 |
| 官方技术文档 | 解释通用机制 | 动态页面可能晚于项目 SDK/Android 版本 |
| 教学图、问题、labs | 提炼理解和可控反例 | 不代替产品代码或真实集成验证 |

参考组织结构来自 [zyyziyunying/KnowledgeBase](https://github.com/zyyziyunying/KnowledgeBase) 的本地副本 `dae3470e61f8d6232454d02a67e812e304998c49`。该副本的 origin 已核对；本次网页抓取失败，因此不声称其内容是远端最新版本。只借鉴索引、专题和证据分工，没有复制其 Framework 讲义。

基础卡中的官方网页于 2026-09-09 打开核对，保留直接链接和版本限制，不镜像全文或给动态网页计算“固定源码 hash”。

2026-09-10 增加的入门课程和短导读，分别使用通用教学模型和已有专题快照；其代码执行、导航及来源复核记录放在 [课程验证](beginner-validation.md)。新增导读的取材关系补入清单，原始采集日期和内容指纹保持不变。

## 如何复核

没有源码也可以在知识库根目录检查导航：

```shell
python tools/verify_knowledge.py
```

若有源项目，将命令参数换成你自己的 Frame app 根目录：

```shell
python tools/verify_knowledge.py --source-root /path/to/frame-app
```

共享包路径以 Frame app 为基准记录为 `../../packages/...`，需要保留原工作区布局。工具只读这些文件，不修改项目。外部官网链接不在离线可达性检查范围内。

- 返回 `0`：本次请求的静态检查通过。
- 返回 `1`：结构、来源或内部链接有错误。
- 返回 `2`：来源内容漂移，需要重读相关代码和专题。

hash 相同只表明字节相同，不证明讲解一定正确；hash 不同也不意味着每条结论都失效。先看 source-map 中的引用专题，再进行定向复核，不能直接刷新 hash 消除提示。

新博客的定向复核使用 `python tools/verify_knowledge.py --manifest evidence/blog-sources.json --source-root /path/to/frame-app`；不传 `--manifest` 时仍检查原 `sources.json`。2026-09-14 原快照已有 5 项漂移，详情留在博客验证记录；本次没有覆盖旧采集记录。
