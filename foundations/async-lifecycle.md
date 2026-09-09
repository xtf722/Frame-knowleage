# 异步与生命周期：结果回来时，它还属于现在吗？

[返回首页](../README.md) · [Portrait](../modules/portrait.md) · [Wi-Fi](../modules/wifi.md)

## 先建立两个模型

**时间模型**：`await` 暂停当前异步函数后续步骤，等待期间其他事件仍可运行；它不会把整个 App 锁住。两个请求可以按 A、B 的顺序发起，却按 B、A 的顺序返回。[Dart Future 官方文档](https://api.flutter.dev/flutter/dart-async/Future-class.html)

**所有权模型**：异步结果不仅要有值，还要有资格提交。提交时应重新回答“接收者还活着吗”和“当前业务还是发起时那个业务吗”。后一个问题是项目设计，`await` 不会自动解决。

## State 与业务身份

Flutter 的 State 会经历创建、`initState`、依赖与配置更新、build、移除和 `dispose`。相同位置上同 runtimeType 与 key 的新配置通常复用 State，并通过 `didUpdateWidget` 交接；`dispose` 后不能再 `setState`。[Flutter State 生命周期](https://api.flutter.dev/flutter/widgets/State-class.html)

由此推导出一个项目问题：**State 没销毁，业务也可能已经切换**。例如同一页面从宠物 A 改到 B。`mounted` 只检查树中的生存状态；用它单独保护 A 的迟到结果，会遗漏“结果属于旧选择”的错误。

| 检查 | 要回答的问题 | 常见失败 |
| --- | --- | --- |
| `mounted` / `_disposed` | 接收者还允许更新吗？ | 已退出页面仍更新 |
| generation / epoch | 结果是否属于当前这一轮操作？ | A 的结果覆盖后选的 B |
| identity / revision | 数据是否属于当前实体和版本？ | 同地址误复用另一份媒体 |
| lease / canCommit | 这次 I/O 现在仍有提交或清理资格吗？ | 旧任务清理新任务需要的缓存 |

后三种是教学分类，实际字段和判断位置看各专题。不要为了形式完整给每段代码都堆四个检查。

## 最小的 generation 模式

下面是**原创教学伪代码**，不是复制项目实现：

```dart
final myGeneration = ++generation;
final result = await load(selectedId);
// 页面活着并且仍属于这一轮选择，结果才有提交资格。
if (disposed || myGeneration != generation) return;
current = result;
```

关键不是变量名，而是**切换时递增、提交前比较**。如果还会写共享文件，只有最后 UI 赋值前检查是不够的：文件提交和清理同样需要按影响检查资格。

## 取消、超时和忽略结果

| 动作 | 它实际解决什么 | 没有自动解决什么 |
| --- | --- | --- |
| `Timer.cancel()` | 不再触发尚未执行的定时回调 | 已发起的异步工作 |
| 取消订阅 | 不再接收该订阅后续事件 | 已排入其他队列的业务工作 |
| generation 检查 | 阻止旧结果修改新状态 | 底层 I/O 的资源占用 |
| 底层请求取消 | 尽可能终止具体 I/O | 取消与完成竞态下的提交资格 |
| `Future.timeout` | 给调用方一个等待期限 | 自动终止源 Future |

`Future.timeout` 返回一个新的等待结果，源 Future 仍可能稍后完成。超时后是否仍写文件、产生平台副作用，需要具体实现处理。[Dart Future.timeout](https://api.dart.dev/dart-async/Future/timeout.html)

## 在 Frame 中怎么练

- 在 [Portrait](../modules/portrait.md) 找稳定 session identity：比较哪些更新只是资源地址更新，哪些才应重建 Host。
- 在 [Wi-Fi](../modules/wifi.md) 找 page generation 和 observer epoch：分别画出页退出、stop/start 后迟到结果的处理。
- 在 [App Update](../modules/app-update.md) 找 `_runExclusive`：用户操作互斥和自动通知合并解决的是不同问题。
- 运行 [future_race.dart](../labs/future_race.dart)：用 `Completer` 控制返回顺序，先看没有门的结果，再看带门的结果。

## 自测

1. 为什么不能简单地把 `await` 理解成“后面的操作都在排队等”？
2. 页面始终 mounted，为什么仍需要 generation？
3. 去掉迟到结果的 UI 更新，就能证明没有残留 I/O 吗？
4. 同一个 controller 被多个页面使用，谁应该 dispose？

<details>
<summary>参考答案</summary>

1. 只有当前函数的后续语句在等；其他事件、函数和回调可以执行。
2. 存活性与业务归属不同。选项切换可能保留 State 却改变合法结果。
3. 不能。结果隔离不等于底层工作取消，应分别追踪资源和外部效果。
4. 找明确的持有者。页面借用的 App 级对象通常由 App 所有者释放，具体以创建/注入/释放链为准。

</details>

资料检索：2026-09-09。上述语言/框架文档用于解释机制，具体项目生命周期由专题的源码快照支持。
