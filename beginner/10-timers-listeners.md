# 10：是谁安排下一次回调，结束时谁来取消？

[上一课：旧结果](09-stale-results.md) · [课程目录](README.md) · [下一课：读源码](11-source-reading.md)

先修：[02 回调](02-callbacks.md)、[04 空值](04-types-nullability.md)、[06 生命周期](06-lifecycle.md)；读到 Stream 清理时用到 [08 的 finally](08-async-ui.md)。本课先学 Timer；Stream 和 listener 可以第二次回来再读。

## 第一步：让一个函数稍后执行

完整 Dart 小程序，不依赖 Flutter：

```dart
import 'dart:async';

void main() {
  Timer(Duration(seconds: 1), () {
    print('切换下一张');
  });
  print('已安排计时');
}
```

`Timer` 接收等待时长和一个回调。创建计时器后，当前函数可以继续；到时间时，计时器才调用回调。本例 `Timer(...)` 是一次性的，`Timer.periodic(...)` 才表示重复安排。

**预测 1：会先打印哪一句？这段代码会每秒一直换图吗？**

<details>
<summary>展开答案与原因</summary>

先打印“已安排计时”，约一秒后打印“切换下一张”。只执行一次。把“一秒后调用一次”看成“每秒调用一次”会误读播放策略。

</details>

## 第二步：保存 Timer，才能在需要时取消

下面三块是同一份 State 中的字段和方法片段，`advance` 表示已有的换页方法：

```dart
Timer? nextPhotoTimer;

void scheduleNext() {
  nextPhotoTimer?.cancel();
  nextPhotoTimer = Timer(Duration(seconds: 3), advance);
}
```

`Timer?` 允许暂时没有计时器；`?.cancel()` 表示存在时才取消。先取消旧计时再安排新的计时，可以让这个字段只管理一份有效安排。

```dart
@override
void dispose() {
  nextPhotoTimer?.cancel();
  super.dispose();
}
```

`cancel()` 会取消计时器未来的回调，重复取消也可以；它不能倒回去撤销已经执行的回调。[Timer.cancel 官方 API](https://api.dart.dev/dart-async/Timer/cancel.html)

**预测 2：旧计时还剩一秒时又调用 `scheduleNext()`，这段代码会保留哪个计时安排？**

<details>
<summary>展开答案与原因</summary>

旧安排被取消，新的三秒安排保留。字段重新赋值只会改变变量指向；真正取消旧安排的是前面的 `cancel()`。

</details>

## 第三步：把一次结果与连续通知分开

| 写法 | 可以先怎样理解 | 通常怎么结束 |
| --- | --- | --- |
| `Future<String>` | 一次异步完成及其结果 | 等待完成，或按底层能力取消 |
| `Stream<String>` | 一串陆续到来的事件 | 取消自己的 subscription |
| `addListener(callback)` | 让对象变化时通知这个回调 | `removeListener` 移除同一个回调 |

下面是拥有一个 Stream 订阅的普通异步函数示意；假设 `states` 和 `waitUntilDone` 已由调用方提供：

```dart
final subscription = states.listen((String state) {
  print(state);
});
try {
  await waitUntilDone();
} finally {
  await subscription.cancel();
}
```

`listen` 返回订阅对象。`finally` 保证等待正常完成或抛错时都尝试取消；清理不能只放在成功路径的末尾。取消后该订阅不再接收事件；返回的 Future 表示相关清理何时完成。[StreamSubscription.cancel](https://api.dart.dev/dart-async/StreamSubscription/cancel.html)

Flutter 的 `dispose()` 是同步方法，不要为了复制上面的 `await` 把它改成 async。如果某个资源的下一步操作必须等清理完成，需要由能等待的外层所有者安排，而不是假装 dispose 可以被框架 await。

对 `ChangeNotifier` 类对象，常见配对是：

```dart
controller.addListener(handleChanged);
// 不再监听时，移除之前登记的那个回调。
controller.removeListener(handleChanged);
```

具体对象通过 `notifyListeners()` 发出通知。[ChangeNotifier 官方 API](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html)

**预测 3：页面借用了 App 创建的 controller，页面结束时应直接 dispose 整个 controller 吗？**

<details>
<summary>展开答案与原因</summary>

先找谁拥有这个对象。页面通常只移除自己登记的 listener；App 创建并共享的 controller 由其持有者决定最终释放。把共享对象提前 dispose，其他使用它的页面也会受影响。

</details>

## 自己改一处

设计一个 `pauseSlideshow()`：暂停时取消下一张安排，但保留当前照片。恢复时复用 `scheduleNext()`。

<details>
<summary>参考解</summary>

```dart
void pauseSlideshow() {
  nextPhotoTimer?.cancel();
  nextPhotoTimer = null;
}
```

这里只暂停自动前进；恢复时会重新计算三秒，不是接着之前剩余的一秒。若产品要求保留剩余时间，需要另外保存截止时间，不能从 Timer 字段自动得到这个业务规则。

</details>

运行 [timer_cancel.dart](../labs/beginner/timer_cancel.dart)，再去 [Moment 短导读](guided/moment.md) 找“暂停”和“重新安排”两个动作。读 Wi-Fi 时则先看 [Wi-Fi 短导读](guided/wifi.md)，识别哪些通知由 App 持有。

停止点：能为一个 Timer 或 listener 写出“在哪里建立、保存在哪里、在哪里取消”。不要求现在理解 Android 的全部网络回调。官方 API 核对日期：2026-09-10。
