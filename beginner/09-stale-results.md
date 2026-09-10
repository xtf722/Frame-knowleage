# 09：页面还在，为什么旧结果也要丢掉？

[上一课：异步界面](08-async-ui.md) · [课程目录](README.md) · [下一课：定时器与监听](10-timers-listeners.md)

本课只回答一个问题：用户已经改选 B，A 的加载结果晚到，为什么不能照常显示？先读懂 [03 的 await](03-future-await.md) 和 [08 的 mounted](08-async-ui.md)。

## 第一步：先不写任何保护

这是放在 State 中的教学方法片段；假设 `fetchName` 返回指定宠物的名称，`photoName` 是已声明的字段。它故意只检查存活，用来暴露问题。

```dart
Future<void> loadFor(String petId) async {
  final name = await fetchName(petId);
  if (!mounted) return;
  setState(() {
    photoName = name;
  });
}
```

`petId` 是这次调用的参数。`await` 等待期间，用户仍可能触发另一遍 `loadFor`。这些调用可以同时处于等待阶段。

先画四件事，不需要知道 HTTP 怎样实现：

```text
选择 A → 开始加载 A
选择 B → 开始加载 B
B 先完成 → 显示 B
A 后完成 → 显示 A？
```

**预测 1：页面一直存在，`mounted` 始终为 true，上面的方法最终显示谁？**

<details>
<summary>展开答案与原因</summary>

最终显示 A。A 的结果晚到，但存活检查通过，因此最后一次赋值覆盖了 B。`mounted` 没有比较宠物，也没有记录用户最近选择了谁。

如果你回答 B，可能把“最后发起的请求”误当成“最后返回的请求”。返回顺序由具体异步工作决定。

</details>

## 第二步：给每一轮加载一个编号

在 State 字段区增加：

```dart
int generation = 0;
```

把方法改成下面这个成功路径片段：

```dart
Future<void> loadFor(String petId) async {
  final mine = ++generation;
  final name = await fetchName(petId);
  if (!mounted || mine != generation) return;
  setState(() {
    photoName = name;
  });
}
```

逐句读新加的部分：

- `++generation` 先把字段加一，表示开始新一轮加载。
- `mine` 保存这次调用拿到的编号；后续新调用不会修改这个局部变量。
- `mine != generation` 表示“我的编号已经不是最新编号”。
- `||` 表示两边只要有一个条件成立就进入 `return`。

| 时刻 | 当前 `generation` | A 保存的 `mine` | B 保存的 `mine` |
| --- | --- | --- | --- |
| 开始 A | 1 | 1 | 尚未开始 |
| 开始 B | 2 | 1 | 2 |
| B 返回 | 2 | 1 | 2，允许更新 |
| A 返回 | 2 | 1，直接返回 | 2 |

**预测 2：如果 A、B 都请求同一只宠物，第二次属于刷新，编号还会有作用吗？**

<details>
<summary>展开答案与原因</summary>

会。这个示例采用“最新一次调用的结果有效”策略，编号区分请求轮次，即使 petId 相同也能排除旧刷新结果。业务有时需要排队保留每次操作，不能把这套策略无条件套给所有请求。

</details>

## 第三步：错误和 loading 也有归属

08 课为了降低难度，用 busy 限制同时加载。开放并发、切换或刷新后，要重新检查所有等待后的界面写入。

例如 A 失败的时候，B 可能仍在加载。A 的 `catch` 不应把 B 的界面改成“加载失败”；A 的 `finally` 也不应替 B 清掉 loading。

**预测 3：只在成功分支比较 generation，在 catch/finally 里只检查 mounted，够吗？**

<details>
<summary>展开答案与原因</summary>

不够。名称、错误提示和 loading 都是会影响当前画面的状态，旧调用修改任何一项都可能造成错误。等待之后的 catch/finally 写入同样要检查当前编号。

</details>

## 自己改一处

想象用户点击“取消本次加载”。暂时只要求取消后忽略结果，不要求中断底层下载。下面的取消方法应怎样写？

<details>
<summary>参考解与边界</summary>

```dart
void cancelCurrentResult() {
  generation++;
}
```

它让之前保存的 `mine` 失效。即使没有发起新请求，旧结果也不能再写入。它没有停止已经开始的网络或文件操作；真正的资源取消要看底层接口。

</details>

## 运行与回到 Frame

可以运行已有的 [future_race.dart](../labs/future_race.dart)。其中 `Completer` 是实验用的“手动决定 Future 何时完成”的工具，用来固定 B 先返回、A 后返回；先看实验输出，再读这个工具的语法也可以。

接着只读 [Portrait 短导读](guided/portrait.md)，对照 `mounted` 与“当前宠物/当前请求”两个问题。更完整的身份与提交条件在 [异步基础卡](../foundations/async-lifecycle.md)，暂时不用追解码器。

完成本课的标准：能手画返回顺序，指出旧结果应该被哪一个条件拦住，并解释忽略结果与中断 I/O 的区别。

本课的编号策略是原创教学设计；Future 等待与超时基础参见 [Dart Future](https://api.dart.dev/dart-async/Future-class.html)，它不提供自动保证“只接受最新业务结果”的功能。核对日期：2026-09-10。
