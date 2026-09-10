# 02 · 函数怎样交给别人执行？

[课程目录](README.md) · [上一课](01-values-functions.md) · [下一课](03-future-await.md)

这一课只解决一个问题：**代码写下一个函数名字时，是已经执行了，还是把它交给别人，等别人决定何时执行？**

## 开始前先判断

先修：会区分函数定义、参数、调用和返回值；不确定时回到[第 01 课](01-values-functions.md)。
如果你已经能解释 `showPhoto` 与 `showPhoto()`，可先做第二步的预测题。
如果还说不清接收方在哪一行调用回调，就从第一步开始，不必重复背术语。
本课所有标有“独立运行”的代码都各自包含一个 `main`，请分别运行。

## 第一步：先把函数存起来，再调用它

**独立运行：**

```dart
void showPhoto() {
  print('显示米粒的照片');
}

void main() {
  void Function() action = showPhoto;
  print('函数已保存');
  action();
}
```

`showPhoto` 的定义只是说明执行它时应该做什么，不会因为定义出现在文件前面就先打印。
`action = showPhoto` 把函数本身交给变量 `action`，这一步没有进入函数体。
`void Function()` 是这个变量的类型：它存放一个“不接收参数，也不提供可用返回值”的函数。
注意，类型里的 `()` 描述参数列表；真正执行的是下面那句 `action()`。
因此顺序是先显示“函数已保存”，再显示“显示米粒的照片”。

**先预测：**只删掉 `action();`，还会显示照片那一行吗？

<details>
<summary>看答案与错误原因</summary>

不会。函数已经保存，但还没人调用它。
如果答“会”，可能把“拿到函数”当成了“进入函数体”。先问自己：执行用的那对括号在哪里？

</details>

## 第二步：接收方决定在哪一行执行

**独立运行：**

```dart
void openAlbum(void Function() onReady) {
  print('打开相册');
  onReady();
  print('相册流程结束');
}

void main() {
  openAlbum(() { print('显示米粒的照片'); });
}
```

`openAlbum` 接收一个函数参数，把它叫作 `onReady`。
`main` 传进去的 `() { ... }` 是匿名函数：不另外取名字，直接在调用位置描述动作。
传入时没有执行匿名函数里的 `print`；执行先进入 `openAlbum`。
`openAlbum` 在自己的 `onReady();` 那一行，才调用收到的函数。
这个交给接收方调用的函数，就叫 **callback，回调**。
这里三次打印都按同步顺序执行。回调不自带延迟，也不自动变成异步任务。

**先预测：**如果把 `onReady();` 移到“相册流程结束”的打印后面，输出顺序是什么？

<details>
<summary>先把三个输出写下来，再展开</summary>

“打开相册” → “相册流程结束” → “显示米粒的照片”。
接收方改变了调用位置，回调执行的位置也跟着改变。
若你认为名字叫 `onReady` 就必须提前执行，误解在于把名字当成了调度规则；要找真正的调用语句。

</details>

## 第三步：长写法和箭头写法表达同一个动作

**独立运行：**

```dart
void showPhoto() {
  print('显示米粒的照片');
}

void main() {
  void Function() first = () { showPhoto(); };
  void Function() second = () => showPhoto();
  first();
  second();
}
```

`first` 保存一个匿名函数，函数体里只有一条调用语句。
`second` 用 `=>` 写成单个表达式；在这个例子里，调用它时同样会执行 `showPhoto()`。
`=>` 不是“延迟执行”按钮，也不是异步标记。暂时不执行，是因为你创建了函数，还没有调用它。
多个步骤可以写进 `{ ... }`；箭头后面只能是一个表达式，不是任意一串语句。

下面两种交付方式在本例都可以：`openAlbum(showPhoto)` 和 `openAlbum(() => showPhoto())`。
前一种直接交付已有函数；后一种交付新函数，新函数被调用后再调用 `showPhoto`。
`openAlbum(showPhoto())` 则不符合这里的参数要求：它先执行 `showPhoto`，其 `void` 结果不能作为所需的函数。
最后这一种是**错误写法的说明**，不要把它当作可运行示例。

官方核对入口：[函数作为值、函数类型和匿名函数](https://dart.dev/language/functions)。

## 修改练习：让接收方连续调用两次

写一个 `showTwice(void Function() action)`，在它里面调用 `action` 两次。
在 `main` 里传入打印“下一张照片”的回调，预期恰好打印两次。
不要在 `main` 里调用两次 `showTwice`，因为我们要练习的是接收方的调用责任。

<details>
<summary>参考解：独立运行</summary>

```dart
void showTwice(void Function() action) {
  action();
  action();
}

void main() {
  showTwice(() => print('下一张照片'));
}
```

如果只有一次输出，检查接收方是否只有一处 `action()`。
如果有四次输出，检查是否同时把接收方的内部调用和外部调用都重复了。

</details>

## 运行小实验，再判断是否完成

打开 [callbacks.dart](../labs/beginner/callbacks.dart)，在知识库根目录运行 `dart labs/beginner/callbacks.dart`。
实验不接收外部输入：观察“保存函数时没有执行”以及“接收方在调用点同步执行”；程序会自动比对顺序，最后输出 `PASS callbacks`。
其中 `void Function(String) record` 仍是函数参数，只是每次调用要传入一个字符串，用来记录发生了什么。
实验末尾的 `if` 在条件成立时进入检查分支；`throw StateError(...)` 表示检查失败，先把它当作实验的报错出口即可。
它没有模拟 Flutter 按钮或事件循环；以后读 `onPressed` 时，再去找框架什么时候调用传入的函数。

- 你能区分 `showPhoto`、`showPhoto()`、`() => showPhoto()`。
- 你能指着接收方的调用行，解释回调为什么此时执行，以及它可能被调用多次或完全不被调用。
- 你能完成两次调用的修改练习，并说明“有回调”不等于“有异步”。

资料核对：2026-09-10；采用 Dart 3 基础函数语法。程序核对范围仅是教学执行顺序。

[上一课：值与函数](01-values-functions.md) · [下一课：await 到底在等哪里？](03-future-await.md)
