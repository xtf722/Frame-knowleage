# BesideYou App 课程：复核与证据边界

[App 学习入口](../besideyou-app/README.md) · [来源索引](app-source-map.md) · [独立来源清单](app-sources.json) · [Git 负责范围](app-contributions.md)

整理日期：2026-09-21。此次交付是知识库内容与离线证据工具的小范围扩展，不改变 App 功能。

## 取材与范围

- 从当前 App HEAD 可达的 `xtf722` 非 merge 提交筛出 5 项开发主线，查看具体差异；重复补丁、merge、stash 结构记录单列排除，方法见贡献证据。
- 独立记录 59 个去重后的源码、owner 和测试文件；App 与 workspace HEAD、工作区是否有未提交内容、SHA-256、章节关联和符号定位都在 App 清单中。
- 原 Frame 的 `sources.json` 与 `blog-sources.json` 保留原日期及字节，不通过刷新旧 hash 消除历史漂移。App 以 `primary_repository=app` 明确自己的源仓库。
- 公开内容使用相对源码路径和必要的短讲解片段，不保存完整项目源码、真实凭据、私有服务地址、设备标识或个人机器目录。

## 静态检查结果

在最终交付副本执行的检查结果如下；这些命令不启动 App，不连接项目后端。

| 检查 | 范围 | 结果 |
| --- | --- | --- |
| `python -X utf8 -B tools/verify_knowledge.py` | 默认历史清单结构与全部 Markdown 相对链接；没有传 Frame 源码根 | 58 篇 Markdown，结构/断链错误 0 |
| `python -X utf8 -B tools/verify_knowledge.py --manifest evidence/app-sources.json` | App 清单结构与全部 Markdown 链接 | 58 篇 Markdown，结构/断链错误 0 |
| 同上附加 `--source-root /path/to/besideyou-flutter` | 59 个来源文件的 SHA-256 | 结构错误 0，源码 DRIFT 0 |
| `python -X utf8 -B -m unittest discover -s tools -p 'test_*.py' -v` | 知识库证据工具回归 | 7 项通过 |
| `git diff --check` 与新文档空白检查 | 知识库本次改动 | 通过 |
| 新文档格式与内容抽查 | fenced code、details 配对、内部链接、私人路径和敏感信息 | 未发现阻断项 |

默认检查没有比较 Frame 源码，不能从该结果推断旧 Frame 快照已与当前 Frame 工作区一致。离线检查不访问外部网页；第 01 章引用的三份 Dart/Flutter 官方页面另于 2026-09-21 打开核对，只支持基础语义。

工具新增回归验证：显式 App 主仓库无需伪造 Frame 元数据；无效主仓库名或无效仓库元数据不通过；发现 App 源码漂移时返回 2，并保留原清单。原有的历史快照默认选择、独立清单选择、无源码检查与越界拒绝用例继续保留。

## 内容交叉复核

章节由不同阅读者交叉检查关键源码路径。复核后收紧了三个容易误导的说法：

1. 第 02 章的 exact-pet 队列复核限定为普通 `petSpace` fallback；合法 pending startup target 可跳过不会使用的 fallback 准备。
2. 第 03 章说明 prewarmer 复验后不再允许或需要完整 runtime 时，也可能移除 status；胶囊消失不能单独证明资源完备。
3. 第 05 章统一自测与正文：正常 Hold 循环暂缺/不匹配 activity 会等待，不清零已开始的同一 press 计时；明确中断事件另行处理。

另外确认 Great 只等待保存调用结束；存储层吞掉失败后仍可能显示，不能把它当作落盘证明。`middle.base` 缺少可播放资源时跳过教学，不伪造完成记录。源码摘录、省略的教学片段、状态推演和真实运行结果已区分。

## 发现的既有 owner 差异

`lib/app/pages/home/README.md` 的“Pet Space 选择与交互边界”仍有“只预热当前宠物、不遍历全部 Space”的旧句；同文档较新的“Portrait 本机加载提示与 Basic 入口”、Space 的 `prewarm-scheduler` 以及当前 `_prewarmPriorityPetSpace()` 已按完整 eligible 队列解释。

第 03 章明确按当前实现及相互一致的更新段落讲解。本次没有修改产品 owner；后续维护该模块时应在源仓库收敛这处差异，不能只在知识库改变产品合同。

## 没有验证的层

本次没有执行产品 Dart/Flutter 测试、分析、Flutter 构建、签名、安装、设备操作、真实账号/支付/后端请求或物理体验验收。产品测试文件只是帮助阅读输入、反例与断言，owner 中历史通过数未升级为本次结果。

没有新增实验程序；文中的方法片段与时序题未作为完整程序运行。Mermaid 图作为 Markdown 文本完成静态检查，未声明已在每一种阅读器中做视觉验收。

上述检查在知识内容提交前完成；Git 发布结果以实际提交和远端分支为准。本记录维护文档证据，源仓库已有未提交工作保留原样。
