import 'dart:async';
import 'dart:io';

// 独立教学模型：不导入产品代码，不访问网络、设备或真实账号。
var passed = 0;

void check(bool condition, String behavior) {
  if (!condition) throw StateError('FAIL: $behavior');
  passed++;
  print('PASS: $behavior');
}

class LatestResult {
  LatestResult({this.guard = true});

  final bool guard;
  String account = 'A';
  int epoch = 0;
  int revision = 0;
  String? value;
  Object? error;
  bool loading = false;

  Future<void> read(Future<String> response) async {
    final owner = epoch;
    final request = ++revision;
    loading = true;
    bool current() => !guard || (owner == epoch && request == revision);
    try {
      final next = await response;
      if (!current()) return;
      value = next;
      error = null;
    } catch (failure) {
      if (current()) error = failure;
    } finally {
      // 清理也是写状态，旧请求不能结束新请求的 loading。
      if (current()) loading = false;
    }
  }

  void replaceSession(String nextAccount) {
    account = nextAccount;
    epoch++;
    revision++;
    value = null;
    error = null;
    loading = false;
  }

  void acceptWrite(String next) {
    // 已确认写入使更早的读取失去覆盖资格。
    revision++;
    value = next;
    error = null;
    loading = false;
  }
}

Future<void> asyncCases(bool broken) async {
  final model = LatestResult(guard: !broken);
  final old = Completer<String>();
  final fresh = Completer<String>();
  final a = model.read(old.future);
  final b = model.read(fresh.future);
  fresh.complete('new');
  await b;
  old.complete('old');
  await a;
  check(model.value == 'new', 'a late success cannot replace a newer result');

  final lateFailure = Completer<String>();
  final c = model.read(lateFailure.future);
  await model.read(Future.value('confirmed'));
  lateFailure.completeError(StateError('old network error'));
  await c;
  check(
    model.error == null && model.value == 'confirmed',
    'a late error cannot replace a newer success',
  );

  final earlier = Completer<String>();
  final later = Completer<String>();
  final d = model.read(earlier.future);
  final e = model.read(later.future);
  earlier.complete('earlier');
  await d;
  check(model.loading, 'old completion cannot stop current loading');
  later.complete('later');
  await e;
  check(!model.loading, 'current completion releases loading');

  final previousSession = Completer<String>();
  final f = model.read(previousSession.future);
  model.replaceSession('B');
  model.replaceSession('A');
  previousSession.complete('old account A data');
  await f;
  check(
    model.account == 'A' && model.value == null,
    'returning to the same account does not revive its old session',
  );

  final beforeWrite = Completer<String>();
  final g = model.read(beforeWrite.future);
  model.acceptWrite('used');
  beforeWrite.complete('available');
  await g;
  check(model.value == 'used', 'confirmed writes invalidate older reads');
}

class EstimateModel {
  // 模拟持久记录；实际只在内存中保存，不测试磁盘、并发或损坏恢复。
  final Map<String, int> deadlines = {};

  int? observe(String identity, int nowSeconds, {required bool eligible}) {
    if (!eligible) return null;
    final deadline = deadlines.putIfAbsent(identity, () => nowSeconds + 3600);
    return deadline > nowSeconds ? deadline : null;
  }
}

bool insideWindow(int nowSeconds, int startSeconds, int endSeconds) =>
    nowSeconds >= startSeconds && nowSeconds < endSeconds;

void timeCases() {
  final estimates = EstimateModel();
  const pass = 'environment/account/activity/pass-1';
  check(
    estimates.observe(pass, 0, eligible: false) == null &&
        estimates.deadlines.isEmpty,
    'waiting does not start an estimate',
  );
  check(
    estimates.observe(pass, 100, eligible: true) == 3700,
    'first production observation anchors the deadline',
  );
  check(
    estimates.observe(pass, 1300, eligible: true) == 3700,
    'reopening keeps the first deadline',
  );
  check(
    estimates.observe(pass, 3700, eligible: true) == null,
    'exact deadline is expired',
  );
  check(
    estimates.observe(pass, 7300, eligible: true) == null &&
        estimates.deadlines[pass] == 3700,
    'expired estimates never restart',
  );
  check(
    estimates.observe('another-pass', 7300, eligible: true) == 10900,
    'another business identity has its own deadline',
  );
  check(
    !insideWindow(9, 10, 20) &&
        insideWindow(10, 10, 20) &&
        !insideWindow(20, 10, 20),
    'windows include start and exclude end',
  );
}

class ResponseLost implements Exception {}

class FakeServer {
  final Map<String, int> receipts = {};
  int effects = 0;
  bool dropFirstResponse = true;

  Future<int> apply(String key) async {
    // 模拟服务端已经执行，然后响应丢失；同键重放返回原回执。
    final receipt = receipts.putIfAbsent(key, () => ++effects);
    if (dropFirstResponse) {
      dropFirstResponse = false;
      throw ResponseLost();
    }
    return receipt;
  }
}

class FakeJournal {
  String? key;
}

class Client {
  Client(this.journal, this.server);
  final FakeJournal journal;
  final FakeServer server;

  Future<int> submit() async {
    // 先保存业务身份；异常时保留记录，避免下一次生成新业务。
    journal.key ??= 'intent-1';
    final receipt = await server.apply(journal.key!);
    journal.key = null;
    return receipt;
  }
}

Future<void> recoveryCases(bool broken) async {
  final journal = FakeJournal();
  final server = FakeServer();
  try {
    await Client(journal, server).submit();
    throw StateError('the first response should be lost');
  } on ResponseLost {
    check(
      journal.key == 'intent-1' && server.effects == 1,
      'lost response retains the original identity',
    );
  }
  if (broken) journal.key = 'intent-2';
  final receipt = await Client(journal, server).submit();
  check(
    receipt == 1 && server.effects == 1,
    'recreated client recovers one effect with the original key',
  );
  check(journal.key == null, 'known completion clears the pending record');
}

class MediaOwners {
  final Set<Object> _active = {};
  void acquire(Object owner) => _active.add(owner);
  void release(Object owner) => _active.remove(owner);
  bool get blocksBackground => _active.isNotEmpty;
}

void ownerCases() {
  final owners = MediaOwners();
  final a = Object();
  final b = Object();
  owners.acquire(a);
  owners.acquire(b);
  owners.release(a);
  check(owners.blocksBackground, 'one owner cannot release another owner');
  owners.release(a);
  check(
    owners.blocksBackground,
    'duplicate release leaves other owners intact',
  );
  owners.release(b);
  check(
    !owners.blocksBackground,
    'last release removes only the ownership gate',
  );
}

Future<void> main(List<String> args) async {
  try {
    await asyncCases(args.contains('--broken-fence'));
    timeCases();
    await recoveryCases(args.contains('--broken-key'));
    ownerCases();
    print(
      'Completed: $passed behavior checks. No product or device execution.',
    );
  } catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  }
}
