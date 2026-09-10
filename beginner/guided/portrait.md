# Portrait 导读：第二次选择，怎样让第一次等待失效

> 本导读沿用 2026-09-09 的 Portrait 专题快照。当前源代码可能变化；这里不刷新源码行为或验证记录。
> 示例是原创教学小模型，不是项目实现；练习只需纸笔，未运行产品测试或设备实验。

## 先准备，再只看一个动作

先修：[Future 与 await](../03-future-await.md)、[Widget 与 State](../05-widget-state.md)、[过期结果](../09-stale-results.md)、[源码阅读](../11-source-reading.md)。
如果分不清“回调不再有效”和“资源已经释放”，先回看 [计时器与监听](../10-timers-listeners.md) 的清理部分。
合上先修后，先说出：`await` 等待期间页面仍可能接收用户的新动作。
这句话说不清，就先停在第 03 课；现在不需要读播放器、Android 或缓存实现。

生活里的场景：你正在看宠物 A，点了 B，等了一会儿又改选 A。
B 的封面这时才准备好。屏幕应听最后一次选择，还是听最后一个回包？
本课只追踪“B 的旧结果还有没有资格接管”，不展开整套 Portrait 状态机。

## 先把封面变成一张写着名字的纸

下面的 `poster` 只会给出一个代表封面的字符串，不读取真实图片。
假定页面一直存在、所有 Future 都成功；每次选择都调用一次 `choose`。
`visible` 代表当前展示对象，`generation` 代表最新选择的轮次。

```dart
int generation = 0;
String visible = 'A';
Future<void> choose(String target, Future<String> poster) async {
  final myTurn = ++generation;
  final decoded = await poster;
  if (myTurn != generation) return;
  visible = target;
  print('$visible：$decoded');
}
```

先遮住下一节，在纸上写下：点 B 时 `myTurn` 是几？再点 A 后，B 的 `myTurn` 会跟着变吗？

## 逐句读：哪一个值属于哪一次选择

1. `int generation = 0`：建立共享计数器，之后每一次调用都能看到它的新值。
2. `String visible = 'A'`：开始时 A 可见；发出新请求本身还没有改这行状态。
3. `Future<void>`：函数会异步结束，但不返回供调用方使用的结果值；它仍会修改 `visible`。
4. `String target` 是本次目标；`Future<String> poster` 是本次正在等待的封面结果。
5. `++generation` 先加一，再把新值交给 `myTurn`。`final` 让这个局部记录之后不被重新赋值。
6. `await poster` 暂停本次函数的后半段。新的 `choose` 可以在这段等待期间开始。
7. `myTurn != generation` 问的是“我还是最新一次吗”；`return` 在这里结束旧调用。
8. `visible = target` 才是真正提交展示状态；这行放在资格检查后面。
9. `print` 用字符串插值显示被接受的目标和结果，方便纸面预测输出。

`myTurn` 像你手里的取餐号，`generation` 像柜台当前受理的号码。
柜台号码变了，不会涂改你手里的纸；比较两个号码，才能知道旧单是否还有效。

## 把这张纸放回 Portrait

专题记录：目标封面准备期间，旧 Host 可以继续运动；准备结果接管前还要核对当前目标。
对应阅读点是 `didUpdateWidget`、`_resolveTargetPoster`、`_commitPreparedSession` 和 `_posterGeneration`。
不要把模型中的每次 `choose` 与真实方法逐行配对；真实代码还区分 transition 身份、封面资源和可见身份。
本课只借模型理解“等待完成之后，为什么还要检查一次”。

真实失败情境不只有“回包慢”：B 封面也可能失败，页面也可能已经离开。
快照中，封面失败仍允许已确认的 B session 启动，并用此前可用封面保护加载过程。
所以失败不等于直接把屏幕清空；模型没有实现这条恢复路径。
页面已经销毁时还要检查生命周期；页面没销毁、目标换了时还要检查请求身份。
只写 `mounted`，回答不了“页面仍在，但现在选的已经不是 B”。

## 先预测，再展开答案

### 题 1：B 慢，A 快

从初始 A 开始，依次调用选择 B、选择 A；A 的 Future 先结束，B 后结束。最后 `visible` 是谁？

<details>
<summary>展开答案与理由</summary>

是 A。B 记住 `myTurn = 1`，A 记住 `myTurn = 2`；共享 `generation` 最后是 2。
A 可以提交，B 回来时在比较处退出。决定权来自选择次序，不来自完成次序。

</details>

### 题 2：把比较删掉

保持同样的完成顺序，只删掉 `if` 那一行。错误最早发生在哪一行？

<details>
<summary>展开答案与理由</summary>

B 在 `visible = target` 把 A 覆盖时，错误第一次成为展示状态。
B 的 Future 完成不是错误；允许已经过期的 B 写入当前状态才是错误。

</details>

### 题 3：旧结果退出，图片就自动释放了吗

真实图片回调已经交给你一个资源 handle；发现请求过期后直接 `return`，是否足够？

<details>
<summary>展开答案与理由</summary>

不够。拒绝提交和释放已取得资源是两件事。
专题记录的图片监听路径会释放收到的 `ImageInfo` handle；不要从模型的普通字符串推导图片自动清理。

</details>

## 第一次读源码：最多两个文件，读到这里就停

1. 通过 [frame_portrait_stage_page.dart](../../evidence/source-map.md#source-c969a6cf62) 定位源文件，只搜索 `_posterGeneration`、`_resolveTargetPoster`、`_commitPreparedSession`。
2. 纸上画三格：“新目标到来”“封面等待”“结果提交”，在对应格里抄下一个相关条件的名字。
3. 再打开 [frame_portrait_stage_page_test.dart](../../evidence/source-map.md#source-2aa098367c)，搜索 `returning to the active companion cancels a pending poster switch`。
4. 先遮住断言预测 B 晚到的结果，再用断言校对；本课不要求执行这个测试。

停止点：能指出旧请求在哪个检查失去提交资格，并解释旧画面为什么可以暂时保留，就关闭两个文件。
此时不用继续跟进 `PortraitPlayerLiveHost`、原生首帧或下载器。

下一次回到 Portrait 专题，只读 [难点二：等待新内容接管](../../modules/portrait.md#难点二保持旧画面等待新内容有条件接管) 与 [难点三：保护本次请求](../../modules/portrait.md#难点三过期判断要保护本次请求不只保护页面)。
完成标志不是背出 generation 名字，而是能自己画出 A → B → A 的三次时刻，并圈出“允许写入”的那一步。
