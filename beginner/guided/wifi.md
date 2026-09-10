# Wi-Fi 导读：连上热点，为什么还显示 Checking

> 本导读沿用 2026-09-09 的 Wi-Fi 专题快照。当前源代码可能变化；这里不刷新源码行为或验证记录。
> 示例是原创教学小模型，不是项目实现；练习只需纸笔，未运行产品测试或设备实验。

## 先准备，再只判断一次“可以继续吗”

先修：[函数](../01-values-functions.md)、[回调](../02-callbacks.md)、[Future 与 await](../03-future-await.md)、[过期结果](../09-stale-results.md)、[源码阅读](../11-source-reading.md)。
如果不清楚“等待结束”和“工作取消”的区别，先回看 [计时器与监听](../10-timers-listeners.md) 的任务清理说明。
开始前，说出 `Future<bool>` 与 `bool` 的区别：前者需要等待，才拿到后者表示的真假结果。
这一关还不需要学习 Wi-Fi 权限、Android API 或密码保存方式。

生活里的场景：你在 Frame 选中家里的热点，输入密码，界面显示已连接，随后停在 Checking。
像走进商场后还要确认目标店铺开没开，连接热点只回答其中一层问题。
本课只追“目标 Wi-Fi 状态”和“业务服务可达”为什么要分开，并在等待后再核对网络。

## 用两位检查员代替平台和服务

`readTargetWifi` 是传入的假函数：返回 `true` 表示目标 Wi-Fi 的链路条件当前成立。
`pingService` 也是假函数：返回 `true` 表示这次服务检查成功；模型假定失败统一返回 `false`。
函数由练习者安排返回值，不接触真实网络，`pingService` 这个教学名字也不表示 ICMP ping。

```dart
Future<String> checkRoute(
  Future<bool> Function() readTargetWifi,
  Future<bool> Function() pingService,
) async {
  final wifiBefore = await readTargetWifi();
  if (!wifiBefore) return '等待目标 Wi-Fi';
  final serviceReady = await pingService();
  if (!serviceReady) return '等待业务服务';
  final wifiAfter = await readTargetWifi();
  if (!wifiAfter) return '网络已经变化';
  return '网络检查通过';
}
```

先给三次检查依次填入 `true`、`true`、`false`，预测最终返回哪一句。

## 逐句读：同一个网络检查为什么出现两次

1. `Future<String>` 表示稍后得到一段状态文字；`async` 允许函数体使用 `await`。
2. `Future<bool> Function()` 表示“一种不接收参数、调用后返回 Future 的函数类型”。
3. `readTargetWifi` 和 `pingService` 是两份传入的检查动作；此时传的是函数，并没有执行。
4. `readTargetWifi()` 后的圆括号表示现在调用；`await` 等它给出真假结果，再保存在 `wifiBefore`。
5. `!` 把真假反过来：检查不通过时条件成立，`return` 提前结束这次判断。
6. `serviceReady` 保存服务检查结果，第二个 `if` 检查它。前一关失败已退出，便不会执行到这里。
7. `wifiAfter` 保存再次读目标 Wi-Fi 的结果；第三个 `if` 检查服务等待期间网络有没有变化。
8. 最后一行表示这几项网络检查都通过；模型没有检查绑定、账号或媒体权限。

“刚才是真的”与“现在仍是真的”是两个问题。
第二次读网络不是为了重复劳动，而是补上服务等待期间可能发生变化的那段时间。

## 把检查员放回 Wi-Fi 页面

专题记录：`FrameWifiDesignPage` 在 `_handoffWhenReady` 中核对目标 raw SSID 与 active transport。
注入 health repository 时还会调用 `checkHealth()`；快照中的实现请求解析后的 `/readyz`。
health 成功后还有展示等待，真正导航前再次读取状态，并核对 generation 和目标网络。
阅读测试时先看注入：空 `healthRepository` 会跳过服务检查，不能拿这种配置解释所有生产调用。

失败情境一：Wi-Fi 条件成立，服务检查失败。最后正确点是平台链路；第一个失败点是服务检查。
此时能说“服务暂不可达”，不能据此断言密码错误，也不能擅自改成忽略 health 放行。
失败情境二：服务等待期间用户 Refresh 或切换网络。旧检查可能成功，但已经没有导航资格。
真实页面用 generation、当前目标和生命周期检查保护这条边界；模型只演示重新读目标网络。
`Future.timeout` 也不会自动取消底层工作，所以超时与底层已经退出要分别判断。

## 先预测，再展开答案

### 题 1：true、true、false

第一次目标网络检查成功，服务成功，第二次目标网络检查失败。模型返回什么？

<details>
<summary>展开答案与理由</summary>

返回“网络已经变化”。前两次成功是较早时刻的事实，第三次检查否定了继续依赖目标网络的前提。
如果少了这次检查，就可能凭已经过时的网络状态继续。

</details>

### 题 2：连上了，但服务失败

第一次检查返回 `true`，服务检查返回 `false`。模型会执行第二次网络检查吗？能报告绑定成功吗？

<details>
<summary>展开答案与理由</summary>

不会。它在“等待业务服务”处 `return`，本次函数就结束了。
也不能报告绑定成功；即使网络三关全过，绑定仍是本模型之外的业务事实。

</details>

### 题 3：Settings 里检查成功，就自动进入 Pairing 吗

同一 Wi-Fi 页面在设置中复用，readiness 通过能否推出一定导航到配对？

<details>
<summary>展开答案与理由</summary>

不能。快照中首次配网入口拥有 `onReady`，Settings Network 检查成功后仍留在 Network。
“检查条件成立”与“调用方授予什么导航动作”应分开阅读。

</details>

## 第一次读源码：最多两个文件，读到这里就停

1. 通过 [frame_wifi_design_page.dart](../../evidence/source-map.md#source-1605f96079) 定位源文件，搜索 `_handoffWhenReady`。
2. 只标出目标网络检查、`checkHealth`、最终状态回读与 `_isCurrentHandoff`，按发生顺序画四格。
3. 再打开 [frame_wifi_design_page_test.dart](../../evidence/source-map.md#source-085fdc4f7f)，搜索 `handoff rechecks WiFi after health before navigating`。
4. 先预测 health 成功后换网的导航次数，再读断言；本课不执行测试。

停止点：能说清“最后成功的是哪层，下一层失败是什么”，并找到最终导航前的核对位置，就关闭两个文件。
不用继续打开 `FrameWifiController.kt`；权限或系统连接实现留到另一次学习。

下一次回到 Wi-Fi 专题，只读 [五种事实](../../modules/wifi.md#1-先把五种事实分开)、[连接成功后的等待](../../modules/wifi.md#5-主动连接成功为什么还要等) 与 [入口导航权](../../modules/wifi.md#6-两个入口复用导航权必须分开)。
完成标志：面对“已连接却卡 Checking”，先提出服务检查和状态变化两个可查位置，而不是直接猜 Wi-Fi 密码错误。
