# 入门课程交付验证

日期：2026-09-10。对象是本知识库新增的课程与原创教学例子；[2026-09-09 专题验证](validation.md) 保留原始范围，不把本页结果归到 Frame 产品上。

[课程入口](../beginner/README.md) · [练习运行方法](../labs/beginner/README.md) · [来源说明](README.md)

## 本次范围

- 新增 11 节连续自学课程、语法速查和 Portrait / Moment / Wi-Fi / App Update 四篇短导读。
- 新增 4 个纯 Dart 实验与 2 个完整 Flutter 页面例子；现有两个进阶 Dart 实验保持原代码。
- 更新入口、复习方法和相关专题的导航；新增导读取材关系，不改变原源码快照身份。

## Dart 示例执行

工具链的实际 Dart 版本：`3.12.1 stable / windows_x64`。在知识库根目录执行：

```shell
dart format labs/beginner/callbacks.dart labs/beginner/await_order.dart labs/beginner/types.dart labs/beginner/timer_cancel.dart
dart labs/beginner/callbacks.dart
dart labs/beginner/await_order.dart
dart labs/beginner/types.dart
dart labs/beginner/timer_cancel.dart
```

四个实验均退出 `0`，输出与各自自检匹配：回调交付与调用、两种 await 放置顺序、泛型与空值、取消后回调数为 0 / 一次性 Timer 回调数为 1。

额外机械提取第 01–04 课的 17 个 Dart 代码块，按教材说明补齐第 03 课两段所需的 `loadPhoto`。**17/17** 运行成功，输出逐字匹配。
第 02 课故意错误的 `openAlbum(showPhoto())` 另行验证，按预期因不能把 void 结果作为函数值使用而编译失败；失败没有记作通过的完整程序。
第 05 课新增的普通类示例、第 10 课第一个 Timer 小程序分别运行通过，合计 **19 个成功运行的文档代码块**。这不表示所有标注为“片段”的模型都可单独运行。

## Flutter 示例验证

在临时、独立的最小 Flutter 工程中，使用实际回读的 Flutter `3.44.1 stable` 与 `flutter_test`，没有导入 Frame 产品实现。两个完整公开示例经格式化后复制到该工程：

```shell
flutter pub get --offline
dart analyze lib test
flutter test --no-pub test/teaching_examples_test.dart --reporter expanded
```

分析结果为 `No issues found`，四个 widget 测试全部通过：

| 用例 | 实际覆盖 |
| --- | --- |
| State 与配置 | 初始文本、点击增加点赞、同一位置同类型同 key 的配置更新保留点赞数 |
| 加载与重复调用 | 忙碌按钮禁用、下一帧前及等待中重复调用被拒绝、成功结束 loading、新一轮不被旧调用提前解锁 |
| 离开页面 | 等待期间移除 State，再让 Future 完成，无 `setState after dispose` 异常 |
| 失败与重试 | 用机械生成的失败变体模拟错误，显示失败、恢复按钮、保留原文本，然后成功重试 |

失败变体只给 `_fetchMessage` 增加可控的抛错分支，没有修改公开示例的 `_load` 状态处理。临时工程、提取脚本和测试文件不属于公开课程代码；上面的分析和测试命令是在该临时工程内运行，不能直接在知识库根目录运行。

两份文件测试后按仓库规则统一为 LF 换行；与被测副本比较，除换行统一外内容完全一致。以下 SHA-256 对应入库的 LF 文件，后续逻辑修改需重新验证：

| 文件 | SHA-256 |
| --- | --- |
| `flutter_state_demo.dart` | `a610eb26d6647c747788ff0892718f24aadd85a68547549213b106ab738ff50a` |
| `flutter_async_demo.dart` | `848c536b676173da3e4fa71987e0b4c248469894595f7008936c1ad62b7edc98` |

首次从受限环境启动 Flutter 离线依赖解析时，60 秒无输出超时。完整进程树已由 watchdog 清理并确认 `active=0`；使用有权限的同一工具链重新解析后通过。该次超时不是产品失败，也未被计入通过结果。
所有本轮拥有的验证命令最终已退出，成功记录为 `timeout=False active=0`；没有保留后台测试进程。widget 测试没有覆盖 Chrome 手动运行、Android 渲染、实际网络或硬件。

## 内容复核与来源

独立只读审查覆盖课程递进、代码语义、问答、四篇导读的源码与指定测试入口。发现并修订了两处问题：

1. 第 05 课原先假定已理解 class/构造函数/字段；现已补普通 Dart 对象例子，打通先修导航。
2. 第 10 课原先只在成功路径末尾取消订阅；现改为 `try/finally`，等待失败时也尝试清理。

新增导读关联了原有 8 个来源。`sources.json` 中的采集日期、仓库基线和 67 份来源内容指纹均保持不变；只补充 `used_by` 和索引导航。对应导读仍标为原专题快照，不宣称刷新了产品行为。

对整合后的文件执行 `python tools/verify_knowledge.py --source-root <本地Frame-app目录>`，结果：**38 篇 Markdown，结构/断链错误 0，67 份来源 DRIFT 0**。离线检查跳过 53 个外部链接，不将它们计作在线可达性验证。`git diff --check` 通过。
没有源码时也可以运行 `python tools/verify_knowledge.py` 检查结构和内部导航；命令说明见 [来源复核](README.md)。

检查公开文档时，未发现本地个人绝对路径、凭据字面量或内网地址模式；定向扫描不等于对所有类型敏感信息的全面认证。
