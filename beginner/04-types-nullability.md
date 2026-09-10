# 04 · 尖括号和问号在告诉我什么？

[课程目录](README.md) · [上一课](03-future-await.md) · [下一课](05-widget-state.md)

这一课只解决一个问题：**还没有运行代码，怎样从类型看出“里面放什么”和“可能没有值”？**

## 开始前先判断

先修：认识 `String`、`int`、函数参数，以及[第 03 课](03-future-await.md)的 `Future<String>`。
如果你能解释 `Map<String, int>` 为什么查找时仍可能得到 `null`，可先做第二步的预测题。
这一课先学会读常见类型，不要求你自己设计一个泛型类，也不要求一次掌握所有空安全规则。

## 第一步：先看容器，再看里面允许放什么

**独立运行：**

```dart
void main() {
  List<String> pets = ['米粒', '小白'];
  Map<String, int> photoCounts = {'米粒': 3};
  print(pets[0]);
  print(photoCounts['米粒']);
  print(photoCounts['小白']);
}
```

`List<String>` 表示列表里的元素是字符串；`pets[0]` 取第一个元素，因为序号从 `0` 开始。
`Map<String, int>` 表示“字符串键 → 整数值”的对应关系；本例用宠物名查照片数。
这里的 `<...>` 是类型参数，也就是先确定容器，再说明它存什么类型。这种写法叫泛型。
前两次打印分别得到“米粒”和 `3`；第三次得到 `null`，因为 Map 中还没有“小白”这个键。
“已有的值是 int”与“每个键都存在”是两件事，因此 Map 的 `[]` 查找结果是 `int?`。

把上一课也放进来一起读：

| 类型 | 现在先读成什么 |
| --- | --- |
| `List<String>` | 列表中的每个元素是字符串 |
| `Map<String, int>` | 用字符串键查找整数值 |
| `Future<String>` | 成功完成时交出字符串的 Future |

尖括号不表示“小于”“大于”，也不表示里面已经有数据；空列表也可以是 `List<String>`。
泛型写法见 [Dart Generics](https://dart.dev/language/generics)，查找缺失键的规则见 [Map operator []](https://api.dart.dev/dart-core/Map/operator_get.html)。

## 第二步：允许没有值，就把缺失的情况写出来

**独立运行：**

```dart
String displayName(String? name) {
  return name?.trim() ?? '尚未选择';
}

void main() {
  print(displayName(null));
  print(displayName(' 米粒 '));
  print(displayName(''));
}
```

`String?` 表示参数可以是字符串，也可以是 `null`；`String` 则不允许 `null`。
`null` 表示这里没有字符串值，它不是空字符串 `''`，也不是字符组成的 `'null'`。
`name?.trim()` 表示有字符串才调用 `trim()` 去掉两端空白；若 `name` 是 `null`，这部分结果就是 `null`。
`??` 在左边为 `null` 时才使用右边的备用值，所以本例的缺失值会显示“尚未选择”。
这个函数的返回类型仍是 `String`，因为两条路径最后都有一个字符串。

**先预测：**第三次传入空字符串 `''`，会打印“尚未选择”吗？

<details>
<summary>看答案与错误原因</summary>

不会，会打印一个空行。空字符串也是一个存在的字符串，`??` 只处理 `null`。
如果答“会”，可能把“内容为空”和“没有值”混在了一起。若产品要求空白名称也显示占位，需要另外判断字符串是否为空。

</details>

看到 `name!` 时，把它读成“我在这里断言 name 不是 null”。若实际是 `null`，运行时会失败。
`!` 不会产生一个缺失的值，也不会帮你等到值准备好；先用判断、`?.` 或合适的 `??` 表达缺失行为。
这些符号的边界见 [Dart 空安全说明](https://dart.dev/null-safety/understanding-null-safety)。

## 第三步：required 与 late 分别把责任交给谁？

**独立运行：先看命名参数。**

```dart
String makeTitle({required String petName, int count = 0}) {
  return '$petName：$count张照片';
}

void main() {
  print(makeTitle(petName: '米粒'));
  print(makeTitle(petName: '小白', count: 2));
}
```

函数参数外面的 `{ ... }` 表示命名参数，调用时写 `petName: '米粒'` 来说明给哪个参数传值。
`required` 要求调用方必须提供 `petName`；`String` 再要求提供的值不能是 `null`。
`count = 0` 给未传入的数量一个默认值，因此两次输出分别是“米粒：0张照片”和“小白：2张照片”。
`required` 自己不检查空字符串，也不等于非空类型；例如 `required String? petName` 仍允许显式传 `null`。
规则入口：[Named parameters](https://dart.dev/language/functions#named-parameters)。

**独立运行：再看稍后赋值。**

```dart
void main() {
  late String title;
  title = '米粒的照片';
  print(title);
}
```

这段无初始值的 `late String title` 把责任交给编写初始化流程的人：必须在读取前完成赋值。
当前例子确实先赋值再打印，所以能输出标题；这种简单情况直接初始化更清楚，这里只是辨认语法。
如果实际流程漏掉赋值而先读取，`late` 不会等待，也不会自动提供默认值，会在运行时失败。
它适合初始化顺序有保证但声明时无法赋值的情况；不要为了消除错误提示到处加 `late` 或 `!`。

## 修改练习：缺少照片数时显示零

写 `int countFor(Map<String, int> counts, String petName)`：存在对应键就返回照片数，缺失就返回 `0`。
用 `{'米粒': 3}` 分别查询“米粒”和“小白”，要求输出 `3` 与 `0`，不要使用 `!`。
先想清楚：本练习选择 `0` 是给定的显示要求，不是说所有系统都可以把缺失数据当作零。

<details>
<summary>参考解：独立运行</summary>

```dart
int countFor(Map<String, int> counts, String petName) {
  return counts[petName] ?? 0;
}

void main() {
  final counts = <String, int>{'米粒': 3};
  print(countFor(counts, '米粒'));
  print(countFor(counts, '小白'));
}
```

`<String, int>{...}` 在 Map 字面量上指定类型，与前面写 `Map<String, int> counts` 对应。
若写成 `counts[petName]!`，缺失键会造成失败，不能达到“缺少时显示零”的要求。

</details>

## 运行小实验，再判断是否完成

打开 [types.dart](../labs/beginner/types.dart)，在知识库根目录运行 `dart labs/beginner/types.dart`。
实验没有外部输入，会检查列表、缺失键、空值备用显示、Future 结果和命名参数，最后输出 `PASS types`。
它只验证类型与这些给定的显示规则，没有从照片名推导真实宠物身份；项目数据归属见[数据身份基础卡](../foundations/storage-identity.md)。

- 看见三个常用泛型类型，能用自己的话说明它们的元素、键值或成功结果类型。
- 能解释 `String?`、`?.`、`??` 分别出现在哪里，以及空字符串为什么不会触发 `??`。
- 知道 `required` 约束调用方传参；无初始值的 `late` 要求读取前赋值；`!` 失败时不会修复数据。

资料核对：2026-09-10；采用 Dart 3 空安全语法，示例为原创教学内容。

[上一课：Future 与 await](03-future-await.md) · [下一课：Widget 与 State](05-widget-state.md)
