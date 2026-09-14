# 技术博客源码索引

[博客目录](../articles/README.md) · [机器清单](blog-sources.json) · [验证记录](blog-validation.md)

这些路径属于已有授权的 Frame 源项目，不是公共知识库中的源码文件。相对路径以 Frame app 根目录为基准；`../../packages` 指向同工作区共享包。阅读日期为 2026-09-14。

文件指纹只说明读取的字节；测试文件仅作为反例和断言阅读入口，本轮没有执行产品测试。旧专题索引仍保留其原日期。

<a id="source-225f4526be"></a>

<a id="blog-moment-shared-identity"></a>

## ../../packages/besideyou_client_core/lib/src/media_runtime/media_runtime_policy.dart

- SHA-256：`5e936fe30296f9ee293e513b8e10a2f7660de868be5c73c22764ade4eb2413f6`
- 用于：[articles/moment-cache-continuity.md](../articles/moment-cache-continuity.md)
- 搜索：`BesideYouRuntimeManifestMedia.mediaCacheIdentityFromFields`

<a id="source-a8454fc649"></a>

<a id="blog-portrait-shared-owner"></a>

## ../../packages/besideyou_client_core/lib/src/portrait_player/README.md

- SHA-256：`f1b705c287766e09b279ba5d22626c15645e454c437a7c2328662020083e1d61`
- 用于：[articles/portrait-lifecycle-identity.md](../articles/portrait-lifecycle-identity.md)
- 搜索：`Diagnostics contract`、`Current Boundary`

<a id="source-3b077ba16d"></a>

<a id="blog-portrait-host"></a>

## ../../packages/besideyou_client_core/lib/src/portrait_player/presentation/portrait_player_live_host.dart

- SHA-256：`31d39061f56427ea8096e706e369e4ffc808ffce7b2aedd4b1bf7333284e9e16`
- 用于：[articles/portrait-lifecycle-identity.md](../articles/portrait-lifecycle-identity.md)
- 搜索：`_PortraitPlayerLiveHostState.didUpdateWidget`、`_bootstrapDependencies`、`_bootstrapGeneration`、`_disposeUnattachedDependencies`、`_withBootstrapPoster`、`build`

<a id="source-6129668b33"></a>

<a id="blog-portrait-host-tests"></a>

## ../../packages/besideyou_client_core/test/portrait_player/presentation/portrait_player_live_rebuild_test.dart

- SHA-256：`b3aee4953d5b8904cf1974252d058b73bfcbde8e88361e4568610ae2248d0004`
- 用于：[articles/portrait-lifecycle-identity.md](../articles/portrait-lifecycle-identity.md)
- 搜索：`replacing an existing bootstrap poster preserves the live media state`、`adding and removing a bootstrap poster preserves the live media state`

<a id="source-80523e2c42"></a>

<a id="blog-portrait-native-owner"></a>

## ../../packages/tiny_player/docs/当前播放路线唯一口径.md

- SHA-256：`d73e9ed0cd6448701ddf3f0ca8f698dab8fab8b9d59c032b4d0204ce080302f3`
- 用于：[articles/portrait-lifecycle-identity.md](../articles/portrait-lifecycle-identity.md)
- 搜索：`Android queue 原生实例复用（2026-09-08）`、`playQueue`、`sessionId`、`generation`

<a id="source-add2a0c82e"></a>

<a id="blog-update-host"></a>

## android/app/src/main/kotlin/ai/besideyou/frame/FrameAppUpdateHost.kt

- SHA-256：`8492dcf03c1d879ea88e8318b4a5acd40398d504ad08f222d8840af6b63e22af`
- 用于：[articles/app-update-recovery.md](../articles/app-update-recovery.md)
- 搜索：`installVerifiedApk`、`commitPackageInstallerSession`、`validateArchiveIdentity`、`FrameAppUpdatePersistence`、`saveCoordinatorState`、`saveInstallerState`、`clearCoordinatorState`、`clearInstallerState`

<a id="source-2cfb9e5af4"></a>

<a id="blog-update-receiver"></a>

## android/app/src/main/kotlin/ai/besideyou/frame/FrameAppUpdateInstallReceiver.kt

- SHA-256：`1e6786f6e229bbde50630774a3eaf22806cf5adb32c45a6b0f8ede77fcda4d57`
- 用于：[articles/app-update-recovery.md](../articles/app-update-recovery.md)
- 搜索：`FrameAppUpdateInstallReceiver.onReceive`、`pendingUserAction`

<a id="source-0318a5d1ab"></a>

<a id="blog-update-submission"></a>

## android/app/src/main/kotlin/ai/besideyou/frame/FrameAppUpdateInstallerSubmission.kt

- SHA-256：`e7f37b3203fa49a27df1556691d4401009e95300c262bf4b60c55bb9c7eaf951`
- 用于：[articles/app-update-recovery.md](../articles/app-update-recovery.md)
- 搜索：`FrameAppUpdateInstallerSubmission.submit`、`commitAttempted`、`PREPARE_FAILED`、`CLEANUP_UNCONFIRMED`、`COMMIT_UNCONFIRMED`

<a id="source-d51e36dbe9"></a>

<a id="blog-update-submission-tests"></a>

## android/app/src/test/kotlin/ai/besideyou/frame/FrameAppUpdateInstallerSubmissionTest.kt

- SHA-256：`6cf9bda7504bf7904140266f495dd9a10d575cb79618e56c92f1f60839d710f7`
- 用于：[articles/app-update-recovery.md](../articles/app-update-recovery.md)
- 搜索：`submission persists before commit and releases the session after commit`、`every preparation failure is retryable only after its session is abandoned`、`failed abandon blocks new sessions in this process and after restoration`、`commit exception preserves submitted or the terminal receiver result without abandoning`、`close failure after commit returns does not turn accepted submission into a retry`

<a id="source-95e8dab761"></a>

<a id="blog-wifi-app"></a>

## lib/app/frame_app.dart

- SHA-256：`c9bbe763ef4980d9fef99ac0535ef668e80c173196478d0985d16e64a540418c`
- 用于：[articles/wifi-readiness-handoff.md](../articles/wifi-readiness-handoff.md)
- 搜索：`_wifiStatusObserver`、`_handleAppUpdateWifiChanged`

<a id="source-83653d89db"></a>

<a id="blog-portrait-routes"></a>

<a id="blog-moment-routes"></a>

<a id="blog-wifi-routes"></a>

## lib/app/route/frame_routes.dart

- SHA-256：`c3307e68ca061f3e0c2005a5756c42dd5f0eb1fe027a53bb294572a397eba128`
- 用于：[articles/portrait-lifecycle-identity.md](../articles/portrait-lifecycle-identity.md) · [articles/moment-cache-continuity.md](../articles/moment-cache-continuity.md) · [articles/wifi-readiness-handoff.md](../articles/wifi-readiness-handoff.md)
- 搜索：`_portraitStagePageForState`、`playbackIdentity`、`_albumPageForState`、`_albumPlaybackSessionIdentity`、`FrameRouteName.wifiSetup`、`FrameRouteName.settingsNetwork`

<a id="source-b14673fdce"></a>

<a id="blog-update-owner"></a>

## lib/src/features/app_update/README.html

- SHA-256：`f3eb15c88c2b9983dceba8a141357117af2357ed42eb2304e11fe57b978a3c5e`
- 用于：[articles/app-update-recovery.md](../articles/app-update-recovery.md)
- 搜索：`discovery-scheduling`、`installer-submission-retry`、`恢复与幂等`、`UI`

<a id="source-2dca7594fe"></a>

<a id="blog-update-controller"></a>

## lib/src/features/app_update/frame_app_update_controller.dart

- SHA-256：`0a66933aefe4d37cee3e1c1e8e35839362eaadee3fadbdd9bf7228fc56ad418c`
- 用于：[articles/app-update-recovery.md](../articles/app-update-recovery.md)
- 搜索：`FrameAppUpdatePhase`、`postponeInstall`、`_PersistedUpdateAttempt`、`_continuePersistedAttempt`、`_submitDownloadedUpdate`、`_retry`、`_installerRetryAdmitted`、`_reportIfNeeded`、`_flushQueuedEvent`、`_confirmInstalledApp`、`_runExclusive`

<a id="source-cff9022b11"></a>

<a id="blog-update-downloader"></a>

## lib/src/features/app_update/frame_app_update_downloader.dart

- SHA-256：`5162fef39a90cdd5c7934998aedaf0ff96ebd9e21c2bbac3359aaa9d5753f975`
- 用于：[articles/app-update-recovery.md](../articles/app-update-recovery.md)
- 搜索：`HttpFrameAppUpdateDownloader.download`、`_deletePartial`

<a id="source-4c7d22fe13"></a>

<a id="blog-portrait-companion-owner"></a>

## lib/src/features/companion/README.html

- SHA-256：`f700a73d18258259c39bb78677b0e900352520239cff7c6c1ee5d4d408ac8d4e`
- 用于：[articles/portrait-lifecycle-identity.md](../articles/portrait-lifecycle-identity.md)
- 搜索：`portrait-poster-localization-continuity`、`portrait-resource-lifecycle`、`portrait-performance-20260909`

<a id="source-83200d27ef"></a>

<a id="blog-moment-data-transfer"></a>

## lib/src/features/data_transfer/README.html

- SHA-256：`ae041146c6b50a4302635d328f244ed3078b9a3dd42ab016473110e7136423c7`
- 用于：[articles/moment-cache-continuity.md](../articles/moment-cache-continuity.md)
- 搜索：`moment-cache-first-playback`、`cache-first-playback`

<a id="source-886fe19d83"></a>

<a id="blog-moment-first-sync"></a>

## lib/src/features/data_transfer/frame_first_sync.dart

- SHA-256：`977158c87f3160dd99e80181289f04a285a71bc9e0956e0e9ff3a6852f02dc40`
- 用于：[articles/moment-cache-continuity.md](../articles/moment-cache-continuity.md)
- 搜索：`authoritativeCandidates`、`_matchesMediaIdentity`、`_hasOnlyAuthoritativeHttpsAlbumMedia`、`_publishPlaybackReady`

<a id="source-4c34a86877"></a>

<a id="blog-moment-cache"></a>

## lib/src/features/frame_album/frame_album_cache.dart

- SHA-256：`28adf201db2061da6057c2a6872d270684d70a29568e125bec3ecc1c14426f67`
- 用于：[articles/moment-cache-continuity.md](../articles/moment-cache-continuity.md)
- 搜索：`FrameAlbumMediaCachePreparer.resolveCached`、`_validateCacheHit`、`_cacheFingerprint`

<a id="source-1df70f9b0b"></a>

<a id="blog-moment-models"></a>

## lib/src/features/frame_album/frame_album_models.dart

- SHA-256：`da92e328e4aaf89cf834244de02eebaf9a594c1088414037b0076c8274104cac`
- 用于：[articles/moment-cache-continuity.md](../articles/moment-cache-continuity.md)
- 搜索：`FrameAlbumItem`、`FrameAlbumItemSource`、`FrameAlbumItem.mediaCacheIdentity`

<a id="source-e11368de0f"></a>

<a id="blog-moment-playback"></a>

## lib/src/features/frame_album/frame_album_playback_page.dart

- SHA-256：`c51e976de9c554b34acaac149da537873fe668577b3c6c783010c89c43cf8815`
- 用于：[articles/moment-cache-continuity.md](../articles/moment-cache-continuity.md)
- 搜索：`FrameAlbumPlaybackItem.hasSameMediaIdentity`、`FrameAlbumPlaybackItem.hasSamePlaybackContent`、`_cacheFirstPlaybackItems`、`_samePlaybackQueue`、`_FrameAlbumPlaybackPageState.didUpdateWidget`、`_activeSource`、`_syncActivePlaybackPolicy`、`_FrameAlbumVideoPlayerState._configureAndPlay`、`_sourceOperationGeneration`、`_soundPolicyGeneration`、`_thumbnailOperationGeneration`

<a id="source-0a00066c7d"></a>

<a id="blog-moment-gallery"></a>

## lib/src/features/gallery/README.html

- SHA-256：`7960fcb71bfc0b99432b72b4c6de94a96c141669e86b134ebc2fd8e8ccf27cc6`
- 用于：[articles/moment-cache-continuity.md](../articles/moment-cache-continuity.md)
- 搜索：`FrameAlbumMediaType.image`、`playbackChanges`、`filterPlaybackItemsByOwnership`

<a id="source-46f2776d39"></a>

<a id="blog-portrait-home-owner"></a>

## lib/src/features/home/README.html

- SHA-256：`54a5dfaf7758faf136b4c93c3c87e4625f0726e9fc4fe715099e4c4a0de54fb4`
- 用于：[articles/portrait-lifecycle-identity.md](../articles/portrait-lifecycle-identity.md)
- 搜索：`HOME`、`PowerVR`、`requireVideoSurface`、`Portrait`

<a id="source-fe3eff6d65"></a>

<a id="blog-portrait-assets"></a>

## lib/src/features/portrait_stage/frame_portrait_live_video_asset_store.dart

- SHA-256：`6fa613947abaa27803e219309adfd87833e31657007d5e826f96bbe84b0e570c`
- 用于：[articles/portrait-lifecycle-identity.md](../articles/portrait-lifecycle-identity.md)
- 搜索：`FramePortraitLiveVideoAssetStore`、`updateManifest`、`_aliasesFor`、`materialize`

<a id="source-c969a6cf62"></a>

<a id="blog-portrait-stage"></a>

## lib/src/features/portrait_stage/frame_portrait_stage_page.dart

- SHA-256：`81a107f59722478c00422ced1a4e511a9a601e8530af7b02ce939243e63f4f6f`
- 用于：[articles/portrait-lifecycle-identity.md](../articles/portrait-lifecycle-identity.md)
- 搜索：`_FramePortraitSessionInputs.hasSameTransition`、`_stableDependenciesLoader`、`didUpdateWidget`、`_resolveTargetPoster`、`_commitPreparedSession`、`_loadDependencies`、`_posterGeneration`、`_dependencyLoadGeneration`

<a id="source-fcd62b8e37"></a>

<a id="blog-moment-settings"></a>

## lib/src/features/settings/README.html

- SHA-256：`518f101c9cfc3a858ad313ef48fc8fb5f309ee0bc43acd2458d5b8e5407fc6f1`
- 用于：[articles/moment-cache-continuity.md](../articles/moment-cache-continuity.md)
- 搜索：`Current downstream behavior`、`FrameSlideshowInterval.never`、`Every 60s`

<a id="source-1605f96079"></a>

<a id="blog-wifi-page"></a>

## lib/src/features/wifi/frame_wifi_design_page.dart

- SHA-256：`3a7c3a11708bfe7685e784e8be690af3fb256076757e667dac624ebaf324aca6`
- 用于：[articles/wifi-readiness-handoff.md](../articles/wifi-readiness-handoff.md)
- 搜索：`_handoffWhenReady`、`_isCurrentHandoff`、`_handoffSavedWifiOnStartup`

<a id="source-d0faccd468"></a>

<a id="blog-wifi-observer"></a>

## lib/src/features/wifi/frame_wifi_status_observer.dart

- SHA-256：`e2ba234bbd05f1db3b8534f28a2c6efb54f76ca410c3249fb379cafe6698e162`
- 用于：[articles/wifi-readiness-handoff.md](../articles/wifi-readiness-handoff.md)
- 搜索：`FrameWifiStatusObserver`、`_readPending`、`refresh`、`stop`

<a id="source-3a278e482c"></a>

<a id="blog-update-controller-tests"></a>

## test/src/features/app_update/frame_app_update_controller_test.dart

- SHA-256：`673330dd65998960d9e9263604603f643d233061aa666aca636547fe1605a347`
- 用于：[articles/app-update-recovery.md](../articles/app-update-recovery.md)
- 搜索：`prepare failure retains the verified APK until explicit Retry`、`only reconciles on Retry and recovery`、`pending event ACK save failure replays the same durable event after restart`、`Retry after a prepare failure requires successful Android readback`、`replays the same durable event after an uncertain response`

<a id="source-dde4bff34e"></a>

<a id="blog-moment-cache-test"></a>

## test/src/features/frame_album/frame_album_cache_lookup_test.dart

- SHA-256：`c95eb9f82cfc0d466971eb8bba4a9b54197bea1997061d47cc6f9713617872bf`
- 用于：[articles/moment-cache-continuity.md](../articles/moment-cache-continuity.md)
- 搜索：`a new managed commit during digest invalidates the old file proof`、`digest does not hold Storage FIFO and revoked lookup cannot publish`

<a id="source-ab0b20ab1e"></a>

<a id="blog-moment-test"></a>

## test/src/features/frame_album/frame_album_playback_page_test.dart

- SHA-256：`64ca8238c7dd3f7444f7de7861bb568a3a6308d489eb19ad3a453af9176be426`
- 用于：[articles/moment-cache-continuity.md](../articles/moment-cache-continuity.md)
- 搜索：`cache upgrade preserves photo deadline and uses next local file`、`cache upgrade keeps playing video until its original deadline`、`a delayed old video setup cannot replay the replacement source`、`video pause resumes the same source without pause feedback`

<a id="source-542aa9a2e4"></a>

<a id="blog-moment-policy-test"></a>

## test/src/features/frame_album/frame_album_runtime_policy_test.dart

- SHA-256：`51d034120bdea3e3a5ac716283d7d9a2a0a79c9a4daf2d8815bea733a3aa486c`
- 用于：[articles/moment-cache-continuity.md](../articles/moment-cache-continuity.md)
- 搜索：`current video survives index shift without new play stop or disposal`、`remote to cache upgrade retains current video source and controller`、`manual drag`、`Never video plays normally and neither max duration nor completion advances`

<a id="source-f9320751c0"></a>

<a id="blog-portrait-asset-tests"></a>

## test/src/features/portrait_stage/frame_portrait_live_video_asset_store_test.dart

- SHA-256：`cc837512c0f411921a533bf0872781681672f947e390a723a134bf8f9aa79cbf`
- 用于：[articles/portrait-lifecycle-identity.md](../articles/portrait-lifecycle-identity.md)
- 搜索：`same runtime promotes initial remote reference to trusted cached file`、`cross-frame, pet, revision, media and reference changes cannot remap active driver`、`missing trusted cache fails without using stale remote URL`

<a id="source-2aa098367c"></a>

<a id="blog-portrait-stage-tests"></a>

## test/src/features/portrait_stage/frame_portrait_stage_page_test.dart

- SHA-256：`c532cf18dc7ceca4ea8ec0dadcfec801b8806493803003a92cd2193407ea2547`
- 用于：[articles/portrait-lifecycle-identity.md](../articles/portrait-lifecycle-identity.md)
- 搜索：`network poster localization retains the mounted video surface`、`cached poster online refresh retains the mounted video surface`、`returning to the active companion cancels a pending poster switch`、`same-transition rebuild while loading still reveals decoded content`、`repeated poster switches release decoded image handles`

<a id="source-085fdc4f7f"></a>

<a id="blog-wifi-page-tests"></a>

## test/src/features/wifi/frame_wifi_design_page_test.dart

- SHA-256：`86ed87a02620338e63de9feb07e8c1b21866dbe7f4cc03edffa4b5d271f9af36`
- 用于：[articles/wifi-readiness-handoff.md](../articles/wifi-readiness-handoff.md)
- 搜索：`handoff rechecks WiFi after health before navigating`、`Refresh cancels pending health and only latest handoff navigates`

<a id="source-27a9e1407f"></a>

<a id="blog-wifi-observer-tests"></a>

## test/src/features/wifi/frame_wifi_status_observer_test.dart

- SHA-256：`baa49fa661b993008ca1c71cd1dc9f3be5c4376b297dab61368528cab825f97e`
- 用于：[articles/wifi-readiness-handoff.md](../articles/wifi-readiness-handoff.md)
- 搜索：`timeout clears stale connection without piling up platform reads`
