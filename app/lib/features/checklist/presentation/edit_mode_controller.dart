import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ids marked for deletion while editing, or null outside edit mode.
final editModeProvider =
    NotifierProvider.autoDispose<
      EditModeController,
      Set<int>?
    >(EditModeController.new);

class EditModeController extends Notifier<Set<int>?> {
  @override
  Set<int>? build() => null;

  void start() => state = const {};

  void stop() => state = null;

  void markForDeletion(int id) => state = {...?state, id};
}
