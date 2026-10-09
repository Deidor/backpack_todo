import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import 'notebook_button.dart';

/// Bottom panel to type a new item. Pops with the trimmed name, or with null
/// when cancelled.
class AddItemSheet extends StatefulWidget {
  const AddItemSheet({super.key});

  static const int maxNameLength = 60;

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.panel,
      barrierColor: Colors.transparent,
      shape: const RoundedRectangleBorder(),
      builder: (context) => const AddItemSheet(),
    );
  }

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Escribe el nombre del objeto.');
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    const fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(6)),
      borderSide: BorderSide.none,
    );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Añadir Objeto',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.button,
                fontSize: 18,
                fontVariations: [FontVariation('wght', 600)],
                color: AppColors.highlight,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                LengthLimitingTextInputFormatter(AddItemSheet.maxNameLength),
              ],
              onChanged: (_) {
                if (_error != null) {
                  setState(() => _error = null);
                }
              },
              onSubmitted: (_) => _submit(),
              cursorColor: Colors.white,
              style: const TextStyle(
                fontFamily: AppFonts.button,
                fontSize: 15,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: 'Escribe el texto aquí',
                hintStyle: const TextStyle(color: Colors.white54),
                errorText: _error,
                errorStyle: const TextStyle(color: AppColors.highlight),
                filled: true,
                fillColor: AppColors.panelField,
                isDense: true,
                border: fieldBorder,
                enabledBorder: fieldBorder,
                focusedBorder: fieldBorder,
                errorBorder: fieldBorder,
                focusedErrorBorder: fieldBorder,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: NotebookButton(
                    label: 'Cancelar',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NotebookButton(
                    label: 'Añadir',
                    backgroundColor: AppColors.accent,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
