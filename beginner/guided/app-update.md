# App Update 导读：下载好了，为什么还要等用户确认

> 本导读沿用 2026-09-09 的 App Update 专题快照。当前源代码可能变化；这里不刷新源码行为或验证记录。
> 示例是原创教学小模型，不是项目实现；练习只需纸笔，未运行产品测试、安装或设备实验。

## 先准备，再只看下载与安装的交界

先修：[值与函数](../01-values-functions.md)、[类型](../04-types-nullability.md)、[Widget 与 State](../05-widget-state.md)、[异步 UI](../08-async-ui.md)、[源码阅读](../11-source-reading.md)。
读过 [过期结果](../09-stale-results.md) 与 [计时器与监听](../10-timers-listeners.md) 后，先保留一句话：页面状态改变，不代表外部工作已经结束。
开始前，能区分“一个状态值”和“改变状态的函数调用”；不熟就回到第 01、05 课。
本课只追 `readyToInstall` 与用户确认，不展开签名算法、Android 系统 OTA 或服务端回报协议。

生活里的场景：Frame 提示新版本，下载完后出现安装选项。你想稍后安装，先收起提示。
像快递已放进收件柜，领取仍是下一步动作；下载已完成也不能单独证明应用已经替换。
我们要分清三件事：文件准备好了、用户作出选择、系统安装有了结果。

## 用三张状态卡模拟界面

假定下载、文件校验和保存都已经由别处完成，才调用 `downloadedAndSaved()`。
模型里的确认函数只改变状态卡，不调用 Android、不安装文件；真实流程有更多中间阶段。

```dart
enum Phase { downloading, readyToInstall, waitingForInstaller }
Phase phase = Phase.downloading;
bool hasVerifiedFile = false;
bool promptVisible = true;
void downloadedAndSaved() {
  hasVerifiedFile = true;
  phase = Phase.readyToInstall;
}
void later() { promptVisible = false; }
void confirmInstall() {
  if (!hasVerifiedFile || phase != Phase.readyToInstall) return;
  phase = Phase.waitingForInstaller;
}
```

先按顺序在纸上调用 `downloadedAndSaved()`、`later()`；分别写出三个变量的最终值。

## 逐句读：收起提示为什么没有清空文件

1. `enum Phase` 声明只能从这些名字里选一个阶段；枚举值写成 `Phase.readyToInstall`。
2. `phase` 保存当前阶段；阶段名字让我们不用记 `1`、`2`、`3` 各代表什么。
3. `hasVerifiedFile` 表示模型是否已有校验好的文件，`promptVisible` 只表示提示是否显示。
4. `downloadedAndSaved()` 的名字约定了调用前提：不能把它当作执行真实下载和校验的代码。
5. 先记录有文件，再切到就绪卡，让“可确认安装”与已准备好的输入对应起来。
6. `later()` 只把显示标记改为 `false`，没有修改文件标记或阶段。
7. `!hasVerifiedFile` 表示文件条件不成立，`phase != ...` 表示阶段不允许。
8. `||` 表示其中任意一项成立就阻止继续；`return` 结束这次确认函数。
9. 最后一行只模拟进入等待；不能把一次 Dart 变量赋值当作系统接受了安装。

同一个页面上可以同时有“文件仍在”“阶段就绪”“提示收起”三个事实。
把它们揉成一个 `isOpen`，就很难解释关闭弹层之后该从哪里继续。

## 把状态卡放回更新控制器

专题记录：`_downloadUpdate` 得到已校验文件后，先保存 `downloadedApk`，再走回报与 `readyToInstall` 展示。
下载后的 Later on 保留 attempt 与已校验文件；Settings Firmware 复用同一个 `FrameAppUpdateController`。
用户确认后进入 `_submitDownloadedUpdate` 的安装准备链；真实 phase 还会经历 `preparing`。
该方法在平台调用前保存 `package_installer_commit_unconfirmed`，用来处理跨平台提交结果不确定的情况。
`readyToInstall`、`waitingForInstaller` 和最终安装成功因此是不同阶段。

失败情境：安装准备失败，用户看到 Retry，但原 APK 仍经过校验且被保留。
快照中的 `package_installer_prepare_failed` 允许明确 Retry 后重新读 Android 状态、核对资格再提交。
另一种情况是 `package_installer_commit_unconfirmed`：无法确定系统是否已接受提交，此时 Retry 应核对既有结果。
不能把所有 Retry 都理解成“再下载一次，再创建一次安装”；已发生的系统效果不会被新下载解释清楚。
本课只认识这条分界；具体失败恢复要回专题和真实分支继续读。

## 先预测，再展开答案

### 题 1：下载后选择 Later

模型依次执行 `downloadedAndSaved()`、`later()`。`phase`、`hasVerifiedFile`、`promptVisible` 各是什么？

<details>
<summary>展开答案与理由</summary>

依次是 `Phase.readyToInstall`、`true`、`false`。
Later 改变展示，下载事实仍在；重新打开入口应读取现存状态，而不是仅凭弹层关闭推断下载被取消。

</details>

### 题 2：还没下载就确认

模型处于初始状态时调用 `confirmInstall()`，会进入等待吗？

<details>
<summary>展开答案与理由</summary>

不会。此时没有已校验文件，阶段也不是就绪；条件成立，函数提前退出。
按钮动作不是输入已经合法的证明，执行入口仍需要检查自己的条件。

</details>

### 题 3：没有收到安装回调，就是没有安装过吗

如果真实流程跨平台提交期间进程消失，下次启动缺少成功回调，是否可以直接重新提交？

<details>
<summary>展开答案与理由</summary>

不能。没有收到结果，只能说明结果尚未被当前调用确认；Android 可能已经接受了提交。
专题中的提交待核对标记保留这个不确定性，恢复时先读取已有安装事实，避免制造重复会话。

</details>

## 第一次读源码：最多两个文件，读到这里就停

1. 通过 [frame_app_update_controller.dart](../../evidence/source-map.md#source-2dca7594fe) 定位源文件，先搜索 `FrameAppUpdatePhase` 与 `readyToInstall`。
2. 在 `_downloadUpdate` 找到 `downloadedApk` 的保存与就绪展示，再在 `_submitDownloadedUpdate` 找到平台调用前的持久化标记。
3. 再打开 [frame_app_update_controller_test.dart](../../evidence/source-map.md#source-3a278e482c)，搜索 `prepare failure retains the verified APK until explicit Retry`。
4. 先写出准备失败后文件、attempt、phase 应各保留什么，再用断言校对；本课不执行测试。

停止点：能指出“文件就绪”“用户确认”“等待系统结果”各在哪个阶段，知道关闭提示不会抹掉更新事实，就关闭两个文件。
此时不用继续打开 Kotlin、研究 signer 或实际点击设备上的安装按钮。

下一次回到 App Update 专题，只读 [状态与用户动作](../../modules/app-update.md#4-状态与用户动作)、[下载到安装的持久化顺序](../../modules/app-update.md#7-下载到安装之间的持久化顺序) 与 [Retry 的动作边界](../../modules/app-update.md#8-同样显示-retry允许的动作却不同)。
完成标志：面对“下载好了但还没更新”，能先核对用户确认与系统安装结果，而不是把下载进度当作安装成功。
