# 07 · 还是这份 State，为什么输入变了？

[上一课：生命周期](06-lifecycle.md) · [课程入口](README.md) · [下一课：异步 UI](08-async-ui.md)

本课只回答一个问题：**父组件传入新配置时，保留下来的 State 怎样知道变化？**

先修：第 05–06 课；知道 `widget.photoId` 是输入，`_likes` 是 State 字段。
本课的教学规则是：切到另一张照片时，点赞数清零。它是练习规则，不是 Frame 产品要求。

## 先预测一次替换

想象父组件在同一个子节点位置先后产生下面两个配置；两者都没有显式 key：

```dart
// 父组件首次 build 的子节点
PhotoPage(photoId: '照片 A')

// 父组件稍后 build 的同一子节点
PhotoPage(photoId: '照片 B')
```

两次都是 `PhotoPage` 类型，key 都是 `null`。更新这个现有节点时，新配置可用于更新旧 Element，进而保留对应 State。[Flutter Widget.canUpdate](https://api.flutter.dev/flutter/widgets/Widget/canUpdate.html)

“同一位置”说的是框架正在更新的树节点，不是屏幕坐标。
此处讨论普通的同位置更新；列表重排、父级包装变化、GlobalKey 移动等情况要继续追树的匹配规则，不能只比较两个 Dart 变量。

## 只写这几行响应新输入

以下放进第 05 课 `_PhotoPageState` 类，字段和 build 沿用第 05 课：

```dart
@override
void didUpdateWidget(covariant PhotoPage oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (oldWidget.photoId != widget.photoId) {
    _likes = 0;
  }
}
```

- `didUpdateWidget` 是配置交接入口，名字里的 update 指 Widget 配置更新。
- `PhotoPage oldWidget` 是参数：进入方法时，它拿着旧配置。
- `covariant` 允许这个覆写参数使用对应的具体类型；本课先认出 `oldWidget` 是 `PhotoPage` 即可。
- `super.didUpdateWidget(oldWidget)` 调用继承来的实现，按 API 约定放在开头。
- `widget` 已由框架切换为新配置，所以比较的是“旧 photoId”与“新 photoId”。
- 不相同才把 `_likes` 设为 0；其他配置更新不应无条件抹掉用户数据。

这里的 `super` 不是“把新 Widget 安装到 State”的操作：那一步在进入回调前已由框架完成。
官方 `State.didUpdateWidget` 基础实现目前为空，但有 `mustCallSuper` 约定；中间父类也可能有自己的处理，不能虚构基础实现替你同步某个字段。[Flutter didUpdateWidget](https://api.flutter.dev/flutter/widgets/State/didUpdateWidget.html)

## 为什么这次没写 setState？

框架在 `didUpdateWidget` 返回后会调用 build。本例的 `_likes = 0` 在返回前同步完成，因此接下来的 build 会读到 0，无需额外安排。
这是该生命周期入口的约定，不能推广成“只要字段在 State 里，赋值就自动刷新”。[Flutter didUpdateWidget](https://api.flutter.dev/flutter/widgets/State/didUpdateWidget.html)

如果回调只是**启动**异步任务，结果到达时这次 build 可能早已结束。
异步结果稍后修改 UI 字段，仍需要正确的 `setState` 和存活检查；还要检查结果是否属于当前输入，第 08–09 课会继续处理。

再看两个输入写法；这是父组件内的表达式片段：

```dart
// photoId 改变时，key 保持不变。
PhotoPage(key: const ValueKey('viewer'), photoId: selectedId)

// photoId 改变时，key 也跟着改变。
PhotoPage(key: ValueKey(selectedId), photoId: selectedId)
```

第一种在本课同位置、同类型前提下允许复用 State；第二种 key 不同，不能按这个原节点的普通更新路径复用。
不要为“看起来刷新一下”随意换 key，因为保留还是重新创建 State 本身就是行为选择。

## 先预测，再展开

**预测 1：** A 已有 3 个赞，同位置换成 B，但完全不实现 `didUpdateWidget`，文字会是什么？

<details>
<summary>答案与容易错的原因</summary>

在上面同类型、同 key 的条件下，build 读取新 `widget.photoId` 和保留下来的 `_likes`，得到“照片 B：3 个赞”。
Widget 配置变了不等于所有 State 字段自动重置。反过来，仅把旧 photoId 复制进另一个字段，也不会让那个副本自动更新。

</details>

**预测 2：** 加了本课回调，进入回调时 `oldWidget.photoId` 和 `widget.photoId` 分别是什么？

<details>
<summary>答案与容易错的原因</summary>

分别是 A 和 B；比较不同后清零，后续 build 显示“照片 B：0 个赞”。
如果以为两者仍都是 A，就会误以为必须由 `super` 完成新配置安装；实际上框架先替换 widget 再调用回调。

</details>

**预测 3：** 在回调里启动一个加载，2 秒后直接赋值 `_likes = 9`，是否有“回调后自动 build”作保证？

<details>
<summary>答案与容易错的原因</summary>

没有。自动 build 对应这次同步配置交接，不等待未来 2 秒后的工作。
异步完成后需要独立通知 UI，并检查 State 是否仍在、结果是否仍属于当前照片。`mounted` 单独不能回答后一个问题。

</details>

## 微练习：相同输入不要重置

有人把回调写成下方版本。改成“只有 `photoId` 改变才清零”，再解释父组件仍传 A 时会保留什么。

```dart
@override
void didUpdateWidget(covariant PhotoPage oldWidget) {
  super.didUpdateWidget(oldWidget);
  _likes = 0;
}
```

<details>
<summary>修改答案</summary>

```dart
@override
void didUpdateWidget(covariant PhotoPage oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (oldWidget.photoId != widget.photoId) {
    _likes = 0;
  }
}
```

父组件产生新的 A 配置时，旧、新 photoId 相等，保留原 `_likes`。
“新 Widget 对象”和“新的业务对象”并不等同；这里决定清零的是 photoId 变化，而不是仅仅收到一次回调。

</details>

## 到这里可以停

能在纸上写出“框架替换 widget → 回调收到 oldWidget → 同步修改字段 → build”，就继续 [第 08 课](08-async-ui.md)。
暂时不必实现列表重排或 GlobalKey；本页没有覆盖它们全部的复用条件。
想联系已有项目学习快照，可回看 [Portrait 的 session identity](../modules/portrait.md) 和 [异步与生命周期](../foundations/async-lifecycle.md)；本例不证明项目当前使用同一清零策略。

官方资料检索：2026-09-10。上述规则对应官方 API；例子与清零策略均为原创教学设计。
