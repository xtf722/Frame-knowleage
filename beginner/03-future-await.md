# 03 · await 到底在等哪里？

[课程目录](README.md) · [上一课](02-callbacks.md) · [下一课](04-types-nullability.md)

这一课只解决一个问题：**一次加载还没完成时，哪一个函数在等，哪一段代码还能继续？**

## 开始前先判断

先修：知道函数从调用处开始执行，知道 `return` 把结果交回；会辨认[第 02 课](02-callbacks.md)中的回调。
如果你已经能预测“先调用、后 await”的顺序，可以直接做第二步和修改练习。
这一课不要求先懂线程、事件循环或网络。下面没有真正下载照片，只用 SDK 制造一个可观察的等待点。

## 第一步：调用已经开始了，结果还没交回来

**独立运行：**

```dart
Future<String> loadPhoto() async {
  print('进入加载函数');
  await Future<void>.delayed(Duration.zero);
  return 'mili.jpg';
}

Future<void> main() async {
  print('main开始');
  final pending = loadPhoto();
  print('main还能继续');
  final fileName = await pending;
  print(fileName);
}
```

`Future<String>` 表示这个函数返回一个 Future：成功完成后可以取得 `String`，也可能以错误完成。
`async` 允许函数体内使用 `await`；它不表示整个函数一开始就被放到另一个线程。
`loadPhoto()` 一被调用，就执行到第一个 `await`，所以先打印“进入加载函数”。
`Future<void>.delayed(Duration.zero)` 安排一次稍后的完成；零时长仍让这里有一个异步等待点。
其中 `void` 表示这次等待没有需要取出的数据，我们只观察何时恢复。
`pending` 拿到的是 Future，`main` 随后还可以打印“main还能继续”。
`await pending` 等到 Future 完成，再把成功结果字符串交给 `fileName`。
本例的“加载开始”是进入这个函数；真实下载何时发生，还要看被调用函数内部的实现。

**先预测：**四行输出是什么顺序？先写下来，不要先运行。

<details>
<summary>看顺序，以及为什么不是另外两种顺序</summary>

`main开始` → `进入加载函数` → `main还能继续` → `mili.jpg`。
如果把“进入加载函数”放到 `main还能继续` 后面，可能以为 `async` 会把开头的同步代码也延后。
如果把 `mili.jpg` 放到 `main还能继续` 前面，可能以为普通函数调用会等到 Future 最终完成才返回。

</details>

## 第二步：把 await 移到调用处，会改变谁的顺序？

保留上面的 `loadPhoto`，**只替换 `main`，这一段不能单独运行**：

```dart
Future<void> main() async {
  print('main开始');
  final fileName = await loadPhoto();
  print('main继续');
  print(fileName);
}
```

这次 `main` 在 `await loadPhoto()` 处等待，所以“main继续”必须等加载结果回来。
等待的是这个 `main` 调用的后续步骤；不意味着其他函数、事件或整个 App 都停止执行。
`await` 不替你启动一个独立线程，也不把所有地方的代码变成同一条等待队列。
先抓住这句话就够了：**当前函数到这里先等，等到完成后再接着执行下面的语句。**

**先预测：**若想在等待期间立即显示“正在加载”，这句 `print` 应放在 `await` 前还是后？

<details>
<summary>看答案与错误原因</summary>

放在前面。放在后面就要等加载完成后才执行，那时“正在加载”已不能提示这段等待。
常见错误是按照自己想看到的画面顺序理解代码，却没检查提示语句是否被当前函数的 `await` 挡住。
这里验证的是控制台顺序；Flutter 何时绘制一帧，需要后面的 Widget / State 课程再讨论。

</details>

## 第三步：等待顺序不等于启动顺序

**独立运行：**

```dart
Future<String> loadPhoto(String petName) async {
  print('开始$petName');
  await Future<void>.delayed(Duration.zero);
  return '$petName.jpg';
}

Future<void> main() async {
  final first = loadPhoto('米粒');
  final second = loadPhoto('小白');
  print(await first);
  print(await second);
}
```

前两句都调用了加载函数，所以开始等待 `first` 前，两次调用就都已经开始。
后两句规定的是 `main` 取结果并打印的顺序：先米粒，再小白。
如果真实操作的小白结果先回来，这里的打印依然要先等米粒；按顺序 `await` 不会把已经启动的小白工作撤回。
两个等待过程可以重叠，这不等于已经证明两个线程在同时执行。此例没有创建 isolate 或后台线程。
要让“米粒完成后才调用小白”，需要先 `await loadPhoto('米粒')`，再写第二次调用。
这段固定成功的模拟只观察顺序；真实操作若可能失败，需要及时为每个 Future 接好错误处理，不能让第二个错误无人接收。

语言机制的核对入口：[async / await 的执行顺序](https://dart.dev/libraries/async/async-await)、[Future 的完成与错误](https://api.dart.dev/dart-async/Future-class.html)。

## 修改练习：先提示，再显示加载结果

使用第一步的 `loadPhoto()`，把 `main` 改成：先打印“正在加载”，拿到结果后再打印“显示：mili.jpg”。
不要手写第二行的文件名；第二行必须使用函数返回的结果。
`loadPhoto` 自己的“进入加载函数”仍会出现，所以完整输出有三行。

<details>
<summary>参考解：仅替换第一步的 main</summary>

```dart
Future<void> main() async {
  print('正在加载');
  final fileName = await loadPhoto();
  print('显示：$fileName');
}
```

预期是“正在加载” → “进入加载函数” → “显示：mili.jpg”。
若第二行界面文案出现了 Future 对象，而不是文件名，检查是否忘记 `await` 就直接使用了 `loadPhoto()` 的返回值。
若加载抛出错误，`await` 也会在这里抛出错误，不会继续打印成功文案；怎样接住错误并更新画面，留到[异步加载时的界面](08-async-ui.md)。

</details>

## 运行小实验，再判断是否完成

打开 [await_order.dart](../labs/beginner/await_order.dart)，在知识库根目录运行 `dart labs/beginner/await_order.dart`。
实验没有外部输入，会分别检查“调用后继续”和“调用处直接等待”，最后输出 `PASS await_order`。
观察打印顺序，不比较毫秒数。这个实验不访问网络，也不代表真实照片加载速度或线程并行能力。

- 能把第一步每一行输出标回对应语句，并说明 `main` 在哪里开始等待。
- 能区分 `Future<String>` 与 `await` 后得到的 `String`。
- 能解释为什么先调用两个函数，再分别 `await`，不等于完成第一个后才启动第二个。

学完后可把[异步与生命周期基础卡](../foundations/async-lifecycle.md)的“时间模型”读一遍；其余内容留到生命周期课。
资料核对：2026-09-10；采用 Dart 3。所有照片加载都是原创教学模拟，不说明 Frame 现行实现。

[上一课：回调](02-callbacks.md) · [下一课：尖括号与问号在说什么？](04-types-nullability.md)
