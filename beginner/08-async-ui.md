# 08 · 等待结果时，页面怎样显示忙碌和失败？

[上一课：配置更新](07-config-updates.md) · [课程入口](README.md) · [下一课：旧结果](09-stale-results.md)

本课只回答一个问题：**一次异步操作怎样安全地结束等待并显示结果？**

先修：前四课的函数、回调、`Future/await`、布尔条件与 `String?`，以及第 05 课的 State/setState。
本课接着解释 `try/catch/finally`，把异步等待接到加载、失败和重试的 UI 上。
练习只允许同一时间一个操作，忙碌时拒绝重复点击；输入不在中途切换。第 09 课再放开这个限制。

## 先把代码放对地方

想直接运行，复制 [完整异步示例](../labs/beginner/flutter_async_demo.dart)，步骤参照 [练习入口](../labs/beginner/README.md)，无需手动拼接片段。
想练习组装，也可以沿用第 05 课的 import、main 和 `PhotoPage` 外壳，**把 `_PhotoPageState` 类的大括号内部整体替换**为本页接下来的四个代码块：字段与模拟 I/O、加载方法的两半、build。
`_likes`、`_like` 以及前两课附加的生命周期练习不保留，避免把不同练习混在一起。

第一组是 State 字段与模拟 I/O 方法：

```dart
bool _busy = false;
String _message = '尚未加载';
String? _error;

Future<String> _fetchMessage() async {
  await Future<void>.delayed(const Duration(seconds: 2));
  return '照片信息已准备好';
}
```

`_busy` 控制正在等待的状态，也就是常说的 loading；可用来显示进度和禁用重复操作。
`_message` 保存最近成功文本；`_error` 用 null 表示没有错误。
`Future<String>` 表示未来完成时给出字符串的结果；完成也可能失败，它不是已经拿到的 String。
`async` 标记异步函数，`await` 等待 Future 完成后取得值，再继续当前函数；等待时 UI 仍可处理其他事件。
`Future<void>.delayed(...)` 在本例模拟两秒等待，没有要返回的值；`Duration` 描述时长，模拟结束后 return 字符串。这里不访问网络。[Dart async/await](https://dart.dev/libraries/async/async-await)

## 加载方法：先开始，再等待

第二组上半段如下；它与下一代码块相接，**本块单独不构成完整方法**。
`Future<void>` 说明调用者可以等待这个方法完成，但它不提供结果值；UI 数据通过 State 字段保存。

```dart
Future<void> _load() async {
  if (_busy || !mounted) return;
  setState(() {
    _busy = true;
    _error = null;
  });
  try {
    final result = await _fetchMessage();
    if (!mounted) return;
    setState(() {
      _message = result;
    });
```

- `_busy || !mounted`：已有操作或 State 不在树中，就立即返回。
- 第一个同步 `setState` 标记忙碌并清掉旧错误；等待结果前就通知界面。
- `try` 包住可能失败的步骤；成功时继续执行，抛出错误时转到匹配的 catch，跳过 try 中尚未执行的步骤。
- `result` 是这次成功返回的字符串；等待失败时不会执行下面那次 `_message` 赋值。
- `await` 后重新检查 mounted，因为等待期间页面可能已被移除。
- 确认可更新后，用同步回调把结果写进 `_message`。

I/O 放在 `setState` 外等待；交给 `setState` 的回调不能标记 `async`，它要求同步完成状态修改。[Flutter setState](https://api.flutter.dev/flutter/widgets/State/setState.html)

第二组下半段，紧接上一块粘贴：

```dart
  } catch (error) {
    debugPrint('加载失败：$error');
    if (!mounted) return;
    setState(() {
      _error = '加载失败，请重试';
    });
  } finally {
    if (mounted) {
      setState(() {
        _busy = false;
      });
    }
  }
}
```

`catch (error)` 接收被抛出的错误对象；本例打印它作调试观察，界面使用固定的失败提示。
`finally` 在成功、失败或 try/catch 中提前 return 后仍会执行；因此它也必须检查 mounted，不能以为前面的 return 已经保护了最后一次 `setState`。[Dart 错误处理](https://dart.dev/language/error-handling)
已 dispose 的 State 不允许调用 `setState`。mounted 检查是在防止非法 UI 更新，并没有取消底层 Future。[Flutter State.mounted](https://api.flutter.dev/flutter/widgets/State/mounted.html)

## 把状态显示出来

第三组是完整 build 方法；这是最后一组需要放进 State 类的代码：

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(_message),
      Text(_error ?? ''),
      FilledButton(
        onPressed: _busy ? null : _load,
        child: Text(_busy ? '加载中…' : '加载 / 重试'),
      ),
    ])),
  );
}
```

`_error ?? ''` 在错误为 null 时显示空文本。`条件 ? A : B` 按条件选择一个值。
`onPressed` 为 null 时按钮禁用；方法开头还检查 `_busy`，即使下一次 build 还没发生，也挡住重复调用。[Flutter FilledButton](https://api.flutter.dev/flutter/material/FilledButton-class.html)
失败只更新 `_error`，保留最近成功的 `_message`；finally 恢复按钮，用户可以重试。

## 先预测，再展开

**预测 1：** 加载刚开始，按钮还没来得及重建，又调用一次 `_load()`，会同时发两次请求吗？

<details>
<summary>答案与容易错的原因</summary>

本例不会。第一次调用在 await 前同步把 `_busy` 设为 true，第二次在入口就返回。
只把按钮画成灰色是不够的；方法入口的字段判断补上了显示尚未更新时的空隙。

</details>

**预测 2：** 等待中 State 被 dispose；结果返回后执行 `if (!mounted) return;`，finally 还会运行吗？

<details>
<summary>答案与容易错的原因</summary>

会。finally 再检查 mounted 为 false，因此不会调用 setState。若删掉最后这个保护，前面的 return 仍挡不住非法更新。
普通 rebuild 并不等于 dispose：前者继续使用这份 State，后者使它失去更新资格。

</details>

**预测 3：** 把 `_fetchMessage` 调用移进 build，是否能保证“页面加载一次，就请求一次”？

<details>
<summary>答案与容易错的原因</summary>

不能。build 可以多次执行；一次完成后触发的 build 又可能发起下一次请求，造成重复工作甚至循环。
本例由点击回调发起加载，build 只读取字段；别把重建入口当成只运行一次的初始化入口。

</details>

## 微练习：主动制造失败，再恢复

把 `_fetchMessage` 中的 return 改成 `throw Exception('练习失败');`。预测两秒前后按钮和文本，再改回 return 重试。

<details>
<summary>修改答案与观察点</summary>

等待时按钮显示“加载中…”且禁用。失败后显示“加载失败，请重试”，原 `_message` 保留，按钮恢复可点。
恢复 return 后再次点击，开始时清掉旧错误；成功时更新文本，finally 结束忙碌。
若只写 catch 不恢复 `_busy`，页面会永久停在加载中；若吞掉错误不展示，用户不知道失败或如何继续。

</details>

这是可手动运行的原创练习，未作为产品测试执行；模拟 Future 不支持取消，真实资源应由其所有者清理。

## 到这里可以停

能标出三个 UI 阶段，以及 await 后和 finally 内各自的 mounted 检查，就继续 [第 09 课](09-stale-results.md)。
这套互斥示例只解决固定输入下的一次操作；State 存活但输入从 A 换成 B 时，还需要判断结果归属。
可回看 [异步与生命周期](../foundations/async-lifecycle.md)，再读 [Wi-Fi 专题](../modules/wifi.md) 的已有源码学习快照；本课不声称已复核其当前实现。

官方资料检索：2026-09-10。示例按链接中的 API 编写；未测试具体设备、网络或项目后端。
