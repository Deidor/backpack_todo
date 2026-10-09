import 'package:flutter_riverpod/flutter_riverpod.dart';

/// When true, "Lo llevo" and "Comprar" behave as alternatives: ticking one
/// clears the other, and "Comprar" gets its own mark.
///
/// Off by default because RF-04 asks for independent checkboxes. Enable with
/// `--dart-define=EXCLUSIVE_CHECKBOXES=true`.
final exclusiveCheckboxesProvider = Provider<bool>(
  (ref) => const bool.fromEnvironment('EXCLUSIVE_CHECKBOXES'),
);
