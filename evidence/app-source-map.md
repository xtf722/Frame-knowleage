# BesideYou App 源码检索索引

[App 学习入口](../besideyou-app/README.md) · [提交范围](app-contributions.md) · [来源清单](app-sources.json) · [复核记录](app-validation.md)

采集日期：2026-09-21。这里是学习快照的来源导航；当前产品要求回到对应源项目的最近 owner。路径以 `apps/besideyou-flutter/` 为根，`../../packages/` 指同一工作区的共享包。公共知识库不携带项目源码。

本次去重记录 59 个源码、owner 或测试文件的 SHA-256。App HEAD 为 `78a0855fdb44a066ee836bbf3f9cf1e20621e17f`；workspace HEAD 为 `f21b1bb0ecb3bc44ed672781c1657ddcdb28cf90`。两者工作区均非完全干净，HEAD 不能独自替代逐文件内容指纹。

表中行号是该符号在本次文件中的首次文本匹配，可能是调用、导入或声明；用于快速定位，不冒充方法定义行。代码变化后先搜索符号并复核内容，再更新快照。完整符号列表和首次匹配行在 JSON 清单中。

## 最少阅读路径

| 想追的动作 | 先打开 | 接下来 | 到这里可以先停 |
| --- | --- | --- | --- |
| JSON 变成启动目标 | `app_bootstrap_repository.dart` | session fence、startup mapper/resolver | exact-pet 上下文交给 Home |
| Home 显示准备胶囊 | `home_root_page.dart` | prewarmer、preparing UI、tab shell | 状态移除或 Retry |
| Portrait 换背景和播放依赖 | `pet_space_interactive_view.dart` | runtime adapter、portrait stage | active/candidate 同批交付 |
| 长按后记住已学会 | `pet_space_portrait_guide_controller.dart` | guide 资源选择、progress、Host 观察 | 原账号保存与当前 attachment 反馈 |
| Mock 是否影响真实入口 | `main.local.dart` | `main.dart`、fixture backend | 依赖选择和 update gate 分流 |

下列测试均作为源码阅读材料；本轮没有执行产品测试。图表与教学片段由作者基于源码推导，不是保存的运行日志。

<a id="app-basics"></a>
## 基础、启动与接口

| 相对源码文件 | 建议搜索的符号（首次匹配行） |
| --- | --- |
| `lib/main.dart` | `runBesideYouMainEntry` L454；`loadBesideYouMainApp` L534 |
| `lib/app/di/README.md` | `目录职责` L3；`边界规则` L12 |
| `lib/app/api/README.md` | `DTO JSON Serialization Contract` L82；`Repository Usage` L112 |
| `lib/app/api/app_api_gateway.dart` | `AppApiGateway` L47；`getJson` L102；`requestJson` L110 |
| `lib/app/api/app_api_json_reader.dart` | `AppApiJsonReader` L5；`intField` L63 |
| `lib/app/bootstrap/README.md` | `边界规则` L22；`AppBootstrapRepository` L10 |
| `lib/app/bootstrap/app_bootstrap_repository.dart` | `GatewayAppBootstrapRepository` L21；`fetchBootstrap` L14；`AppBootstrapSnapshot` L14 |
| `lib/app/auth/README.md` | `目录职责` L3；`Session boundary` L22 |
| `lib/app/session/README.md` | `目录职责` L3 |
| `lib/app/session/app_account_session_lifecycle.dart` | `AppAccountSessionStamp` L6；`AppAccountSessionLifecycle` L116；`isCurrent` L146 |
| `lib/app/session/account_session_fenced_app_bootstrap_repository.dart` | `AccountSessionFencedAppBootstrapRepository` L4；`_throwIfSuperseded` L18 |
| `lib/app/route/app_startup_flow_location_mapper.dart` | `AppStartupFlowLocationMapper` L6；`locationForBootstrap` L25 |
| `lib/app/route/app_route_redirect_resolver.dart` | `_startupLocationForBootstrap` L202；`skipPetSpaceFallbackRevalidation` L158；`revalidateAuthoritatively` L442 |
| `lib/app/route/session-and-startup-contract.html` | `bootstrap-startup-flow` L366；`portrait-entry-matrix` L135；`homePetSelection` L193 |
| `pubspec.yaml` | `environment:` L13；`sdk: ^3.12.0` L14 |

<a id="app-home"></a>
## Home 队列、预热与升级返回

| 相对源码文件 | 建议搜索的符号（首次匹配行） |
| --- | --- |
| `SPEC.md` | `Product Direction` L6；`Compatibility` L31 |
| `lib/app/pages/home/README.md` | `Portrait 本机加载提示与 Basic 入口` L105；`Pet Space 选择与交互边界` L231 |
| `lib/app/pages/home/home_root_page.dart` | `HomeRootPage` L61；`_usesBasicPortraitUpgrade` L200；`_openBasicPortraitPlans` L220；`_schedulePriorityPetSpacePrewarm` L380；`_prewarmPriorityPetSpace` L825 |
| `lib/app/pages/home/home_tab_shell.dart` | `HomeTabShell` L19；`_syncPreparationOrder` L202；`_preparations` L212；`_dismissPortraitList` L222；`_openPortraitList` L250 |
| `lib/app/pages/home/home_portrait_preparing.dart` | `HomePortraitPreparation` L11；`HomePortraitPreparingPill` L36；`HomePortraitPreparationList` L271；`_PreparingPillState` L53；`_syncMotion` L77 |
| `lib/app/pages/home/home_page.dart` | `HomePage` L18；`_HomeBasicPortraitAction` L689；`basicPortraitUpgrade` L139 |
| `lib/app/pets/README.md` | `UserPetCenterLoadController` L11；`UserPetCenterRepository` L10 |
| `lib/app/pets/user_pet_center_load_controller.dart` | `UserPetCenterLoadController` L26；`ensureLoaded` L83；`refresh` L103；`revalidate` L121；`_load` L100 |
| `lib/app/pets/user_pet_center_repository.dart` | `GatewayUserPetCenterRepository` L27；`fetchQueue` L19；`UserPetCenterQueueResult` L19 |
| `lib/app/space/README.html` | `prewarm-scheduler` L64；`controller-state-model` L163；`manifest-media` L336 |
| `lib/app/space/pet_space_priority_prewarmer.dart` | `PetSpacePriorityPrewarmer` L10；`PetSpacePrewarmStatus` L11；`DefaultPetSpacePriorityPrewarmer` L93；`_publishStatus` L140；`prewarm` L6 |
| `lib/app/space/pet_space_prewarm_scheduler.dart` | `PetSpacePrewarmPriority` L9；`DefaultPetSpacePrewarmScheduler` L79；`schedule` L37；`_promote` L51；`_discard` L52 |
| `lib/app/space/pet_space_runtime_asset_preloader.dart` | `PetSpaceRuntimeAssetPreloadProgress` L54；`fraction` L149；`_currentAssetFraction` L154 |
| `lib/app/route/README.html` | `portrait-entry-matrix` L64 |
| `lib/app/route/session-and-startup-contract.html` | `bootstrap-startup-flow` L366；`portrait-entry-matrix` L135；`homePetSelection` L193 |
| `lib/app/route/home_route_adapter.dart` | `buildHomeRoute` L52；`onViewPlans` L159；`onPetSpaceSelected` L223 |
| `test/app/pages/home/home_portrait_preparing_test.dart` | `one stable capsule opens all pets, updates and closes when empty` L251；`unknown progress keeps loading text without a guessed percent` L44 |
| `test/app/pages/home/home_root_page_test.dart` | `verified purchase and Home return concurrent refresh` L66 |
| `test/app/route/home_basic_upgrade_return_test.dart` | `Basic paw upgrades through formal routes and refreshes Home` L15 |
| `test/app/space/pet_space_priority_prewarmer_test.dart` | `local progress survives server ready and finishes only after media commit` L15；`failed local preparation stays retryable and reset fences late completion` L83 |

<a id="app-portrait"></a>
## Portrait 舞台与 runtime

| 相对源码文件 | 建议搜索的符号（首次匹配行） |
| --- | --- |
| `lib/app/pages/pet_space/README.html` | `当前职责` L41；`主链路` L42；`portrait-access-matrix` L151；`portrait-stage` L315；`portrait-touch-guide` L323 |
| `lib/app/pages/pet_space/pet_space_interactive_view.dart` | `PetSpaceInteractiveView` L33；`_buildRuntimeDependencies` L135；`_PresentedPortrait` L114；`_portraitPointerBinding` L151；`_onGuideProgressChanged` L132 |
| `lib/app/pages/pet_space/pet_space_portrait_stage.dart` | `PetSpacePortraitMetrics` L10；`petSpacePortraitRect` L30；`PetSpacePortraitBackdrop` L68；`_PortraitBackdropImage` L100 |
| `lib/app/space/pet_space_runtime_adapter.dart` | `PetSpaceRuntimeAdapter` L13；`buildDependencies` L38；`PetSpaceRuntimeReady` L17；`PetSpaceRuntimeUnsupported` L31；`refreshMedia` L18 |
| `lib/app/space/README.html` | `prewarm-scheduler` L64；`controller-state-model` L163；`manifest-media` L336 |
| `lib/portrait_player/README.md` | `当前 contract` L32；`测试映射` L105 |
| `../../packages/besideyou_client_core/lib/src/portrait_player/README.md` | `只读交互与播放观测` L42；`Interaction/runtime contract` L50；`展示与解码` L79；`Mutable caller media mappings` L91 |
| `../../packages/besideyou_client_core/lib/src/portrait_player/presentation/portrait_player_live_host.dart` | `PortraitPlayerInteractionStatus` L55；`resolveLiveHostPointerDownTarget` L394；`pointerDownBindingOverride` L404；`PortraitPlayerLiveHost` L638；`onAcceptedPointerDown` L651 |
| `test/app/pages/pet_space/pet_space_portrait_stage_cases.dart` | `_portraitStageTests` L3；`candidate keeps the active poster and backdrop paired` L68；`dragging out and cancelling releases the owner for a new touch` L147 |
| `test/app/pages/pet_space/pet_space_portrait_backdrop_cases.dart` | `_portraitBackdropTests` L3；`missing or broken background stays non-blocking` L49；`a previous pet image completing late cannot replace the new background` L76 |

<a id="app-guide"></a>
## 触摸教学与账号完成记录

| 相对源码文件 | 建议搜索的符号（首次匹配行） |
| --- | --- |
| `lib/app/pages/pet_space/README.html` | `当前职责` L41；`主链路` L42；`portrait-access-matrix` L151；`portrait-stage` L315；`portrait-touch-guide` L323 |
| `lib/app/pages/pet_space/pet_space_interactive_view.dart` | `PetSpaceInteractiveView` L33；`_buildRuntimeDependencies` L135；`_PresentedPortrait` L114；`_portraitPointerBinding` L151；`_onGuideProgressChanged` L132 |
| `lib/portrait_player/README.md` | `当前 contract` L32；`测试映射` L105 |
| `lib/app/pages/pet_space/pet_space_portrait_guide.dart` | `portraitGuideSniffCandidateId` L10；`portraitGuideSniffBinding` L11；`portraitGuideMiddlePoint` L17；`PetSpacePortraitGuide` L106；`_syncMotion` L151 |
| `lib/app/pages/pet_space/pet_space_portrait_guide_controller.dart` | `PortraitGuidePhase` L7；`PetSpacePortraitGuideController` L10；`attach` L19；`observe` L86；`interrupt` L33 |
| `lib/app/pages/pet_space/pet_space_portrait_guide_progress.dart` | `PetSpacePortraitGuideProgress` L5；`forAccount` L10；`completedKey` L22；`load` L28；`_read` L46 |
| `../../packages/besideyou_client_core/lib/src/portrait_player/README.md` | `只读交互与播放观测` L42；`Interaction/runtime contract` L50；`展示与解码` L79；`Mutable caller media mappings` L91 |
| `../../packages/besideyou_client_core/lib/src/portrait_player/presentation/portrait_player_live_host.dart` | `PortraitPlayerInteractionStatus` L55；`resolveLiveHostPointerDownTarget` L394；`pointerDownBindingOverride` L404；`PortraitPlayerLiveHost` L638；`onAcceptedPointerDown` L651 |
| `../../packages/besideyou_client_core/lib/src/portrait_player/presentation/live_segment_driver.dart` | `RandomPortraitTouchVariantResolver` L40；`PortraitPlayerSegmentActivity` L68；`onCurrentPlaybackChanged` L390 |
| `test/app/pages/pet_space/pet_space_portrait_guide_test.dart` | `counts from actual matching Hold playback, then completes once` L140；`Great waits for persistence; completion is not undone by release` L195；`completed guide settles when` L221；`new middle press during release can qualify only on its own Hold` L350 |
| `test/app/pages/pet_space/pet_space_portrait_guide_progress_test.dart` | `late uncompleted read cannot undo completion` L25；`failed save keeps session completion and retries on next entry` L50；`B completion is shared within B but never inherited by C` L68；`late B read and save only change B after C becomes active` L106；`anonymous entry never reads or writes a shared completion` L126 |
| `test/app/pages/pet_space/pet_space_portrait_guide_cases.dart` | `auth-only switch rebinds the default account progress` L4；`B and C keep separate teaching across pets and late reads` L57 |

<a id="app-debug"></a>
## 本地 Mock 与真实入口

| 相对源码文件 | 建议搜索的符号（首次匹配行） |
| --- | --- |
| `LOCAL.md` | `Local Entry Points` L9；`Runtime Env Selection` L19 |
| `lib/env/README.md` | `BESIDEYOU_MOCK_MODE` L116；`BESIDEYOU_INCLUDE_DEBUG_ROUTES` L120 |
| `lib/main.dart` | `runBesideYouMainEntry` L454；`loadBesideYouMainApp` L534 |
| `lib/main.local.dart` | `_mockModeEnabled` L39；`_mockForceUpdate` L40；`_loadLocalApp` L119；`_loadLocalMockApp` L119 |
| `lib/app/debug/README.html` | `BESIDEYOU_MOCK_MODE` L17；`DebugAppMockComposition` L54 |
| `lib/app/debug/debug_app_mock_composition.dart` | `DebugAppMockComposition` L34；`appApiGatewayOverride` L49 |
| `lib/app/debug/debug_app_api_fixture_backend.dart` | `DebugAppApiFixtureBackend` L50；`_DebugAppApiFixtureHttpClientAdapter` L61 |
| `lib/app/debug/debug_app_mock_state.dart` | `existingUserReady` L124；`spaceLifecycle` L136 |
| `lib/app/debug/debug_app_update_mocks.dart` | `DebugContinueAppUpdateStartupGate` L7；`DebugRequiredAppUpdateStartupGate` L15；`DebugNoopAppUpdateStoreLauncher` L40 |
| `test/app/debug/debug_local_entry_test.dart` | `keeps formal entry and app assets free of mock state loading` L92；`BESIDEYOU_MOCK_FORCE_UPDATE` L99 |

## 复核方式

在知识库根目录执行；把占位路径替换成自己已授权的 App checkout：

```shell
python tools/verify_knowledge.py --manifest evidence/app-sources.json
python tools/verify_knowledge.py --manifest evidence/app-sources.json --source-root /path/to/besideyou-flutter
```

第一条检查知识库结构与相对链接；第二条额外比较源码字节。返回 2 表示来源漂移，需要重读文章所依赖的代码，不能只刷新 hash 消除提示。官方网页不在离线可达性检查范围内；查阅日期与直接链接记录在 App 清单，动态网页也不代替项目 SDK 合同。
