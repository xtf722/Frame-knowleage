# 语法桌：看不懂一个符号时再来查

[课程目录](README.md)

这里供随手查阅，不是需要从头背完的清单。每次只查阻碍当前理解的一个写法，然后回到例子。

| 写法 | 先怎样读 | 注意 / 去哪补 |
| --- | --- | --- |
| `String name = 'A';` | name是保存字符串的变量，先放A | [01 值与函数](01-values-functions.md) |
| `name = 'B';` | 把B赋给name | 单个等号是赋值 |
| `a == b` / `a != b` | 相等吗 / 不相等吗 | 结果是bool，不会把b赋给a |
| `final name = ...` | 这个变量只赋值一次 | 它指向的List等对象不一定不可修改 |
| `const ...` | 编译时就能确定的常量 | [04 类型](04-types-nullability.md) |
| `showPhoto` | 这个函数本身 | [02 回调](02-callbacks.md) |
| `showPhoto()` | 现在调用它 | 函数调用的括号也放参数 |
| `() { ... }` | 一个没有名字、没有参数的函数 | 何时执行由接收它的代码决定 |
| `(value) { ... }` | 一个接收value的匿名函数 | 参数来自调用它的一方 |
| `() => value` | 简写的函数，返回一个表达式 | 不等于立即返回外层方法 |
| `void Function()` | 无参数、不提供返回值的函数类型 | 可作为回调参数的类型 |
| `Future<String>` | 稍后完成并提供String的异步结果 | [03 Future](03-future-await.md) |
| `Future<void>` | 稍后完成，不提供业务结果值 | 仍可能失败 |
| `await task` | 当前异步函数等待task完成 | 调用开始工作与等待完成是两件事 |
| `List<String>` | 元素类型是String的列表 | [04 泛型](04-types-nullability.md) |
| `String?` | 允许字符串或null | null代表没有值，和空字符串不同 |
| `value?.method()` | value不为null时才调用方法 | 不会创建缺失的对象 |
| `value ?? fallback` | value是null时用fallback | 不会因为空字符串而使用fallback |
| `value!` | 告诉系统这里不为null | 判断错会在运行时出错，别用它掩盖没处理的情况 |
| `required this.petId` | 调用构造函数时必须提供petId | 是否允许null由字段类型决定 |
| `late` | 初始化可以稍后，但使用前必须满足初始化要求 | 它不是默认值 |
| `class PhotoInfo { ... }` | 定义这种对象有哪些字段和方法 | [05 类与对象](05-widget-state.md) |
| `PhotoInfo(this.photoId)` | 构造对象时把参数存进自己的字段 | `PhotoInfo('A')` 是构造调用 |
| `first.photoId` | 读取first这个对象保存的字段 | 同一个类的不同对象可以保存不同值 |
| `extends StatefulWidget` | 继承StatefulWidget提供的成员与约定 | [05 Widget与State](05-widget-state.md) |
| `if (...) return;` | 条件成立就结束当前函数 | 外层调用者不一定跟着结束 |
| `a || b` / `a && b` | 至少一个成立 / 两个都成立 | 条件按短路规则求值 |
| `!mounted` | 这份State已不再挂载 | [08 异步界面](08-async-ui.md) |
| `widget.petId` | 这份State当前配置里的petId | [07 配置变化](07-config-updates.md) |
| `oldWidget.petId` | 上一次配置里的petId | 不是另一份旧State |
| `super.method()` | 调用继承的父类实现 | 具体做什么要看父类，不能凭super推断有一套隐藏业务 |
| `@override` | 声明这个成员覆盖继承的成员 | 帮助检查拼写和签名 |
| `_name` | Dart库内私有的名字 | 私有范围是library，不是仅这个class |
| `try / catch / finally` | 尝试 / 处理异常 / 收尾 | [08 错误恢复](08-async-ui.md) |

这些是阅读提示，详细语义以课程的示例与官方来源为准。暂时遇到 `covariant`、mixin 等未展开写法，可以先读参数、返回类型和方法体；它们值得单独学，但不必每次遇到就离开当前用户动作。
