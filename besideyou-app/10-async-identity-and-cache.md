# 10 从活动详情与合影缓存理解异步结果资格

[课程入口](README.md) · [本期来源](../evidence/app-october-source-map.md#async) · [上一期](09-time-and-capabilities.md) · [下一期](11-durable-ad-recovery.md)

阅读快照：2026-10-26。案例来自活动旧响应覆盖、完成返回闪回和合影缓存的修复。本期学习：`await` 前后的世界可能已经不同，结果回来后必须重新取得修改当前状态的资格。

先修：[Future 与 await](../beginner/03-future-await.md)、[旧结果失效](../beginner/09-stale-results.md)。核心问题：**请求成功了，为什么有时应该丢弃它？**

## 先制造一个确定的乱序

| 时间 | 发生的事 | 正确状态 |
| --- | --- | --- |
| T0 | 列表 GET A 发出，旧快照里券还没使用 | 等待 A |
| T1 | 用户完成用券，写结果 B 已确认 used | 接纳 B |
| T2 | A 迟到，仍含 available 或 none | 保留 B，并接纳列表其他活动 |

只判断 HTTP 成功就覆盖列表，会让已报名活动倒退。把整个 A 丢弃又可能丢掉首次列表中的其他活动。当前 Controller 记录读取开始时的详情对象，返回时合并期间新接纳的详情；稍后新发起的列表仍可更新旧摘要。这里需要的是明确的并发规则，不能简单宣布“详情永远优先”。

## 三种身份解决不同问题

| 身份 | 回答的问题 | 示例 |
| --- | --- | --- |
| 账号会话 stamp／epoch | 结果还属于这次登录吗 | A 登出再登录 A，账号 ID 相同，旧流程仍失效 |
| 活动级 detail revision | 同一活动是否已有更新读取或写入 | 旧详情成功和旧详情失败都变成取消 |
| 页面或动作 owner | 原来的用户意图还存在吗 | 用户离开页面，迟到资格不能继续领券 |

`mounted` 只说明 State 仍在树中；页面可能被新路由盖住，账号可能已切换。同样，取消本地续接并不证明服务端停止了请求。[State.mounted](https://api.flutter.dev/flutter/widgets/State/mounted.html)

`await` 让当前异步函数等待，它不会冻结应用的其他事件。用户切页、换号和新请求完成都可以发生在等待期间。[Dart 异步说明](https://dart.dev/libraries/async/async-await)

## 一个可逐句解释的最小片段

以下是教学方法片段，属于一个自定义 Controller；`epoch`、`revision`、`value`、`fetch` 和 `notifyListeners` 由外部提供，不是完整程序。

```dart
Future<void> refresh() async {
  final owner = epoch;
  final request = ++revision;
  final next = await fetch();
  if (owner != epoch || request != revision) return;
  value = next;
  notifyListeners();
}
```

第一行保存会话代次，第二行取得本次读取序号。`fetch` 等待期间若换号或开始新读取，保存的数字不再匹配，结果就不能提交。`notifyListeners` 只通知观察者，不能替代前面的归属判断。

这段简化只画成功分支。真实实现还要给 `catch` 和 `finally` 加同等资格保护，否则旧失败仍可能盖掉新成功，或旧请求结束时关掉新请求的 loading。写操作接纳后也要使旧读取失效。完整练习见[异步实验](../labs/app-october/README.md)。

项目的 `_checkDetailRevision` 不仅阻止写字段，还让过时读取以取消结束，从而阻止调用它的 `openEntry` 根据旧资格继续产生外部动作。只在渲染层忽略旧值并不足够。

## 缓存还需要内容身份与撤销规则

合影缓存键由活动、manifest revision、photo ID 组成；账号隔离由持有缓存的会话生命周期提供。它保留最近少量结果和字节预算，读取会更新最近使用顺序。业务缓存复用已加载字节，远程传输及持久图片缓存继续经过 `TosImage`。

签名 URL 是临时访问地址，不等于内容身份。`persistUrl: false` 配合明确的非 URL 资源键可以保存图片字节而不保存签名。不能随意剥掉查询参数来猜测两张图相同。

| 刷新结果 | 本案例如何处理已有合影 | 原因 |
| --- | --- | --- |
| 超时或临时网络失败 | 保留已确认结果 | 暂时不知道，不等于明确失去资格 |
| 确认权限拒绝、404 或版本失效 | 撤下旧结果并失效相关缓存 | 缓存不能越过已知撤销 |
| 换号或退出 | 清空会话结果，拒绝迟到回填 | 图片归属不能跨账号 |
| 新 photo ID 或新 revision | 按新内容身份替换 | 旧字节不冒充新交付 |

这不是任何应用都可以无条件“先显示缓存”的通用许可。允许哪些离线显示、拒绝后何时撤下，必须由对应业务合同明确。

## 最少源码阅读顺序

1. `pawventures_controller.dart`：`refresh`、`refreshDetail`、`_accept`、`_accountChanged`。
2. 同文件 `_writeAndReconcile`：看失败后为什么先核实，而不是再次写入。
3. `pawventures_photo_cache.dart`：只看 `_key`、`read`、`invalidate`；访问撤销规则回到 owner。

停止点：能解释旧成功、旧失败、列表合并和换号四条时序，不必读完整播放器。

## 预测题与反例

A 请求先发，B 后发且成功，A 最后失败。如果只在成功分支检查 revision，页面会怎样？

<details>
<summary>展开答案与理由</summary>

旧失败可能覆盖 B 的有效数据对应的错误态。错误和 loading 也是共享状态，必须遵守同样的写入资格。项目对应测试保护的是“旧失败不能覆盖新确认”，而非私有序号恰好等于某个数字。

</details>

用户 A 登出后重新登录 A，只比较 `accountId` 是否相等够不够？

<details>
<summary>展开答案与理由</summary>

不够。旧会话已经失效，新登录是新的会话代次。旧请求可能携带过期授权、旧页面意图或清理前状态。需要 epoch 或等价的会话凭证；同账号 token 正常续期是否换代，则由会话合同单独规定。

</details>

## 练习与完成标准

运行离线实验，观察 B 先完成、A 后完成时最终保留谁；再运行 `--broken-fence`，确认删除资格检查会被实验捕获。用 `Completer` 控制顺序，比加随机延迟等待“偶现”更能说明问题。

完成标准：能为每个 `await` 列出可能改变的身份，给成功、失败和清理路径设置边界，并说明缓存的“更新”和“撤销”条件。可迁移到搜索联想、切换账号、分页、文件预览和图片导出。
