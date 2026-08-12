import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fawatiri/services/firestore_service.dart';
import 'invoice_provider.dart';

final pinEnabledProvider = FutureProvider<bool>((ref) =>
    ref.watch(firestoreServiceProvider).isReceiverPinEnabled());

final pinActionsProvider = Provider<PinActions>((ref) =>
    PinActions(ref.read(firestoreServiceProvider)));

class PinActions {
  final FirestoreService _remote;
  PinActions(this._remote);

  Future<bool> verify(String pin) => _remote.verifyReceiverPin(pin);
  Future<void> setPin(String pin) => _remote.saveReceiverPin(pin);
}