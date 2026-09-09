# 基础卡：网络事实、Android 能力与平台通道

> 学习整理日期：2026-09-09。平台规则按 Android 版本、target SDK 与设备能力回查官方文档；Frame 当前实现以模块 owner 为准。下文例子均为教学假设。

用于补课：[Wi-Fi 专题](../modules/wifi.md)｜[更新专题](../modules/app-update.md)。
读完后的目标：能说清“网络到了哪一步”和“哪个身份获准执行哪种操作”，不再只问“有没有网”。

## 1. MethodChannel 传递消息，不替业务完成事务

Flutter 通过异步消息调用平台方法，原生侧返回结果；标准 codec 编解码布尔、数字、字符串、列表和 Map 等值。[Flutter 平台通道](https://docs.flutter.dev/platform-integration/platform-channels)

教学推论：传输机制只解决“怎么交流”，不会自动替你定义成功时刻、撤销操作或失败回滚。
例如 Flutter 发送 `connect`，原生保存配置并启动连接，消息返回与 Wi-Fi 最终就绪是两个时刻。
若 Flutter 页面随后销毁，已经开始的系统操作不会因为页面不存在就自然恢复原状。

| 要自己设计的问题 | 可以问自己的具体问题 |
| --- | --- |
| 完成语义 | success 表示“请求已接受”，还是“目标网络已回读确认”？ |
| 部分完成 | 保存配置成功、连接失败时，留下了什么？ |
| 重复回包 | receiver 和 timeout 都到达，谁能完成 Result？ |
| 迟到结果 | 老请求完成时，新请求是否已经取得所有权？ |
| 数据契约 | DTO 里的缺失、false、unknown 是否被错误合并？ |

Frame 的学习入口是 `FrameWifiOneShotCompletion`、`FrameWifiOperationSlot` 和 `_readyGeneration`。
它们分别回答“一次结果”“谁拥有资源”“谁还有发布权”，详见 [Wi-Fi 生命周期](../modules/wifi.md)。

## 2. 将“有网”拆成一组可验证的问题

Android 的 `NET_CAPABILITY_INTERNET` 表示网络配置可用于互联网；`NET_CAPABILITY_VALIDATED` 表示系统探测时确认了公网访问。能力随时可能变化；验证通过也不能保证任意服务必达。[Android 网络状态](https://developer.android.com/develop/connectivity/network-ops/reading-network-state)

| 事实层 | 教学问题 | 可能的反例 |
| --- | --- | --- |
| SSID / security | 连的是哪个候选或保存配置？ | 同名但安全类型不同 |
| transport | 当前相关网络是否使用 Wi-Fi？ | 接入路由器但外网断开 |
| `INTERNET` capability | 此网络是否配置了互联网能力？ | 酒店网络仍需网页认证 |
| `VALIDATED` capability | 系统探测时能否访问公网？ | 某个业务域名被单独拦截 |
| 业务 health | 本服务的健康请求是否成功？ | 健康接口可用但用户授权失败 |
| 业务操作 | 此次查询、下载或写入是否完成？ | 下载中断或写入回执丢失 |

这里的 `NET_CAPABILITY_INTERNET` 是网络 capability，不是 Manifest 中同名含义相近的联网 permission。
这张表是分析维度，不是要求每个产品逐层打探测请求，也不是 Android 保证的一条严格事件顺序。
Frame 图标表达本机链路；更新控制器的 `setNetworkReady` 是请求准入门槛。具体健康、身份与安装结果继续由各自流程判断。

练习：假设路由器仍开机，但业务服务器停机。预期可以“Wi-Fi connected + 业务请求失败”；这不矛盾。
反过来，“health 成功”也不能证明大文件下载始终成功，下载期间还有新的时间与状态变化。

## 3. Android 10 扫描为什么牵涉定位权限

对 Android 10 且 target SDK ≥29 的普通路径，`startScan` 需要 `ACCESS_FINE_LOCATION`、`CHANGE_WIFI_STATE` 与开启的 Location service；读取结果需要前者、`ACCESS_WIFI_STATE` 与 Location service。扫描可能限流，结果也可能来自上一轮。[Wi-Fi 扫描要求](https://developer.android.com/develop/connectivity/wifi/wifi-scan)

不要把“我只想扫 Wi-Fi”推导为“不需要定位相关能力”；API 的授权边界由平台定义。
排查时把四个问题写开：设备 Android 版本、App target SDK、权限是否获授、相关系统服务是否开启。
高级宿主的豁免另按精确 API 和能力事实核实，不能用一个 privileged 标签跳过全部检查。

教学例子：Refresh 后仍看到旧热点，至少有三种解释：新扫描未结束、新扫描失败但保留旧结果、候选确实没变化。
因此 `fresh` 与错误 code 值得保留；“列表非空”本身无法区分这三种情况。
Frame 对应 `FrameWifiScanSnapshot`、permission gate 和 `FrameWifiCapabilityProfile`，见 [Wi-Fi 专题](../modules/wifi.md)。

## 4. Device Owner、平台签名、ROOT 各回答不同问题

| 概念 | 它描述什么 | 不应自动推出 |
| --- | --- | --- |
| Device Owner | DPC 对 fully managed device 的管理角色 | App 已使用平台证书签名 |
| platform signing | App 证书与平台包签名相同或兼容 | App 已获得 Device Owner 角色或 ROOT |
| ROOT | Linux 层的超级用户权限概念 | 所有 Android API、SELinux 约束都消失 |

Device Owner 的角色范围见 [Android 设备管理](https://developer.android.com/work/dpc/device-management)；平台签名定义见 [AOSP signature permission](https://source.android.com/docs/core/permissions/signature-permission-allowlist)。
Android 的 SELinux 强制访问控制也约束具有 root 权限的进程，见 [AOSP 安全特性](https://source.android.com/docs/security/features)。
这里只引用概念定义；新版本的 signature allowlist 规则不能直接倒套到 Android 10。

教学例子：一个应用可能拥有设备管理角色，同时作为普通数据分区应用运行；描述签名、安装位置和角色时要分别给事实。
在 Frame 中，先读 `deviceOwnerManagedAvailable`、`fullPrivilegedProfileAvailable`、`scanPermissionBypassAvailable` 各自含义，再判断操作能力。
这些名词的价值是帮助定位权限边界，不是让 UI 拼出一种“权限越大越好”的运行模式。

## 5. 监听、轮询和时效

Android 的 default-network callback 与其他 network callback 观察范围不同；网络刚出现时应等待 capability 回调，避免立即同步读取产生竞态。不再使用时需注销 callback。[Android 网络事件](https://developer.android.com/develop/connectivity/network-ops/reading-network-state)

从工程上继续问：这条消息描述谁、什么时候采样、现在是否仍然有效？
callback 是事件通知，polling 是间隔取样；两者都需要处理生命周期结束和旧结果迟到。
Frame 的 App observer 采取单个 pending read、读取期限与 generation；具体时间参数归 [Wi-Fi 专题](../modules/wifi.md)。
更新模块收到网络恢复后，还要按自己的调度、身份和服务端间隔决定是否请求，见 [更新专题](../modules/app-update.md)。

学习实验（未执行）：画时间轴“读状态 A → 页面暂停 → 恢复并开启新 generation → A 返回”。
先写出若直接接收 A 会出现什么错误，再说明它为什么仍可能是一个成功完成的底层 Future。

## 6. 三道自测

1. MethodChannel 返回 success 后页面销毁，能否认定原生操作已经自动回滚？
2. 同时有 Wi-Fi transport 和 `VALIDATED`，为何更新请求仍可能失败？
3. App 是 Device Owner，扫描失败时能否立即排除权限与 Location service？

<details>
<summary>展开答案</summary>

1. 不能。消息成功、业务完成和回滚是不同契约；先查原生操作的结果语义与清理路径。
2. 系统探测不代表特定服务或特定请求永远成功，还可能有服务、身份、下载和时序失败。
3. 不能。管理角色、扫描权限与系统服务是不同事实，要按平台版本、API 与明确能力检查。

</details>

复习动作：回到 [Wi-Fi](../modules/wifi.md)，用这六层事实标注一次 `_handoffWhenReady`；再到 [更新](../modules/app-update.md)，找到网络门槛之后仍会失败的两个阶段。
