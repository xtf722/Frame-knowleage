# Frame 学习知识库维护约定

## 阅读与内容边界

先读 README、对应专题、evidence/source-map.md，再用用户提供的源码工作区核对。该仓库沉淀项目学习材料，不拥有产品合同、部署或物理验收状态。

- README 和 learning-map 只保存边界、阅读顺序、链接。
- beginner 保存循序渐进的自学课程：先修、一个核心问题、短例子、逐句解释、预测题、折叠答案及理由、小改动练习、完成标准。每次只引入必要的新概念，已会内容可通过练习跳过。
- beginner/guided 每篇只追一个模块行为，连接基础课与 modules；限制本轮需要打开的源码文件，明确阅读停止点。导读不另建产品行为事实源。
- modules 每条核心链路一篇，按“问题 → 源码 → 生命周期 → 失败 → 基础 → 自测”组织。
- articles 保存注明阅读日期的技术博客：从具体工程冲突推导方案、取舍与验证，附面试讲述和追问；链接自己的来源快照，不冒充产品合同。
- interview 保存项目介绍、案例组织和候选简历表达；个人负责范围以作者确认内容为准，不编造事故、协作归属、收益指标或完成状态。
- foundations 解释跨模块可迁移的机制，通过回链落回项目，不复制专题的全部实现。
- besideyou-app 保存手机 App 的提交范围导向课程：具体用户动作、数据流、基础写法、状态时间线与失败路径；职责背景与个人提交分开，源码快照统一在 evidence/app-* 中保存。
- review 保存复习方法、个人空白模板和用户明确记录的掌握状态；不替用户声明已经掌握。
- evidence 保存源码路径、符号、读取时的 revision 和 hash，不保存源码副本。
- labs 只放不访问项目后端、不操作设备的独立教学程序。

## 自学内容规则

- 学习者应能自行展开答案继续，不强制每一道题等待 AI；答错时提供应回看的具体解释。
- 区分完整可运行程序、State字段、build内容和教学方法片段；代码片段要说清缺少的外部定义，不能把省略的示意代码冒充完整程序。
- 避免将 mounted 解释为页面一定可见；离页不必然 dispose，重建不必然创建新 State。
- didUpdateWidget 后的自动 build 不能代替稍后异步完成时的界面通知；setState 回调保持同步。
- 基础课中的简化策略注明边界，例如忙碌时禁重复与可切换并发请求不能混为同一方案。

## 更新方法

1. 先运行文档检查。若有源码，使用 `--source-root` 发现来源漂移。
2. 哈希变化表示需要复核，不等于原结论必然错误。阅读真正变化的源码和 owner 文档。
3. 先修订相应专题，再更新对应来源记录；不要只刷新 hash 让检查变绿。
4. 新增重要状态分支时补一题反例推演，保留准确 English identifiers。
5. 定义学习实验的输入、观察点、预期、适用限制。未运行的实验明确写未运行。

对当前代码未证明的推断，明确标注，不根据历史测试数量推定当前通过。不把 Widget、APK、安装、服务及物理验收合为一个“已验证”。

## 公开内容

仓库可以公开阅读。只发布原创讲解、必要的相对源码路径、符号索引及来源元数据。不得收录密钥、真实凭据、私有网络地址、设备标识、个人目录、完整日志、APK 或项目源码副本。公共基础资料优先链接官方来源，注明检索日期及版本适用限制。

## 完成检查

- `python tools/verify_knowledge.py` 检查文件、Markdown 链接和证据结构。
- 若有源码：`python tools/verify_knowledge.py --source-root /path/to/frame-app` 复核来源 hash。
- 博客使用独立清单：`python tools/verify_knowledge.py --manifest evidence/blog-sources.json --source-root /path/to/frame-app`。历史快照漂移保留并解释，不能覆盖旧 hash 以消除提示。
- 手机 App 使用独立清单：`python tools/verify_knowledge.py --manifest evidence/app-sources.json --source-root /path/to/besideyou-flutter`；清单显式设置 `primary_repository=app`，不把 App 的 HEAD 冒记成 Frame。两类清单均沿用原 workspace 相对布局，不改旧快照。
- `git diff --check`；检查提交范围只包含本知识库。
- 只改文档无需运行产品构建或设备操作。示例改动仅运行对应示例。
- commit/push 根据用户授权执行，不能改写历史或覆盖远端已有内容。
