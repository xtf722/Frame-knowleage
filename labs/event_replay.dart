// 教学模型：这些对象仅模拟持久记录和接收端，不访问磁盘或真实服务。
class Event {
  const Event(this.id, this.sequence);
  final String id;
  final int sequence;
}

class SimulatedDurableStore {
  Event? pending;
  bool acknowledged = false;
}

class Receiver {
  final Set<String> accepted = {};
  int deliveries = 0;
  int effects = 0;
  bool loseFirstAck = true;

  Future<void> send(Event event) async {
    deliveries++;
    // 同一 eventId 只产生一次效果；实际后端还需定义原子性和payload一致性。
    if (accepted.add(event.id)) effects++;
    if (loseFirstAck) {
      loseFirstAck = false;
      throw StateError('Simulated response loss AFTER the event was accepted.');
    }
  }
}

class Coordinator {
  Coordinator(this.store, this.receiver);
  final SimulatedDurableStore store;
  final Receiver receiver;

  Future<void> continuePending() async {
    final event = store.pending;
    if (event == null) return;
    await receiver.send(event);
    // 收到ACK后才收尾；不确定时让原事件留在恢复记录中。
    store.acknowledged = true;
    store.pending = null;
  }
}

Future<void> main() async {
  final store = SimulatedDurableStore()
    ..pending = const Event('demo-event-1', 1);
  final receiver = Receiver();
  try {
    await Coordinator(store, receiver).continuePending();
    throw StateError('Expected a simulated lost acknowledgement.');
  } on StateError catch (error) {
    if (store.pending == null || receiver.deliveries != 1) rethrow;
    print(error.message);
  }
  final retained = store.pending;
  if (retained?.id != 'demo-event-1' || retained?.sequence != 1) {
    throw StateError('The original event identity must survive.');
  }
  // 换一个协调器对象模拟恢复；保留的记录和接收端均不变。
  await Coordinator(store, receiver).continuePending();
  print(
    'deliveries=${receiver.deliveries} effects=${receiver.effects} '
    'acknowledged=${store.acknowledged}',
  );
  if (receiver.deliveries != 2 ||
      receiver.effects != 1 ||
      !store.acknowledged ||
      store.pending != null) {
    throw StateError('The replay contract failed.');
  }
  print('PASS: restart replayed the same event identity.');
}
