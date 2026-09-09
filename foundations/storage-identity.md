# 存储与身份：文件还在，为什么不一定能播放

> 基础学习卡 · 2026-09-09。通用概念使用原创例子，项目映射依据当天工作区源码；本文不记录当前验证结果。带着具体问题回到 [Moment](../modules/moment.md) 或 [Portrait](../modules/portrait.md)。

## 一份缓存至少有四个问题

假设学习用相框保存过“宠物 A 的照片 X”。第二天相框改绑，照片字节仍在磁盘。文件存在只能回答“我还保存着什么”，不能回答“这次绑定能不能继续展示”。

| 问题 | 要检查的东西 | 不能替代它的证据 |
| --- | --- | --- |
| 现在允许谁看什么？ | 当前绑定、displayScope、候选集合及宠物归属 | 目录里恰好有文件 |
| 这是哪份内容？ | 业务媒体身份、内容版本与内容 identity | 两个 URL 的字符串相同 |
| 字节是否可用？ | 受管 entry、owner、文件存在、大小、必要的 hash/类型检查 | `File.exists()` 返回 true |
| 当前任务还能提交吗？ | generation/lease 与写入队列准入 | 请求开始时还是当前宠物 |

Frame 的 [First Sync](../evidence/source-map.md#source-886fe19d83) 先检查当前身份和候选引用，再调用缓存查找。`resolveCached` 获得本地来源，不能自行恢复历史绑定与选择；具体准入回查 [Data Transfer owner](../evidence/source-map.md#source-83200d27ef)。

## 五种“名字”各自标识什么

| 名称 | 通用理解 | 项目中怎样找 |
| --- | --- | --- |
| `petId` | 业务所有者是谁 | [FrameAlbumItem](../evidence/source-map.md#source-1df70f9b0b) 每条媒体的归属；Mixed 顶层空值不能抹掉逐项归属 |
| `id` / `mediaId` | 哪个候选项、哪个来源媒体 | 同文件中的 `FrameAlbumItem.id` 与 `FrameAlbumItemSource.mediaId`，不是任意可互换字段 |
| `revision` / cursor | 哪版集合、哪次同步位置 | [FrameFirstSyncPlaybackSession](../evidence/source-map.md#source-886fe19d83) 与 checkpoint；集合更新不等于每个媒体内容都变了 |
| `mediaCacheIdentity` / content hash | 缓存引用和字节内容的稳定识别依据 | `FrameAlbumItem.mediaCacheIdentity` 委托共享规则，由 cacheKey、contentHash、URL 等字段决定 |
| 临时 URL | 此时从哪里取得字节 | 签名续期可改变 URL，却不必改变业务媒体或播放状态；不能笼统断言任意 URL 变化都可忽略 |

原创例子：一张图搬到另一个领取地址，好比书换了快递单号；书的内容未必变。反过来，地址没变，里面的文件也可能已替换，所以还需要内容版本和校验。

物理去重与业务归属可以并存：宠物 A、B 可以引用同一文件，但两条播放快照仍分别拥有 `petId`。在 [pending worker](../evidence/source-map.md#source-6146168e7f) 中，恢复匹配使用 `(mediaCacheIdentity, petId)`，避免重试次数和授权集合串到另一只宠物。

## Cache hit 是一次校验结果，不是永久标签

在 [FrameAlbumMediaCachePreparer.resolveCached](../evidence/source-map.md#source-4c34a86877) 里，查到 index entry 后还要验证文件；耗时摘要计算结束后，重新读 entry 与文件 stat，核对 `_cacheFingerprint`，才发布命中。

这个顺序处理的是 **TOCTOU（检查时与使用时之间发生变化）**：检查文件有效后，另一个任务可能回收文件，或者用同 identity 提交新内容。先前检查成功，不意味着现在还在使用同一份字节。

阅读 cache hit 时按顺序问：

1. 候选媒体是否拥有合法归属与元数据？
2. entry 是否属于正确 owner，扩展名、长度等是否匹配？
3. 声明了 content hash 时，内容是否满足它？
4. 等待完成后，entry、文件状态与任务代际是否仍是刚刚检查的那份？

校验记录可以减少重复读取，但需要明确有效期与失效条件。它不能让旧 session 授权当前播放，也不能把未声明 hash 的路径表述成“所有文件都做了 SHA-256”。

## Range 续传：接上哪一段，必须说清楚

HTTP `Range` 请求某个表示的一部分；`If-Range` 让服务器在验证器匹配时处理范围，不匹配时忽略范围。客户端不能为 `If-Range` 使用弱 ETag。[RFC 9110 §14.2](https://www.rfc-editor.org/rfc/rfc9110.html#section-14.2)、[§13.1.5](https://www.rfc-editor.org/rfc/rfc9110.html#section-13.1.5)。

`206` 表示部分内容；`200` 可能是完整响应，不能直接拼到旧前缀后；`416` 表示范围被拒绝，不是“已下载完成”的证明。[RFC 9110 §15.3.7](https://www.rfc-editor.org/rfc/rfc9110.html#section-15.3.7)、[§15.5.17](https://www.rfc-editor.org/rfc/rfc9110.html#section-15.5.17)。

下面是项目实现观察，不是规范强制客户端采取的唯一策略。入口为 [FrameAlbumHttpMediaDownloader.download](../evidence/source-map.md#source-4c34a86877)。

| 本地已有部分字节，收到什么？ | 当前代码如何处理 | 需要防止的问题 |
| --- | --- | --- |
| `206` | `_requireMatchingContentRange` 核对起点，比较 metadata，核对本段及总长度 | 拼接错位、把两个版本拼成一份媒体 |
| `200` | 清空旧 partial 与内存前缀，使用本次完整响应 | 得到“旧前缀 + 完整文件”的损坏结果 |
| `416` 或其他未接受状态 | 此续传分支抛 `downloadHttpStatus`，没有把它直接视为成功 | 将不成立的范围当作下载完整 |

纸面练习：已有 4 字节 `ABCD`，服务器返回完整 6 字节 `UVWXYZ`。直接追加会得到 10 字节错误结果；从头接纳则为 6 字节。这个例子只解释拼接，不代表真实媒体格式。

## 临时文件、提交与 read model

通用设计可以分为：**收集/写临时数据 → 验证 → 提交可读索引 → 发布新的读取视图**。这里的 read model 指供界面读取的整理后状态，不要求项目采用特定架构框架。

失败时的重要问题是“哪一步已对其他读者可见”。临时文件存在不等于已提交；文件已改名也不等于索引写入成功；内存中的新对象不等于磁盘已保存。

Frame 的具体对应如下：

- [FrameAlbumMediaCachePreparer](../evidence/source-map.md#source-4c34a86877) 负责媒体元数据与字节验证，使用 Storage 的 staging/commit 能力；不能把所有验证都归到 `commitStaged`。
- [FrameStorageManager.stageBytes](../evidence/source-map.md#source-b64047ec71) 生成受管 staged file；`commitStaged` 再检查文件存在及长度，改名后写 index；index 失败时尝试回滚到 staging。
- [FrameFirstSyncSessionStore](../evidence/source-map.md#source-886fe19d83) 发布给路由消费的 session；它与下载 partial、受管索引、同步 checkpoint 属于不同状态，不应统称为一个“缓存”。
- [Gallery 的 `_saveLocalVisibility`](../evidence/source-map.md#source-320fb1f6cd) 先保存目录与 pending，再更新有效隐藏集与页面结果；写盘失败保留草稿和原播放事实。

不要把上述多个步骤概括成“跨文件数据库事务已经原子完成”。需要分别检查失败回滚、重启恢复与索引一致性；当前具体保证以各 owner 和源码为准。

## generation/lease：结果正确，还得允许现在提交

原创时序：任务 A 开始下载 → 用户切宠 → 任务 B 成为当前任务 → A 下载成功。A 的字节可能正确，但 A 已不能覆盖 B 的当前 session。

[FrameFirstSyncRunCoordinator](../evidence/source-map.md#source-886fe19d83) 使用 generation/lease 识别当前运行；`commitForGeneration` 串行 checkpoint，并在队首再次检查代际。[FrameStorageManager.runGuardedCacheTransaction](../evidence/source-map.md#source-b64047ec71) 对缓存 index 的读改写也在 FIFO 队首检查 `canCommit`。

“排队前允许”不等于“轮到时允许”。另外，已经进入底层的写入未必能取消，所以需要排空、提交顺序和新旧结果隔离，不能把 `Future` 丢掉就称为取消完成。

如果这段难理解，回到 [异步与生命周期](async-lifecycle.md) 的旧结果处理，再用 [Moment](../modules/moment.md) 的 pending 与 Gallery 案例串起来。

## 自测与一次纸面实验

1. 旧缓存有文件、hash 也正确，但 Frame 改绑了。还缺哪一种事实？
2. 同一媒体只换签名 URL，哪些身份可能不变？为什么不能用任意 URL 字符串变化直接重建视频？
3. 续传收到 `200` 或 `416`，分别为什么不能“无条件追加”和“直接标完成”？
4. 为什么 generation 要在 FIFO 队首检查，而不是只有发起请求时检查？

实验（本轮未执行）：画四列 `临时文件 / index / session / Gallery pending`，在每一次 await 后假设断电或切宠。逐列填“最后确认的值、未完成的值、恢复后依据”，再回源码找对应守卫。不要在真实缓存目录注入破坏。

<details>
<summary>参考答案</summary>

1. 缺当前绑定与播放授权集合；字节完整性不能证明业务授权。
2. `petId`、业务媒体 id、稳定 cache/content identity 可能不变；读取地址与媒体身份解决不同问题，具体同一性必须按项目规则判断。
3. `200` 可能给出完整新内容，追加会多出旧前缀；`416` 只说明范围遭拒绝，不能证明本地内容完整且属于当前版本。
4. 任务可能在等待队列期间失效；队首检查保证尚未开始的旧副作用不能越过新代际，已开始的底层写入还需顺序与排空管理。

</details>

学会本卡后，应能对“缓存命中了”“下载好了”“已经保存了”追加一个具体问题：**哪个 owner、哪份内容、哪层状态、哪个提交时刻？**
