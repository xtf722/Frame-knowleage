# 技术博客整理与复核记录

日期：2026-09-14。范围：四篇技术博客、面试准备、相关导航和独立来源清单。

[博客目录](../articles/README.md) · [来源清单](blog-sources.json) · [源码索引](blog-source-map.md) · [提交线索](contribution-history.md)

## 本轮做了什么

- 定向阅读 Portrait、Moment、Wi-Fi、App Update 当前源码、最近模块 owner 与相关测试，按技术冲突、机制、取舍和反例组织文章。
- 根据作者确认的主要负责范围，查看 2026-08-14 之后的相关提交及文件差异，组织讲述提纲和候选简历表达。
- 新文章使用独立 `blog-sources.json`，保留原 2026-09-09 `sources.json`；没有用新 hash 覆盖旧学习快照。
- `verify_knowledge.py` 增加 `--manifest`，允许明确选择要复核的来源快照；不传时保持原来的选择。

## 旧快照为什么有漂移

本轮初查原清单：38 篇 Markdown、内部结构和链接错误 0，来源 `DRIFT=5`。这意味着以下文件的当前字节与旧采集不同，不表示知识库中每条旧结论都错误：

| 原来源 | 变化含义 |
| --- | --- |
| 共享 Portrait controller | 当前实现已演进，旧专题按原日期阅读 |
| 共享 Portrait reducer | 同上，修改功能前回当前源码 |
| 共享 live_segment_driver | 同上，不用历史摘要替代当前状态机 |
| tiny_player 当前播放路线 owner | 最近文档已更新，按当前 owner 查验收边界 |
| Frame `TEST.md` | 文档职责与验证入口已调整 |

详细路径仍在[原来源索引](source-map.md)中。本次博客只为实际读取并引用的文件建立新记录，不批量改写旧专题或旧验证结果。

## 可复核命令

在本知识库根目录检查内部导航和新博客清单：

```shell
python tools/verify_knowledge.py --manifest evidence/blog-sources.json
python tools/verify_knowledge.py --manifest evidence/blog-sources.json --source-root /path/to/frame-app
python tools/test_verify_knowledge.py
git diff --check
```

`/path/to/frame-app` 替换为自己的源码目录；共享包需要保持原工作区布局。不带 `--source-root` 只做静态结构与导航检查，不复核源文件字节。

回看历史快照时使用原命令 `python tools/verify_knowledge.py --source-root /path/to/frame-app`；其漂移提示应保留，不能为了得到 0 而切换清单后声称原快照已刷新。

## 结果与边界

最终整合检查结果：

| 检查 | 实际结果 |
| --- | --- |
| 新博客清单 + 当前源码对照 | 47 篇 Markdown；结构/断链错误 0；35 份来源 `DRIFT=0` |
| 新来源记录 | 35 个去重文件、37 个文章定位别名；汇总时逐个比对阅读时的 hash，一致后才写入 |
| 来源选择回归 | 4 项 Python 测试通过：默认历史漂移保留、指定清单独立比对、无源码静态检查、越界/缺失清单拒绝通过 |
| 原快照完整性 | `evidence/sources.json`、`evidence/source-map.md` 与本轮基线无差异；原来源的 5 项漂移保留 |
| Markdown 与公开文本 | 围栏/折叠块配对通过，定向个人路径/凭据/内网 URL 扫描无命中；不等于全面安全认证 |
| Git 差异 | `git diff --check` 通过 |

静态导航检查跳过 64 个外部链接，不将其算作在线可达性验证。全部自有验证命令已退出，watchdog 结果为 `timeout=False active=0`。
内容复核重点包括当前源码语义、图示与条件、反例对应的测试断言、提交所支持的改动，以及面试措辞的证据边界。

当前文章中的产品测试是阅读依据，不是本轮执行记录；教学代码和时序图为说明机制的片段，不属于新增的可运行产品。

本轮没有构建 APK、安装或控制设备、执行后端请求，也没有测量帧率、黑帧耗时、网络恢复时长或更新成功率。文章没有据此补造量化结果。
官方资料在文章中保留直接链接和检索日期；离线工具不会把官网链接计为可达性检查通过。
