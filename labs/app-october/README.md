# 十月进阶课程的离线实验

[课程入口](../../besideyou-app/README.md) · [程序](reliability_lab.dart) · [本次复核](../../evidence/app-october-validation.md)

这个完整 Dart 程序把四类问题缩成可控制顺序的实验。它只使用 Dart 标准库，不安装依赖、不连接后端、不调用 Flutter 插件，也不操作设备。使用支持 Dart 3 的现有 SDK，从知识库根目录运行：

```sh
dart labs/app-october/reliability_lab.dart
```

正常完成应输出 19 条 `PASS` 和 `Completed: 19 behavior checks`，退出码为 0。程序使用会抛错的检查，不依赖 `assert` 是否启用。

| 对应课程 | 输入 | 观察点 | 应保留的结果 |
| --- | --- | --- | --- |
| [10 异步资格](../../besideyou-app/10-async-identity-and-cache.md) | 用 Completer 控制新旧成功、失败和会话替换 | value、error、loading | 旧结果失去提交资格，确认写入不倒退 |
| [09 时间](../../besideyou-app/09-time-and-capabilities.md) | 将整数假时钟推进到截止时刻前后 | deadlines 的原值 | 首次截止不顺延，到期不重启 |
| [11 持久恢复](../../besideyou-app/11-durable-ad-recovery.md) | 模拟服务端已执行但响应丢失，再重建 Client | effects 与原 key | 同键恢复只有一次效果 |
| [13 媒体所有权](../../besideyou-app/13-scene-audio.md) | A、B 取得占用，A 重复释放，B 最后释放 | blocksBackground | A 无法解除 B 的占用 |

## 主动破坏一次保护

```sh
dart labs/app-october/reliability_lab.dart --broken-fence
dart labs/app-october/reliability_lab.dart --broken-key
```

这两次**应当失败并返回 1**。第一项禁用异步提交资格，旧成功覆盖新结果；第二项故意在恢复时换 key，模拟服务端执行第二笔。它们证明实验对目标错误敏感，不是产品测试或性能基准。

## 自己修改的练习

先预测，再修改：把旧失败改成在新请求未完成前返回；在换回账号 A 后再启动新读取；让两个 owner 交错释放；把时间输入改成恰好截止前一秒。每次只改变一个事件，并说明最终字段为何如此。

实验没有模拟实际磁盘、原子替换、跨进程锁、服务端权限、SDK 凭证、原生展示、真实声音、图片解码或 UI。`FakeJournal` 只是共享内存，重建 Client 不等于杀掉操作系统进程。实际项目的持久化失败和回执协议仍要回到 owner 与对应测试核验。
