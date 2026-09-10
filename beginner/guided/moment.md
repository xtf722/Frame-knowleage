# Moment 导读：暂停一张照片，究竟停掉了什么

> 本导读沿用 2026-09-09 的 Moment 专题快照。当前源代码可能变化；这里不刷新源码行为或验证记录。
> 示例是原创教学小模型，不是项目实现；练习只需纸笔，未运行产品测试或设备实验。

## 先准备，再只看一张照片

先修：[回调](../02-callbacks.md)、[类型与空值](../04-types-nullability.md)、[生命周期](../06-lifecycle.md)、[计时器与监听](../10-timers-listeners.md)、[源码阅读](../11-source-reading.md)。
读过 [过期结果](../09-stale-results.md) 后，本课先记住“现在已经不需要的工作，不应继续推进页面”。
开始前，用自己的话解释 `Timer?`、`() { ... }` 和 `cancel()`；不熟就回到对应先修。
本课的任务不是学习全部 Gallery 或媒体缓存，而是区分“用户暂停”和“一次计时结束”。

生活里的场景：轮播到一张合照，你点一下，想多看一会儿。
三秒后你又点一下继续。下一张会立刻出现、等剩下的时间，还是重新等一整段？
先写下直觉，不急着猜项目答案。

## 用一个小计时器代替轮播页面

假定有足够多的照片，页面没有拖动，也不会退出；`index` 表示当前照片序号。
这里只演示第一次到期，省去循环回到第一张的逻辑；先调用 `schedule()` 开始等待。
`5` 秒是教学值，不是 Frame 的产品默认时长。

```dart
import 'dart:async';
Timer? nextPhoto;
bool paused = false;
int index = 0;
void schedule() {
  nextPhoto?.cancel();
  if (paused) return;
  nextPhoto = Timer(const Duration(seconds: 5), () { index++; });
}
void tap() {
  paused = !paused;
  schedule();
}
```

在纸上画时间线：0 秒开始，2 秒暂停，8 秒恢复。先预测 `index` 首次增加的时刻。

## 逐句读：暂停意图与计时工作是两件事

1. `import 'dart:async'` 引入 `Timer`；导入语句本身不会启动计时。
2. `Timer? nextPhoto` 可以暂时没有计时器；这个变量保存的是计时器引用，不是剩余秒数。
3. `bool paused = false` 保存用户意图，`int index = 0` 保存照片位置。
4. `void schedule()` 声明一个不返回结果的函数；被调用时才执行函数体。
5. `nextPhoto?.cancel()`：有旧计时器就取消，没有就跳过，防止两个计时同时等着推进。
6. `if (paused) return`：暂停时不建立下一只计时器，旧计时器已经在上一句取消。
7. `Duration(seconds: 5)` 描述时长；`Timer` 安排稍后执行回调，不会把页面同步卡住五秒。
8. `() { index++; }` 是到期回调，`index++` 到那时才把序号加一。
9. `tap` 中的 `!paused` 把暂停状态翻转，再调用 `schedule` 根据新状态重新安排工作。

模型里没有“剩余时间”这个变量。恢复时创建的 `Timer`，拿到的仍然是完整五秒。
这正是阅读时应该问的问题：代码保存了截止时间或剩余量吗，还是仅重新创建计时器？

## 把计时器放回 Moment

快照中的照片播放入口是 `FrameAlbumPlaybackPage`，源码目录名称使用 `frame_album`。
`_syncActivePlaybackPolicy` 根据当前媒体和状态决定自动前进策略；`_togglePlayback` 处理用户暂停意图。
图片至少有两项、未暂停、未拖动、间隔不为 `null` 时，才建立图片计时器。
恢复图片播放会重新建立间隔；它不是保存剩余秒数的倒计时。
但同一照片从网络升级为本地缓存时，已有展示截止时间会保留；不要把任何更新都当作用户恢复。

失败情境：用户已暂停，旧计时器仍把页面推进了。最后正确点是暂停意图已经改变。
下一步应查计时器是否取消，以及何处又建立了计时；不能仅凭“暂停图标显示了”认定已经暂停。
真实页面还处理拖动、队列变化和 `dispose`；模型省略它们，不能据此保证页面退出后的行为。
本课也不从照片计时推导后台音视频表现，视频结束事件属于另一个分支。

## 先预测，再展开答案

### 题 1：从 8 秒继续

0 秒开始计时，2 秒暂停，8 秒恢复。模型在哪个时刻第一次把 `index` 加一？

<details>
<summary>展开答案与理由</summary>

13 秒。2 秒时原计时被取消；8 秒时重新创建五秒计时器。
模型没有保存先前剩余的三秒，所以不是 11 秒；恢复动作也没有直接增加序号。

</details>

### 题 2：先 return，再 cancel

把 `if (paused) return` 移到 `nextPhoto?.cancel()` 前面，用户暂停后会发生什么？

<details>
<summary>展开答案与理由</summary>

函数因暂停直接退出，旧计时器没有取消；原回调仍可能按原计划执行。
用户意图已经是暂停，但安排过的工作仍在。两行顺序决定了暂停能否约束旧工作。

</details>

### 题 3：Never 就是用户暂停吗

项目里间隔为 `null`，和 `_isUserPaused` 为 `true`，是否可以合并为一种状态？

<details>
<summary>展开答案与理由</summary>

不能。快照中 Never 禁止自动换页，视频仍可正常播放；用户暂停是对当前播放的明确意图。
两个条件有时都会阻止照片计时，但它们对其他分支的意义不同。

</details>

## 第一次读源码：最多两个文件，读到这里就停

1. 通过 [frame_album_playback_page.dart](../../evidence/source-map.md#source-e11368de0f) 定位源文件，搜索 `_togglePlayback`、`_isUserPaused`、`_syncActivePlaybackPolicy`。
2. 只跟图片分支，分别指出“取消旧计时”和“建立新计时”在哪里；遇到视频配置先跳过。
3. 再打开 [frame_album_playback_page_test.dart](../../evidence/source-map.md#source-ab0b20ab1e)，搜索 `cache upgrade preserves photo deadline and uses next local file`。
4. 先预测只改缓存来源会不会重置当前图片时限，再读时间推进和断言；本课不执行测试。

停止点：能解释“用户恢复重新计时”和“同照片缓存升级保持时限”的差别，就关闭两个文件。
此时不用追 `TinyPlayer`、下载队列或 Gallery 隐藏照片。

下一次回到 Moment 专题，只读 [图片和视频的前进条件](../../modules/moment.md#图片和视频共用页面但前进条件不同) 与 [身份稳定和播放连续](../../modules/moment.md#身份稳定才可能保持播放连续)。
完成标志：能用一条时间线解释暂停前、暂停中、恢复后的计时器分别是否存在。
