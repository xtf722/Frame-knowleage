# 01 · 一行代码怎样把输入变成结果？

[课程目录](README.md) · [下一课：回调](02-callbacks.md)

这一课只解决一个问题：**拿到一个值后，代码怎样修改、比较或把它交给函数，得到下一步要用的结果？**

例子都是独立的宠物照片教学程序，不是 Frame 项目源码。

## 开始前先判断

不需要先修知识。这里的 `main` 是程序开始执行的位置，`print` 用来把结果显示到控制台。
每段标有“独立运行”的代码，都可以单独放进一个 `.dart` 文件运行；不要把多个 `main` 合并到同一个文件。

如果你能解释 `count = count + 1`、`count == 3`、`makeTitle('米粒')` 三行分别做什么，可以跳到修改练习。
遇到不认识的符号，先读下面的小例子，不必提前背完整的 Dart 语法。

## 第一步：给值起名字，再跟着执行顺序走

**独立运行：**

```dart
void main() {
  String petName = '米粒';
  int count = 2;
  count = count + 1;
  bool enough = count == 3;
  print(petName);
  print(count);
  print(enough);
}
```

先从 `main` 的第一句往下看：

1. `String petName` 声明一个用来存字符串的变量，第一次赋给它的值是 `'米粒'`。
2. `int count = 2` 表示照片数量从整数 `2` 开始。
3. `count = count + 1` 先算右边：旧的 `2 + 1` 得到 `3`，再把 `3` 赋给左边。
4. `count == 3` 是比较，结果是布尔值 `true`，存进 `enough`。
5. 三次 `print` 依次显示名字、数量、比较结果。

`=` 表示赋值；`==` 表示判断是否相等。读代码时把它们读成不同的动作。
`String`、`int`、`bool` 分别说明这里期待字符串、整数和真假值。

**先预测：**在 `bool enough = count == 3;` 后加上 `count = 8;`，最后打印的 `enough` 会变成 `false` 吗？

<details>
<summary>自己说出理由后，再看答案</summary>

不会，仍然是 `true`。赋值那一刻已经计算完比较结果；以后修改 `count`，不会自动重新计算 `enough`。
如果你认为它会跟着变化，可能把“保存本次结果”理解成了“建立永久关联”。这段代码没有建立这种关联。

</details>

## 第二步：把重复的计算放进函数

**独立运行：**

```dart
String makeTitle(String petName, int count) {
  return '$petName有$count张照片';
}

void main() {
  final title = makeTitle('米粒', 3);
  print('准备显示');
  print(title);
}
```

`String makeTitle(...)` 前面的 `String` 表示这个函数会返回字符串。
括号里的 `petName` 和 `count` 是参数：函数执行时，用它们接住调用方提供的值。
`makeTitle('米粒', 3)` 才是真正调用：这一轮 `petName` 是 `'米粒'`，`count` 是 `3`。
字符串里的 `$petName`、`$count` 会插入它们当前的值。
`return` 把结果交回调用位置，结果随后存进 `title`；它自己不负责显示到控制台。
`void main()` 的 `void` 则表示调用方不应从这个函数取得一个可用的返回值。

**先预测：**如果删去 `print(title);`，控制台还会自动显示“米粒有3张照片”吗？

<details>
<summary>看答案与常见误解</summary>

不会，只显示“准备显示”。`return` 把值交给调用方，`print` 才负责在这个实验里显示它。
如果答“会”，请重新区分“函数算出了值”和“程序要求把值打印出来”。

</details>

## 第三步：这次赋值之后，还允许换一个值吗？

**独立运行：**

```dart
void main() {
  var count = 2;
  count = 3;
  final title = '米粒有$count张照片';
  const maxCount = 10;
  print(title);
  print(count < maxCount);
}
```

`var count = 2` 让 Dart 从初始值推断出 `count` 是 `int`，以后仍可以给它赋另一个整数。
`final title` 表示变量只能赋值一次；这里的字符串是在运行时用 `count` 算出来的。
`const maxCount` 要求值是编译时就能确定的常量，同时这个变量也不能重新赋值。
`final` 限制的是变量重新赋值；若以后存的是可修改的集合，集合内容不一定被锁住。
现在不用展开集合规则，只需先学会：会变化的数量用普通变量，一次算好的标题可以用 `final`。

官方核对入口：[变量与 final / const](https://dart.dev/language/variables)、[函数参数与返回值](https://dart.dev/language/functions)。

## 修改练习：让函数算出下一张照片的序号

自己写一个 `int nextNumber(int current)`，输入 `4` 时返回 `5`。
在 `main` 中保存返回结果，再把它打印出来；函数内部不要调用 `print`。
先写完运行，再展开参考解。你可以改变输入，检查是不是仍然只增加 `1`。

<details>
<summary>参考解：独立运行</summary>

```dart
int nextNumber(int current) {
  return current + 1;
}

void main() {
  final next = nextNumber(4);
  print(next);
}
```

预期只输出 `5`。若函数里面打印了 `5` 却没有返回它，调用方就没有拿到要求的计算结果。
若你把 `current = 5` 写成答案，它只适用于一个输入，换成 `8` 就无法正确得到 `9`。

</details>

## 什么时候算完成？

- 不看答案，说出 `=` 与 `==` 的区别，并解释第一题为什么没有自动重新计算。
- 指着 `makeTitle`，说清哪里定义参数、哪里真正调用、结果回到哪里。
- 自己完成修改练习，换两个输入仍能得到正确结果。

下一课会把“传入一个字符串”改成“传入一个函数”。不用现在记住“回调”这个名称的全部含义。
资料核对：2026-09-10；采用 Dart 3 的基础语法，不涉及项目当前实现或硬件行为。

[上一页：课程目录](README.md) · [下一课：函数怎样交给别人执行？](02-callbacks.md)
