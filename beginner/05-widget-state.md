# 05 · 数字变了，画面为什么还没变？

[上一课：类型与空值](04-types-nullability.md) · [课程入口](README.md) · [下一课：生命周期](06-lifecycle.md)

本课只回答一个问题：**输入配置、可变字段、画面更新，分别由谁负责？**

先修：前四课的变量、函数、回调和类型。`class`、构造函数与字段先在下面补齐。
用法：先读短代码，遮住答案预测，再动手改一处；不需要每题等待 AI。

## 先用普通 Dart 认识“类”和“对象”

下面是完整 Dart 小程序，可以单独运行：

```dart
class PhotoInfo {
  final String photoId;
  PhotoInfo(this.photoId);
}

void main() {
  final first = PhotoInfo('照片 A');
  final second = PhotoInfo('照片 B');
  print(first.photoId);
  print(second.photoId);
}
```

`class PhotoInfo` 定义一种对象的结构，像一张信息卡的格式。`first` 和 `second` 是按这个类分别创建的两个对象，各自保存自己的照片编号。
`photoId` 声明在类的大括号里、方法外，叫作**字段**；`first` 声明在 main 内，叫作局部变量。
`PhotoInfo(this.photoId)` 是构造函数；调用 `PhotoInfo('照片 A')` 创建对象时，`this.photoId` 把传入值保存到这个对象的字段。`first.photoId` 用点号读取它。[Dart 类与对象](https://dart.dev/language/classes)

先猜两句打印是否会都变成“照片 B”？不会，依次是 A 和 B；同一个类创建的对象有各自的字段。下面的 `PhotoPage(...)` 与 `_PhotoPageState()` 也使用构造调用，这次创建的是 Flutter 所需的对象。

## 先看一个会记住点赞数的页面

这是 Widget 配置片段，完整程序在下方折叠区。

```dart
class PhotoPage extends StatefulWidget {
  const PhotoPage({super.key, required this.photoId});
  final String photoId;
  @override
  State<PhotoPage> createState() => _PhotoPageState();
}
```

- `extends StatefulWidget`：这类页面需要与它配对的 State。
- 构造函数接收 `photoId`；`required` 要求调用方传入，`final` 表示这一对象的字段只能赋值一次。
- `super.key` 把可选的 key 交给父类；第 07 课再解释它参与什么判断。
- `@override` 表示下面的方法实现了父类约定的方法。
- `State<PhotoPage>` 是泛型：这份 State 对应 `PhotoPage` 配置，尖括号不是比较大小。
- `=> _PhotoPageState()` 等同于方法体内 `return _PhotoPageState();`，返回一个新对象。

Widget 描述配置；本例会变化的点赞数放在 State 中。`StatefulWidget` 对象本身仍是不可变配置，并不因为名字里有 Stateful 就允许随意改字段。[Flutter StatefulWidget](https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html)

接着看 State 内的字段和方法片段：

```dart
int _likes = 0;

void _like() {
  setState(() {
    _likes = _likes + 1;
  });
  debugPrint('字段现在是 $_likes');
}
```

- `_likes` 是对象字段，留在这份 State 内；开头的 `_` 表示库内私有。
- `_like` 是点击时要调用的方法，不是声明时立刻执行。
- `() { ... }` 是交给 `setState` 的无参数回调。
- 回调**同步执行**，先把 `_likes` 加一；`setState` 再通知框架安排 build。
- 因此紧随其后的日志已读到新值；屏幕不必在日志输出前完成绘制。

`setState` 不是存储容器。它调用回调并安排重建；单纯赋值也会改变字段，但不会主动安排这份 State 的 build。[Flutter setState](https://api.flutter.dev/flutter/widgets/State/setState.html)

## 画面在哪里读取字段？

这是 `build` 返回值里的片段：

```dart
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    Text('${widget.photoId}：$_likes 个赞'),
    FilledButton(onPressed: _like, child: const Text('点赞')),
  ],
)
```

`widget.photoId` 读取当前输入配置，`_likes` 读取 State 字段。
`${...}` 把表达式的值放进字符串；`onPressed: _like` 传方法，没有括号，所以这里不会立即调用。
`build` 返回的是界面描述；以后再执行 build，就会重新读取这些值。[Flutter State.widget](https://api.flutter.dev/flutter/widgets/State/widget.html)

## 先预测，再展开

**预测 1：** 初始为 0，调用 `_like()` 后，日志打印 0 还是 1？

<details>
<summary>答案与容易错的原因</summary>

打印 1。回调已同步修改字段。把“屏幕稍后更新”误读成“字段稍后才修改”，就会答成 0。

</details>

**预测 2：** 把 `setState` 删掉，只留 `_likes = _likes + 1;`，数字一定永远不会变吗？

<details>
<summary>答案与容易错的原因</summary>

不能说“永远”。字段会变，只是这次赋值没有安排 build；若之后因别的原因重建，画面也可能读到新值。
偶尔看见它更新，不证明可以省略状态通知；没有更新，也不代表赋值失败。

</details>

**预测 3：** 把 `int _likes = 0;` 移进 `build` 开头，每次 build 会保留上次值吗？

<details>
<summary>答案与容易错的原因</summary>

不会。它变成每次调用 build 都重新创建并初始化的局部变量；持续保留的本地 UI 状态应由这份 State 的字段持有。
“代码仍写在 State 类里”不等于“变量就是对象字段”，要看它是否写在方法体内。

</details>

## 微练习：一次加两个赞

只修改 `_like` 中的一行，让一次点击增加 2。先写出连续点击两次后的字段值，再运行观察。

<details>
<summary>修改答案</summary>

改为 `_likes = _likes + 2;`，仍放在同步的 `setState` 回调中。初始 0，点击两次后为 4。
不要改成在 `build` 里加 2，否则任何一次重建都会改变点赞数。

</details>

<details>
<summary>可运行版本：完整替换独立 Flutter 练习项目的 lib/main.dart</summary>

以下是原创最小程序，使用 Flutter 自带 Material 组件，不访问后端。运行方法见 [练习入口](../labs/beginner/README.md)，也可打开 [独立代码文件](../labs/beginner/flutter_state_demo.dart)。只替换练习项目文件；本页不宣称已在你的运行环境执行。

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: PhotoPage(photoId: '照片 A')));

class PhotoPage extends StatefulWidget {
  const PhotoPage({super.key, required this.photoId});
  final String photoId;

  @override
  State<PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  int _likes = 0;

  void _like() {
    setState(() {
      _likes = _likes + 1;
    });
    debugPrint('字段现在是 $_likes');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('State 练习')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${widget.photoId}：$_likes 个赞'),
            FilledButton(onPressed: _like, child: const Text('点赞')),
          ],
        ),
      ),
    );
  }
}
```

输入：点击“点赞”。观察点：按钮上方数字和调试日志。预期：每点一次增加 1；不要用 build 次数作为点击次数。

</details>

## 到这里可以停

合上答案，能指出 `photoId`、`_likes` 和 `setState` 各自负责什么，再继续 [第 06 课](06-lifecycle.md)。
暂时不用背 Widget 树的全部规则；想对照项目时，先看 [Portrait 专题的生命周期表](../modules/portrait.md)，它是已有源码学习快照，不是本课重新核验的当前实现。

官方资料检索：2026-09-10。适用于链接所述 Dart/Flutter API；运行前以练习环境的 SDK 与分析器结果为准。
