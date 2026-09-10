# 06 · build 再执行，是不是页面重生了？

[上一课：Widget 与 State](05-widget-state.md) · [课程入口](README.md) · [下一课：配置更新](07-config-updates.md)

本课只回答一个问题：**同一份 State 的开始、重复工作和结束，怎样区分？**

先修：第 05 课，能找到 State 字段、`_like` 和 `build`。
沿用上课完整程序；新增的方法写在 `_PhotoPageState` 类内，与 `build` 平级。
本课日志只作教学观察，不能当作正式业务里的工作触发器。

## 先看开始和结束

```dart
@override
void initState() {
  super.initState();
  debugPrint('开始：${widget.photoId}');
}

@override
void dispose() {
  debugPrint('结束：${widget.photoId}');
  super.dispose();
}
```

- 两个 `@override` 表示我们实现框架约定的生命周期方法。
- `initState` 是框架给这份 State 的初始化入口；不需要自己在点击按钮时调用。
- `super.initState()` 先调用继承来的实现，再执行本类初始化。
- 日志读取 `widget.photoId`；此时框架已给 State 配好对应的 Widget。
- `dispose` 表示这份 State 的使用期结束，可在这里清理它拥有的订阅或控制器。
- 本类清理完成后调用 `super.dispose()`；不能把已 dispose 的 State 重新拿来 build。

“一次”以 **每份 State 对象** 为单位：`initState` 对每份对象调用一次，不是整个 App 只调用一次。[Flutter initState](https://api.flutter.dev/flutter/widgets/State/initState.html)
`dispose` 后这份 State 不再 mounted，不能再 `setState`；它也不是操作系统结束进程时必定执行的存档机会。[Flutter dispose](https://api.flutter.dev/flutter/widgets/State/dispose.html)

## 再看重复的工作

在上课已有的 `build` 方法开头加日志，其余返回值保留：

```dart
@override
Widget build(BuildContext context) {
  debugPrint('构建：${widget.photoId}，赞数=$_likes');
  return Scaffold(
    body: Center(child: Text('$_likes 个赞')),
  );
}
```

`build` 根据当时的输入和字段描述画面；同一份 State 可以反复执行它。
这里为了看清代码省略了按钮；实际实验保留上课完整程序的 `Scaffold` 返回内容。
不要把请求、创建播放器或“点赞数加一”放在 build 里，它的执行可能很频繁。[Flutter build](https://api.flutter.dev/flutter/widgets/State/build.html)

可以先这样读一段过程，方括号表示“可能重复”：

```text
创建这份 State
  → initState
  → [build；字段改变后再 build；配置或依赖改变后再 build]
  → 永久移除后 dispose
```

这张图省略了 `didChangeDependencies`、`deactivate` 等入口，只服务本课问题；完整顺序查看 [State 官方生命周期](https://api.flutter.dev/flutter/widgets/State-class.html)。

## 看不见，不等于已释放

设想相册 A 上面又打开设置 B。A 不可见时，它仍可能保留在路由中，返回时继续使用原 State。
`MaterialPageRoute` 的 `maintainState` 控制非活动路由是否保留；因此不能仅凭一次 push 覆盖，就断定 A 已 dispose。[Flutter MaterialPageRoute.maintainState](https://api.flutter.dev/flutter/material/MaterialPageRoute/maintainState.html)

先分开问：画面是否可见、路由是否仍保留、State 是否已 dispose。
App 切到后台又是另一个边界；本课没有把这些事件合并成同一个“离开页面”。

## 先预测，再展开

**预测 1：** 连续点三次点赞，`initState` 应出现三次吗？

<details>
<summary>答案与容易错的原因</summary>

不应因这三次点击重新初始化同一份 State。点击改变字段并请求重建，不等于创建新的 State。
如果实际出现多次“开始”，应追查是否有多份实例或子树替换；不能只凭日志次数宣布框架异常。

</details>

**预测 2：** 调用两次 `setState`，是否能保证日志中恰好增加两次 build？

<details>
<summary>答案与容易错的原因</summary>

不能。多次请求可能在一帧内合并，build 也可能由配置、依赖等其他变化触发。
将 `setState` 次数与 build 次数一一对应，是把“安排更新”误当成“立刻且只执行一次更新”。
这里应观察最终字段和界面，而不是规定精确日志条数。[Flutter setState 的性能说明](https://api.flutter.dev/flutter/widgets/State/setState.html)

</details>

**预测 3：** A 被 B 覆盖后，某个回调还能读到 A 的字段，是否已经证明内存泄漏？

<details>
<summary>答案与容易错的原因</summary>

不能。A 可能按路由策略正常保留。先确认 A 的所有者是否仍有意保留它，再检查应释放时是否仍有对象持有它。
不可见、mounted、业务仍有效是不同的问题；下一课会看到页面存活但输入已经改变。

</details>

## 微练习：首次的赞数只设一次

保持字段 `int _likes = 0;`。在 `initState` 的父类调用后加一行，把初始点赞数设为 10。
先预测：首次显示多少、点一次后多少、再发生一次普通 build 是否回到 10。

<details>
<summary>修改答案</summary>

```dart
@override
void initState() {
  super.initState();
  _likes = 10;
  debugPrint('开始：${widget.photoId}');
}
```

首次为 10，点击一次后为 11；同一份 State 的普通 build 不重新运行 initState，因此不会自动回到 10。
这里同步初始化后本来就有首次 build，不需要为了这次初始赋值额外包 `setState`。
若你把赋值写在 build 里，就会在每次 build 把用户的点赞覆盖掉。

</details>

## 自己运行时记录什么

输入：启动练习、点击两次、停止练习。观察：每条日志属于初始化、构建还是释放。
预期：点赞时字段递增，同一 State 不因点赞重做初始化；**直接结束进程不保证出现 dispose 日志**。
本课示例为待运行练习，未据此声称某个平台或 Frame 设备已通过验证。

## 到这里可以停

能用一句话区分“build 再执行”和“新建 State”，并说明“不可见”为什么不能直接推出 dispose，就继续 [第 07 课](07-config-updates.md)。
以后涉及播放器时，回看 [生命周期总览](../lifecycle-map.md) 和 [Portrait 专题](../modules/portrait.md) 的既有学习快照；不要用页面 build 的日志替代播放器释放证据。

官方资料检索：2026-09-10。本文只介绍链接中的通用 API 边界，不承诺具体路由配置或平台进程行为。
